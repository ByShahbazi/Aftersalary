import 'dart:convert';
import 'package:drift/drift.dart';
import '../database/app_database.dart';

class BackupService {
  /// خروجی گرفتن از تمام اطلاعات دیتابیس به فرمت استاندارد JSON
  static Future<String> exportDatabase(AppDatabase db) async {
    final banks = await db.getAllBanks();
    final accounts = await db.getAllAccounts();
    final categories = await db.getAllCategories();
    final plannedPayments = await db.getPlannedPayments();
    final transactions = await db.getTransactions();
    final salaryPeriod = await db.getActiveSalaryPeriod();
    final templates = await db.getAllSmsTemplates();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'app': 'Aftersalary',
      'banks': banks.map((b) => {
        'id': b.id,
        'name': b.name,
        'colorHex': b.colorHex,
        'iconName': b.iconName,
        'smsSenderNumber': b.smsSenderNumber,
      }).toList(),
      'accounts': accounts.map((a) => {
        'id': a.id,
        'bankId': a.bankId,
        'title': a.title,
        'accountNumber': a.accountNumber,
        'currentBalanceRial': a.currentBalanceRial,
      }).toList(),
      'categories': categories.map((c) => {
        'id': c.id,
        'title': c.title,
        'iconCode': c.iconCode,
        'colorHex': c.colorHex,
        'type': c.type,
        'isDefault': c.isDefault,
      }).toList(),
      'plannedPayments': plannedPayments.map((p) => {
        'id': p.id,
        'accountId': p.accountId,
        'categoryId': p.categoryId,
        'title': p.title,
        'amountRial': p.amountRial,
        'dueDate': p.dueDate.toIso8601String(),
        'status': p.status,
        'isRecurring': p.isRecurring,
      }).toList(),
      'transactions': transactions.map((t) => {
        'id': t.id,
        'accountId': t.accountId,
        'categoryId': t.categoryId,
        'amountRial': t.amountRial,
        'type': t.type,
        'occurredAt': t.occurredAt.toIso8601String(),
        'rawSmsText': t.rawSmsText,
        'isCategorized': t.isCategorized,
        'description': t.description,
      }).toList(),
      'salaryPeriod': salaryPeriod != null ? {
        'startDayOfMonth': salaryPeriod.startDayOfMonth,
        'isActive': salaryPeriod.isActive,
      } : null,
      'smsTemplates': templates.map((s) => {
        'id': s.id,
        'bankId': s.bankId,
        'patternName': s.patternName,
        'regex': s.regex,
        'amountGroupIndex': s.amountGroupIndex,
        'balanceGroupIndex': s.balanceGroupIndex,
        'withdrawKeyword': s.withdrawKeyword,
        'depositKeyword': s.depositKeyword,
      }).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// بازیابی اطلاعات از فایل پشتیبان JSON
  static Future<bool> importDatabase(AppDatabase db, String jsonString) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      if (data['app'] != 'Aftersalary') {
        throw Exception('فایل پشتیبان نامعتبر است.');
      }

      await db.transaction(() async {
        // ۱. پاکسازی جداول موجود
        await db.delete(db.transactions).go();
        await db.delete(db.plannedPayments).go();
        await db.delete(db.accounts).go();
        await db.delete(db.smsTemplates).go();
        await db.delete(db.banks).go();
        await db.delete(db.categories).go();
        await db.delete(db.salaryPeriods).go();

        // ۲. درج بانک‌ها
        if (data['banks'] is List) {
          for (final b in data['banks']) {
            await db.into(db.banks).insert(BanksCompanion.insert(
              id: Value(b['id']),
              name: b['name'],
              colorHex: b['colorHex'],
              iconName: Value(b['iconName'] ?? 'account_balance'),
              smsSenderNumber: Value(b['smsSenderNumber']),
            ));
          }
        }

        // ۳. درج دسته‌بندی‌ها
        if (data['categories'] is List) {
          for (final c in data['categories']) {
            await db.into(db.categories).insert(CategoriesCompanion.insert(
              id: Value(c['id']),
              title: c['title'],
              iconCode: c['iconCode'],
              colorHex: c['colorHex'],
              type: c['type'],
              isDefault: Value(c['isDefault'] ?? false),
            ));
          }
        }

        // ۴. درج حساب‌ها
        if (data['accounts'] is List) {
          for (final a in data['accounts']) {
            await db.into(db.accounts).insert(AccountsCompanion.insert(
              id: Value(a['id']),
              bankId: a['bankId'],
              title: a['title'],
              accountNumber: Value(a['accountNumber']),
              currentBalanceRial: Value(a['currentBalanceRial']),
            ));
          }
        }

        // ۵. درج تعهدات
        if (data['plannedPayments'] is List) {
          for (final p in data['plannedPayments']) {
            await db.into(db.plannedPayments).insert(PlannedPaymentsCompanion.insert(
              id: Value(p['id']),
              accountId: p['accountId'],
              categoryId: Value(p['categoryId']),
              title: p['title'],
              amountRial: p['amountRial'],
              dueDate: DateTime.parse(p['dueDate']),
              status: Value(p['status'] ?? 'pending'),
              isRecurring: Value(p['isRecurring'] ?? false),
            ));
          }
        }

        // ۶. درج تراکنش‌ها
        if (data['transactions'] is List) {
          for (final t in data['transactions']) {
            await db.into(db.transactions).insert(TransactionsCompanion.insert(
              id: Value(t['id']),
              accountId: t['accountId'],
              categoryId: Value(t['categoryId']),
              amountRial: t['amountRial'],
              type: t['type'],
              occurredAt: DateTime.parse(t['occurredAt'] ?? t['dateTime']),
              rawSmsText: Value(t['rawSmsText']),
              isCategorized: Value(t['isCategorized'] ?? false),
              description: Value(t['description']),
            ));
          }
        }

        // ۷. درج دوره حقوقی
        if (data['salaryPeriod'] is Map) {
          final sp = data['salaryPeriod'];
          await db.into(db.salaryPeriods).insert(SalaryPeriodsCompanion.insert(
            startDayOfMonth: Value(sp['startDayOfMonth'] ?? 1),
            isActive: Value(sp['isActive'] ?? true),
          ));
        }

        // ۸. درج قالب‌های پیامک
        if (data['smsTemplates'] is List) {
          for (final s in data['smsTemplates']) {
            await db.into(db.smsTemplates).insert(SmsTemplatesCompanion.insert(
              id: Value(s['id']),
              bankId: s['bankId'],
              patternName: s['patternName'],
              regex: s['regex'],
              amountGroupIndex: Value(s['amountGroupIndex'] ?? 1),
              balanceGroupIndex: Value(s['balanceGroupIndex']),
              withdrawKeyword: Value(s['withdrawKeyword'] ?? 'برداشت'),
              depositKeyword: Value(s['depositKeyword'] ?? 'واریز'),
            ));
          }
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
