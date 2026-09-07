import 'package:intl/intl.dart';

class CurrencyFormatter {
  static const List<String> _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  static const List<String> _englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

  /// تبدیل ارقام انگلیسی یا متفرقه به ارقام فارسی
  static String toPersianDigits(dynamic input) {
    if (input == null) return '';
    String str = input.toString();
    for (int i = 0; i < 10; i++) {
      str = str.replaceAll(_englishDigits[i], _persianDigits[i]);
    }
    return str;
  }

  /// تبدیل ارقام فارسی و عربی به ارقام استاندارد انگلیسی
  static String toEnglishDigits(String input) {
    String str = input;
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < 10; i++) {
      str = str.replaceAll(_persianDigits[i], _englishDigits[i]);
      str = str.replaceAll(arabicDigits[i], _englishDigits[i]);
    }
    return str;
  }

  /// حذف تمام کاراکترهای غیرعددی (کاما، خط تیره و...) و تبدیل به عدد
  static int parseCleanAmount(String text) {
    final cleaned = toEnglishDigits(text).replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.isEmpty) return 0;
    return int.tryParse(cleaned) ?? 0;
  }

  /// تبدیل ریال به تومان
  static int rialToToman(int rial) {
    return (rial / 10).floor();
  }

  /// تبدیل تومان به ریال
  static int tomanToRial(int toman) {
    return toman * 10;
  }

  /// فرمت عدد ۳ رقم ۳ رقم با ارقام فارسی
  static String formatNumber(num number) {
    final formatter = NumberFormat('#,###', 'en_US');
    return toPersianDigits(formatter.format(number));
  }

  /// فرمت بر حسب ریال
  static String formatRial(int amountRial, {bool includeUnit = true}) {
    final formatted = formatNumber(amountRial);
    return includeUnit ? '$formatted ریال' : formatted;
  }

  /// فرمت بر حسب تومان (مقدار ورودی بر حسب ریال است)
  static String formatTomanFromRial(int amountRial, {bool includeUnit = true}) {
    final toman = rialToToman(amountRial);
    final formatted = formatNumber(toman);
    return includeUnit ? '$formatted تومان' : formatted;
  }

  /// فرمت بر حسب تومان (مقدار ورودی بر حسب تومان است)
  static String formatToman(int amountToman, {bool includeUnit = true}) {
    final formatted = formatNumber(amountToman);
    return includeUnit ? '$formatted تومان' : formatted;
  }

  /// تبدیل عدد تومان به حروف فارسی روان (تا میلیاردها تومان)
  static String numberToPersianWords(int toman) {
    if (toman == 0) return 'صفر تومان';
    if (toman < 0) return 'منفی ${numberToPersianWords(toman.abs())}';

    const ones = ['', 'یک', 'دو', 'سه', 'چهار', 'پنج', 'شش', 'هفت', 'هشت', 'نه'];
    const teens = [
      'ده',
      'یازده',
      'دوازده',
      'سیزده',
      'چهارده',
      'پانزده',
      'شانزده',
      'هفده',
      'هجده',
      'نوزده'
    ];
    const tens = ['', '', 'بیست', 'سی', 'چهل', 'پنجاه', 'شصت', 'هفتاد', 'هشتاد', 'نود'];
    const hundreds = [
      '',
      'یکصد',
      'دویست',
      'سیصد',
      'چهارصد',
      'پانصد',
      'ششصد',
      'هفتصد',
      'هشتصد',
      'نهصد'
    ];
    const scales = ['', 'هزار', 'میلیون', 'میلیارد', 'تریلیون'];

    String convertThreeDigits(int n) {
      final parts = <String>[];
      final h = (n / 100).floor();
      final remainder = n % 100;

      if (h > 0) parts.add(hundreds[h]);

      if (remainder >= 10 && remainder < 20) {
        parts.add(teens[remainder - 10]);
      } else {
        final t = (remainder / 10).floor();
        final o = remainder % 10;
        if (t > 0) parts.add(tens[t]);
        if (o > 0) parts.add(ones[o]);
      }

      return parts.join(' و ');
    }

    final scaleParts = <String>[];
    int current = toman;
    int scaleIndex = 0;

    while (current > 0 && scaleIndex < scales.length) {
      final chunk = current % 1000;
      if (chunk > 0) {
        final chunkText = convertThreeDigits(chunk);
        final scale = scales[scaleIndex];
        if (scale.isNotEmpty) {
          scaleParts.insert(0, '$chunkText $scale');
        } else {
          scaleParts.insert(0, chunkText);
        }
      }
      current = (current / 1000).floor();
      scaleIndex++;
    }

    if (scaleParts.isEmpty) return 'صفر تومان';
    return '${scaleParts.join(' و ')} تومان';
  }
}
