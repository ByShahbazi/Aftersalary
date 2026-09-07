import '../database/app_database.dart';
import '../utils/currency_formatter.dart';

class ParsedSmsResult {
  final bool isMatched;
  final int? bankId;
  final String? bankName;
  final int? amountRial;
  final String type; // 'withdraw' or 'deposit'
  final int? remainingBalanceRial;
  final String? templateName;
  final String? accountNumber;
  final String? description;
  final String rawText;

  const ParsedSmsResult({
    required this.isMatched,
    this.bankId,
    this.bankName,
    this.amountRial,
    this.type = 'withdraw',
    this.remainingBalanceRial,
    this.templateName,
    this.accountNumber,
    this.description,
    required this.rawText,
  });

  factory ParsedSmsResult.unmatched(String rawText) {
    return ParsedSmsResult(
      isMatched: false,
      rawText: rawText,
    );
  }
}

class SmsParserService {
  /// نرمال‌سازی نویسه‌های عربی و فارسی برای تطبیق دقیق عبارات باقاعده
  static String normalizeText(String text) {
    return CurrencyFormatter.toEnglishDigits(text)
        .replaceAll('ك', 'ک')
        .replaceAll('ي', 'ی')
        .replaceAll('إ', 'ا')
        .replaceAll('أ', 'ا')
        .replaceAll('ة', 'ه');
  }

  /// پردازش و تطبیق متن پیامک با الگوهای موجود بانک‌ها
  static ParsedSmsResult parse({
    required String rawText,
    required List<SmsTemplate> templates,
    required List<Bank> banks,
  }) {
    if (rawText.trim().isEmpty) {
      return ParsedSmsResult.unmatched(rawText);
    }

    final normalized = normalizeText(rawText);

    // ۱. بررسی الگوی اختصاصی بانک قرض‌الحسنه رسالت
    final resalatResult = _parseBankResalat(normalized, rawText, banks);
    if (resalatResult != null) return resalatResult;

    // ۲. بررسی الگوی اختصاصی بانک ملی ایران
    final melliResult = _parseBankMelli(normalized, rawText, banks);
    if (melliResult != null) return melliResult;

    // ۳. بررسی الگوهای اختصاصی ذخیره‌شده در پایگاه‌داده
    for (final template in templates) {
      try {
        final regex = RegExp(template.regex, multiLine: true, caseSensitive: false);
        final match = regex.firstMatch(normalized);

        if (match != null) {
          int? amount;
          if (template.amountGroupIndex <= match.groupCount) {
            final amountStr = match.group(template.amountGroupIndex);
            if (amountStr != null) {
              amount = CurrencyFormatter.parseCleanAmount(amountStr);
            }
          }

          int? balance;
          if (template.balanceGroupIndex != null &&
              template.balanceGroupIndex! <= match.groupCount) {
            final balanceStr = match.group(template.balanceGroupIndex!);
            if (balanceStr != null) {
              balance = CurrencyFormatter.parseCleanAmount(balanceStr);
            }
          }

          String type = 'withdraw';
          if (normalized.contains(template.depositKeyword)) {
            type = 'deposit';
          } else if (normalized.contains(template.withdrawKeyword)) {
            type = 'withdraw';
          }

          final bank = banks.where((b) => b.id == template.bankId).firstOrNull;

          if (amount != null && amount > 0) {
            return ParsedSmsResult(
              isMatched: true,
              bankId: template.bankId,
              bankName: bank?.name,
              amountRial: amount,
              type: type,
              remainingBalanceRial: balance,
              templateName: template.patternName,
              rawText: rawText,
            );
          }
        }
      } catch (_) {
        continue;
      }
    }

    // ۴. الگوی عمومی هوشمند (Fallback)
    return _fallbackGenericParse(normalized, rawText, banks);
  }

  /// پارسر اختصاصی بانک قرض‌الحسنه رسالت
  /// نمونه:
  /// 10.13580900.1
  /// -1,630,000
  /// 06/07_17:04
  /// مانده: 2,916,248
  static ParsedSmsResult? _parseBankResalat(String normalized, String rawText, List<Bank> banks) {
    final lines = normalized.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    String? accNum;
    int? amount;
    String type = 'withdraw';
    int? balance;

    for (final line in lines) {
      // ۱. شماره حساب رسالت با فرمت x.x.x (مثلاً 10.13580900.1)
      if (RegExp(r'^[0-9]+(?:\.[0-9]+)+$').hasMatch(line)) {
        accNum = line;
        continue;
      }

      // ۲. خط مبلغ با علامت - یا + (مثلاً: -1,630,000 یا +587,284,399)
      final amountMatch = RegExp(r'^([+-])\s*([0-9,]{4,})$').firstMatch(line);
      if (amountMatch != null && amount == null) {
        final sign = amountMatch.group(1);
        amount = CurrencyFormatter.parseCleanAmount(amountMatch.group(2)!);
        type = sign == '+' ? 'deposit' : 'withdraw';
        continue;
      }

      // ۳. مانده (مثلاً: مانده: 2,916,248)
      if (line.contains('مانده')) {
        final balMatch = RegExp(r'مانده:?\s*([0-9,]+)').firstMatch(line);
        if (balMatch != null) {
          balance = CurrencyFormatter.parseCleanAmount(balMatch.group(1)!);
        }
        continue;
      }
    }

    if (amount != null && amount > 0 && (accNum != null || normalized.contains('رسالت'))) {
      final resalatBank = banks.where((b) => b.name.contains('رسالت')).firstOrNull;
      return ParsedSmsResult(
        isMatched: true,
        bankId: resalatBank?.id,
        bankName: resalatBank?.name ?? 'بانک قرض‌الحسنه رسالت',
        amountRial: amount,
        type: type,
        remainingBalanceRial: balance,
        accountNumber: accNum,
        templateName: 'بانک قرض‌الحسنه رسالت',
        description: type == 'deposit' ? 'واریز رسالت' : 'برداشت رسالت',
        rawText: rawText,
      );
    }
    return null;
  }

