import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// -------------------------------------------------------------
// TABLES
// -------------------------------------------------------------

class Banks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get colorHex => text()();
  TextColumn get iconName => text().withDefault(const Constant('account_balance'))();
  TextColumn get smsSenderNumber => text().nullable()();
}

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bankId => integer().references(Banks, #id, onDelete: KeyAction.cascade)();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get ownerName => text().nullable()(); // نام مالک یا دارنده کارت برای تفکیک چند کارت از یک بانک
  TextColumn get accountNumber => text().nullable()();
  IntColumn get currentBalanceRial => integer().withDefault(const Constant(0))();
  BoolColumn get includeInFreeBalance => boolean().withDefault(const Constant(true))(); // آیا در دارایی‌های آزاد محاسبه شود؟
}

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get iconCode => integer()();
  TextColumn get colorHex => text()();
  TextColumn get type => text()(); // 'expense' or 'income'
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}

class PlannedPayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  TextColumn get title => text().withLength(min: 1, max: 100)();
  IntColumn get amountRial => integer()();
  DateTimeColumn get dueDate => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // 'pending', 'paid', 'canceled'
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get accountId => integer().references(Accounts, #id, onDelete: KeyAction.cascade)();
  IntColumn get categoryId => integer().nullable().references(Categories, #id, onDelete: KeyAction.setNull)();
  IntColumn get amountRial => integer()();
  TextColumn get type => text()(); // 'withdraw' or 'deposit'
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get rawSmsText => text().nullable()();
  BoolColumn get isCategorized => boolean().withDefault(const Constant(false))();
  TextColumn get description => text().nullable()();
}

class SalaryPeriods extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get startDayOfMonth => integer().withDefault(const Constant(1))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class SmsTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bankId => integer().references(Banks, #id, onDelete: KeyAction.cascade)();
  TextColumn get patternName => text()();
  TextColumn get regex => text()();
  IntColumn get amountGroupIndex => integer().withDefault(const Constant(1))();
  IntColumn get balanceGroupIndex => integer().nullable()();
  TextColumn get withdrawKeyword => text().withDefault(const Constant('برداشت'))();
  TextColumn get depositKeyword => text().withDefault(const Constant('واریز'))();
}

// -------------------------------------------------------------
// DATABASE CLASS
// -------------------------------------------------------------

@DriftDatabase(tables: [
  Banks,
  Accounts,
  Categories,
  PlannedPayments,
  Transactions,
  SalaryPeriods,
  SmsTemplates,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 3;

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'aftersalary_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedInitialData();
        await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_account ON transactions(account_id);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_date ON transactions(occurred_at DESC);');
        await customStatement('CREATE INDEX IF NOT EXISTS idx_planned_due ON planned_payments(due_date ASC);');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(accounts, accounts.ownerName);
          await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_account ON transactions(account_id);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_tx_date ON transactions(occurred_at DESC);');
          await customStatement('CREATE INDEX IF NOT EXISTS idx_planned_due ON planned_payments(due_date ASC);');
        }
        if (from < 3) {
          await m.addColumn(accounts, accounts.includeInFreeBalance);
        }
      },
    );
  }

  /// بازنشانی کامل داده‌های برنامه به وضعیت خام اولیه
  Future<void> resetAllData() async {
    await transaction(() async {
      await delete(transactions).go();
      await delete(plannedPayments).go();
      await delete(accounts).go();
      // تنظیم مجدد دوره حقوقی به حالت پیش‌فرض
      await delete(salaryPeriods).go();
      await into(salaryPeriods).insert(SalaryPeriodsCompanion.insert(
        startDayOfMonth: const Value(1),
        isActive: const Value(true),
      ));
    });
  }

  Future<void> _seedInitialData() async {
    // ۱. ایجاد بانک‌های پیش‌فرض
    final bankMellat = await into(banks).insert(BanksCompanion.insert(
      name: 'بانک ملت',
      colorHex: '#C62828',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    final bankBlue = await into(banks).insert(BanksCompanion.insert(
      name: 'بلو بانک',
      colorHex: '#2979FF',
      iconName: const Value('credit_card'),
      smsSenderNumber: const Value('blubank'),
    ));

    final bankMelli = await into(banks).insert(BanksCompanion.insert(
      name: 'بانک ملی',
      colorHex: '#1565C0',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک تجارت',
      colorHex: '#00838F',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک سامان',
      colorHex: '#0097A7',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک پاسارگاد',
      colorHex: '#F57F17',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک قرض‌الحسنه رسالت',
      colorHex: '#2E7D32',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک سپه',
      colorHex: '#C62828',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک صادرات',
      colorHex: '#1E56A0',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک مسکن',
      colorHex: '#E65100',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک پارسیان',
      colorHex: '#AD1457',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک کشاورزی',
      colorHex: '#388E3C',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک رفاه کارگران',
      colorHex: '#00838F',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک قرض‌الحسنه مهر ایران',
      colorHex: '#2E7D32',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    await into(banks).insert(BanksCompanion.insert(
      name: 'بانک آینده',
      colorHex: '#6A1B9A',
      iconName: const Value('account_balance'),
      smsSenderNumber: const Value('200000'),
    ));

    // ۲. ایجاد دسته‌بندی‌های پیش‌فرض
    final defaultCategories = [
      // هزینه‌ها
      CategoriesCompanion.insert(
        title: 'خوراک و سوپرمارکت',
        iconCode: 0xe532, // Icons.restaurant
        colorHex: '#FF7043',
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'مسکن و اجاره',
        iconCode: 0xe318, // Icons.home
        colorHex: '#5C6BC0',
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'حمل‌ونقل و بنزین',
        iconCode: 0xe1d5, // Icons.directions_car
        colorHex: '#26A69A',
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'قسط و وام',
        iconCode: 0xef49, // Icons.account_balance
        colorHex: '#EC407A',
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'قبوض و خدمات',
        iconCode: 0xef64, // Icons.receipt_long
        colorHex: '#AB47BC',
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'سلامت و درمان',
        iconCode: 0xe3eb, // Icons.local_hospital
        colorHex: '#EF5350',
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'پوشاک و خرید',
        iconCode: 0xf37d, // Icons.shopping_bag
        colorHex: '#FFA726',
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'کافه و تفریح',
        iconCode: 0xe3b1, // Icons.local_cafe
        colorHex: '#8D6E63',
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'آموزش',
        iconCode: 0xe548, // Icons.school
        colorHex: '#42A5F5',
        type: 'expense',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'سایر هزینه‌ها',
        iconCode: 0xe3ae, // Icons.more_horiz
        colorHex: '#78909C',
        type: 'expense',
        isDefault: const Value(true),
      ),
      // درآمدها
      CategoriesCompanion.insert(
        title: 'حقوق و دستمزد',
        iconCode: 0xe481, // Icons.payments
        colorHex: '#66BB6A',
        type: 'income',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'پاداش و اضافه‌کار',
        iconCode: 0xe6e8, // Icons.card_giftcard
        colorHex: '#26C6DA',
        type: 'income',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'سود بانکی و سرمایه‌گذاری',
        iconCode: 0xe627, // Icons.trending_up
        colorHex: '#2E7D32',
        type: 'income',
        isDefault: const Value(true),
      ),
      CategoriesCompanion.insert(
        title: 'سایر درآمدها',
        iconCode: 0xe047, // Icons.add_circle
        colorHex: '#9E9D24',
        type: 'income',
        isDefault: const Value(true),
      ),
    ];

    for (final cat in defaultCategories) {
      await into(categories).insert(cat);
    }

    // ۳. دوره حقوقی پیش‌فرض (روز اول هر ماه شمسی)
    await into(salaryPeriods).insert(SalaryPeriodsCompanion.insert(
      startDayOfMonth: const Value(1),
      isActive: const Value(true),
    ));

    // ۴. الگوهای پیامک پیش‌فرض بانک‌ها
    // الگوی بلو بانک: مثلاً "برداشت مبلغ 1,500,000 ریال از حساب شما ... مانده: 10,000,000 ریال"
    await into(smsTemplates).insert(SmsTemplatesCompanion.insert(
      bankId: bankBlue,
      patternName: 'بلو بانک استاندارد',
      regex: r'(واریز|برداشت)\s*(?:مبلغ)?\s*([0-9,]+)\s*ریال(?:.*?مانده:?\s*([0-9,]+)\s*ریال)?',
      amountGroupIndex: const Value(2),
      balanceGroupIndex: const Value(3),
      withdrawKeyword: const Value('برداشت'),
      depositKeyword: const Value('واریز'),
    ));

    // الگوی بانک ملت: "بانک ملت\nبرداشت: 500,000 ریال\nمانده: 2,500,000"
    await into(smsTemplates).insert(SmsTemplatesCompanion.insert(
      bankId: bankMellat,
      patternName: 'بانک ملت استاندارد',
      regex: r'(واریز|برداشت)(?:\s*به|\s*از)?(?:\s*حساب)?[:\s]+([0-9,]+)\s*(?:ریال)?(?:.*?مانده[:\s]+([0-9,]+))?',
      amountGroupIndex: const Value(2),
      balanceGroupIndex: const Value(3),
      withdrawKeyword: const Value('برداشت'),
      depositKeyword: const Value('واریز'),
    ));

    // الگوی عمومی برای سایر بانک‌ها
    await into(smsTemplates).insert(SmsTemplatesCompanion.insert(
      bankId: bankMelli,
      patternName: 'الگوی عمومی بانکی',
      regex: r'(واریز|برداشت)\s*([0-9,]+)\s*ریال',
      amountGroupIndex: const Value(2),
      withdrawKeyword: const Value('برداشت'),
      depositKeyword: const Value('واریز'),
    ));

    // ۵. یک حساب اولیه تستی برای کاربر
    await into(accounts).insert(AccountsCompanion.insert(
      bankId: bankBlue,
      title: 'حساب جاری بلو',
      accountNumber: const Value('6219-8610-****-1234'),
      currentBalanceRial: const Value(50000000), // ۵ میلیون تومان پیش‌فرض
    ));
  }

  // -----------------------------------------------------------
  // HELPER REPOSITORY & QUERY METHODS
  // -----------------------------------------------------------

  // بانک‌ها
  Stream<List<Bank>> watchAllBanks() => select(banks).watch();
  Future<List<Bank>> getAllBanks() => select(banks).get();
  Future<Bank?> getBankById(int id) => (select(banks)..where((b) => b.id.equals(id))).getSingleOrNull();
  Future<int> addBank(BanksCompanion bank) => into(banks).insert(bank);
  Future<bool> updateBank(Bank bank) => update(banks).replace(bank);
  Future<int> deleteBank(int id) => (delete(banks)..where((b) => b.id.equals(id))).go();

  // حساب‌ها
  Stream<List<Account>> watchAllAccounts() => select(accounts).watch();
  Future<List<Account>> getAllAccounts() => select(accounts).get();
  Future<Account?> getAccountById(int id) => (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();
  Future<int> addAccount(AccountsCompanion account) => into(accounts).insert(account);
  Future<bool> updateAccount(Account account) => update(accounts).replace(account);
  Future<int> deleteAccount(int id) => (delete(accounts)..where((a) => a.id.equals(id))).go();

  // دسته‌بندی‌ها
  Stream<List<Category>> watchCategories({String? type}) {
    if (type == null) return select(categories).watch();
    return (select(categories)..where((c) => c.type.equals(type))).watch();
  }
  Future<List<Category>> getAllCategories({String? type}) {
    if (type == null) return select(categories).get();
    return (select(categories)..where((c) => c.type.equals(type))).get();
  }
  Future<int> addCategory(CategoriesCompanion category) => into(categories).insert(category);
  Future<bool> updateCategory(Category category) => update(categories).replace(category);
  Future<int> deleteCategory(int id) => (delete(categories)..where((c) => c.id.equals(id))).go();

  // دوره حقوقی
  Stream<SalaryPeriod?> watchActiveSalaryPeriod() {
    return (select(salaryPeriods)..where((s) => s.isActive.equals(true))).watchSingleOrNull();
  }
  Future<SalaryPeriod?> getActiveSalaryPeriod() {
    return (select(salaryPeriods)..where((s) => s.isActive.equals(true))).getSingleOrNull();
  }
  Future<void> updateSalaryPeriodStartDay(int startDay) async {
    final active = await getActiveSalaryPeriod();
    if (active != null) {
      await update(salaryPeriods).replace(active.copyWith(startDayOfMonth: startDay));
    } else {
      await into(salaryPeriods).insert(SalaryPeriodsCompanion.insert(startDayOfMonth: Value(startDay)));
    }
  }

  // تعهدات و پرداخت‌های برنامه‌ریزی‌شده
  Stream<List<PlannedPayment>> watchPlannedPayments({String? status}) {
    if (status == null) {
      return (select(plannedPayments)..orderBy([(p) => OrderingTerm.asc(p.dueDate)])).watch();
    }
    return (select(plannedPayments)
          ..where((p) => p.status.equals(status))
          ..orderBy([(p) => OrderingTerm.asc(p.dueDate)]))
        .watch();
  }

  Future<List<PlannedPayment>> getPlannedPayments() => select(plannedPayments).get();
  Future<int> addPlannedPayment(PlannedPaymentsCompanion payment) => into(plannedPayments).insert(payment);
  Future<bool> updatePlannedPayment(PlannedPayment payment) => update(plannedPayments).replace(payment);
  Future<int> deletePlannedPayment(int id) => (delete(plannedPayments)..where((p) => p.id.equals(id))).go();

  /// تسویه تعهد: ثبت تراکنش برداشت در حساب مربوطه، کسر مانده، و تغییر وضعیت تعهد به 'paid'
  Future<void> markPlannedPaymentAsPaid(PlannedPayment payment) async {
    await transaction(() async {
      // ۱. کسر از حساب و ثبت تراکنش
      await recordTransaction(
        accountId: payment.accountId,
        amountRial: payment.amountRial,
        type: 'withdraw',
        occurredAt: DateTime.now(),
        categoryId: payment.categoryId,
        description: 'تسویه تعهد: ${payment.title}',
        isCategorized: payment.categoryId != null,
      );

      // ۲. بروزرسانی وضعیت تعهد به paid
      await update(plannedPayments).replace(payment.copyWith(status: 'paid'));
    });
  }

  // تراکنش‌ها
  Stream<List<Transaction>> watchTransactions({int? accountId, bool? uncategorizedOnly}) {
    var query = select(transactions);
    if (accountId != null) {
      query = query..where((t) => t.accountId.equals(accountId));
    }
    if (uncategorizedOnly == true) {
      query = query..where((t) => t.isCategorized.equals(false));
    }
    return (query..orderBy([(t) => OrderingTerm.desc(t.occurredAt)])).watch();
  }

  Future<List<Transaction>> getTransactions() => select(transactions).get();

  /// ثبت تراکنش با اعمال اثر مستقیم بر مانده حساب
  Future<int> recordTransaction({
    required int accountId,
    required int amountRial,
    required String type, // 'withdraw' or 'deposit'
    required DateTime occurredAt,
    int? categoryId,
    String? rawSmsText,
    String? description,
    bool isCategorized = false,
  }) async {
    return await transaction(() async {
      final account = await getAccountById(accountId);
      if (account != null) {
        int newBalance = account.currentBalanceRial;
        if (type == 'withdraw') {
          newBalance -= amountRial;
        } else if (type == 'deposit') {
          newBalance += amountRial;
        }
        await update(accounts).replace(account.copyWith(currentBalanceRial: newBalance));
      }

      final id = await into(transactions).insert(TransactionsCompanion.insert(
        accountId: accountId,
        categoryId: Value(categoryId),
        amountRial: amountRial,
        type: type,
        occurredAt: occurredAt,
        rawSmsText: Value(rawSmsText),
        isCategorized: Value(isCategorized),
        description: Value(description),
      ));

      return id;
    });
  }

  Future<bool> updateTransactionCategory(int transactionId, int categoryId) async {
    final tx = await (select(transactions)..where((t) => t.id.equals(transactionId))).getSingleOrNull();
    if (tx == null) return false;
    return await update(transactions).replace(tx.copyWith(
      categoryId: Value(categoryId),
      isCategorized: true,
    ));
  }

  /// ویرایش تراکنش با تعدیل خودکار و دقیق اثر مانده بر حساب‌ها
  Future<bool> editTransaction({
    required int transactionId,
    required int newAccountId,
    required int newAmountRial,
    required String newType, // 'withdraw' or 'deposit'
    required DateTime newOccurredAt,
    int? newCategoryId,
    String? newDescription,
  }) async {
    return await transaction(() async {
      final oldTx = await (select(transactions)..where((t) => t.id.equals(transactionId))).getSingleOrNull();
      if (oldTx == null) return false;

      // ۱. برگشت دادن اثر تراکنش قدیمی بر حساب قدیمی
      final oldAccount = await getAccountById(oldTx.accountId);
      if (oldAccount != null) {
        int restoredBalance = oldAccount.currentBalanceRial;
        if (oldTx.type == 'withdraw') {
          restoredBalance += oldTx.amountRial;
        } else if (oldTx.type == 'deposit') {
          restoredBalance -= oldTx.amountRial;
        }
        await update(accounts).replace(oldAccount.copyWith(currentBalanceRial: restoredBalance));
      }

      // ۲. اعمال اثر تراکنش جدید بر حساب مقصد (حتی اگر همان حساب قبلی باشد)
      final targetAccount = await getAccountById(newAccountId);
      if (targetAccount != null) {
        int updatedBalance = targetAccount.currentBalanceRial;
        if (newType == 'withdraw') {
          updatedBalance -= newAmountRial;
        } else if (newType == 'deposit') {
          updatedBalance += newAmountRial;
        }
        await update(accounts).replace(targetAccount.copyWith(currentBalanceRial: updatedBalance));
      }

      // ۳. ذخیره مشخصات جدید تراکنش
      await update(transactions).replace(oldTx.copyWith(
        accountId: newAccountId,
        amountRial: newAmountRial,
        type: newType,
        occurredAt: newOccurredAt,
        categoryId: Value(newCategoryId),
        description: Value(newDescription),
        isCategorized: newCategoryId != null,
      ));

      return true;
    });
  }

  /// حذف تراکنش با بازگرداندن اثر آن بر مانده حساب
  Future<int> deleteTransaction(int id) async {
    return await transaction(() async {
      final tx = await (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (tx != null) {
        final account = await getAccountById(tx.accountId);
        if (account != null) {
          int newBalance = account.currentBalanceRial;
          if (tx.type == 'withdraw') {
            newBalance += tx.amountRial;
          } else if (tx.type == 'deposit') {
            newBalance -= tx.amountRial;
          }
          await update(accounts).replace(account.copyWith(currentBalanceRial: newBalance));
        }
      }
      return (delete(transactions)..where((t) => t.id.equals(id))).go();
    });
  }

  // قالب‌های پیامک
  Stream<List<SmsTemplate>> watchSmsTemplates() => select(smsTemplates).watch();
  Future<List<SmsTemplate>> getAllSmsTemplates() => select(smsTemplates).get();
  Future<int> addSmsTemplate(SmsTemplatesCompanion template) => into(smsTemplates).insert(template);
  Future<bool> updateSmsTemplate(SmsTemplate template) => update(smsTemplates).replace(template);
  Future<int> deleteSmsTemplate(int id) => (delete(smsTemplates)..where((t) => t.id.equals(id))).go();
}