  /// پارسر اختصاصی بانک ملی ایران
  /// نمونه:
  /// بانك ملي ايران
  /// انتقال:8,250,000+
  /// حساب:77003
  /// مانده:11,038,317
  /// 0609-19:54
  static ParsedSmsResult? _parseBankMelli(String normalized, String rawText, List<Bank> banks) {
    final isMelli = normalized.contains('بانک ملی') || normalized.contains('بانک ملی ایران');
    if (!isMelli) return null;

    final lines = normalized.split(RegExp(r'\r?\n')).map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    String? desc;
    int? amount;
    String type = 'withdraw';
    String? accNum;
    int? balance;

    for (final line in lines) {
      // ۱. جستجوی خط عملیات و مبلغ (مثلاً: انتقال:8,250,000+ یا خريداينترنتي:3,850,000-)
      final opAmountRegex = RegExp(r'^(?:([^:\n]+)[:\s]+)?([0-9,]{4,})\s*([+-])$|^(?:([^:\n]+)[:\s]+)?([+-])\s*([0-9,]{4,})$');
      final match = opAmountRegex.firstMatch(line);
      if (match != null && amount == null) {
        if (match.group(2) != null) {
          desc = match.group(1)?.trim();
          amount = CurrencyFormatter.parseCleanAmount(match.group(2)!);
          type = match.group(3) == '+' ? 'deposit' : 'withdraw';
        } else if (match.group(6) != null) {
          desc = match.group(4)?.trim();
          amount = CurrencyFormatter.parseCleanAmount(match.group(6)!);
          type = match.group(5) == '+' ? 'deposit' : 'withdraw';
        }
        continue;
      }

      // ۲. شماره حساب (مثلاً حساب:77003)
      if (line.startsWith('حساب') || line.contains('حساب:')) {
        final accMatch = RegExp(r'حساب:?\s*([0-9]+)').firstMatch(line);
        if (accMatch != null) {
          accNum = accMatch.group(1);
        }
        continue;
      }

      // ۳. مانده (مثلاً مانده:11,038,317)
      if (line.startsWith('مانده') || line.contains('مانده:')) {
        final balMatch = RegExp(r'مانده:?\s*([0-9,]+)').firstMatch(line);
        if (balMatch != null) {
          balance = CurrencyFormatter.parseCleanAmount(balMatch.group(1)!);
        }
        continue;
      }
    }

    if (amount != null && amount > 0) {
      final melliBank = banks.where((b) => b.name.contains('ملی')).firstOrNull;
      return ParsedSmsResult(
        isMatched: true,
        bankId: melliBank?.id,
        bankName: melliBank?.name ?? 'بانک ملی',
        amountRial: amount,
        type: type,
        remainingBalanceRial: balance,
        accountNumber: accNum,
        templateName: 'بانک ملی ایران',
        description: desc != null && desc.isNotEmpty ? desc : (type == 'deposit' ? 'واریز' : 'برداشت'),
        rawText: rawText,
      );
    }
    return null;
  }

  static ParsedSmsResult _fallbackGenericParse(String normalized, String rawText, List<Bank> banks) {
    Bank? matchedBank;
    for (final bank in banks) {
      if (normalized.contains(normalizeText(bank.name)) ||
          (bank.smsSenderNumber != null && normalized.contains(bank.smsSenderNumber!))) {
        matchedBank = bank;
        break;
      }
    }

    String type = 'withdraw';
    if (normalized.contains('واریز') || normalized.contains('افزایش') || normalized.contains('+')) {
      type = 'deposit';
    } else if (normalized.contains('برداشت') || normalized.contains('خرید') || normalized.contains('کاهش') || normalized.contains('-')) {
      type = 'withdraw';
    }

    final amountRegex = RegExp(r'(?:مبلغ[:\s]*)?([0-9,]+)\s*(ریال|تومان)?');
    final matches = amountRegex.allMatches(normalized);

    for (final m in matches) {
      final numStr = m.group(1);
      if (numStr != null) {
        int parsedNum = CurrencyFormatter.parseCleanAmount(numStr);
        if (parsedNum >= 1000) {
          final unit = m.group(2);
          if (unit == 'تومان') {
            parsedNum = CurrencyFormatter.tomanToRial(parsedNum);
          }

          // استخراج مانده در صورت وجود
          int? balance;
          final balanceRegex = RegExp(r'مانده:?\s*([0-9,]+)');
          final balanceMatch = balanceRegex.firstMatch(normalized);
          if (balanceMatch != null) {
            balance = CurrencyFormatter.parseCleanAmount(balanceMatch.group(1) ?? '0');
          }

          return ParsedSmsResult(
            isMatched: true,
            bankId: matchedBank?.id,
            bankName: matchedBank?.name,
            amountRial: parsedNum,
            type: type,
            remainingBalanceRial: balance,
            templateName: 'الگوی عمومی هوشمند',
            rawText: rawText,
          );
        }
      }
    }

    return ParsedSmsResult.unmatched(rawText);
  }
}
