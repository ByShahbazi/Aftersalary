import 'package:aftersalary/core/constants/app_icons.dart';
import 'package:aftersalary/core/database/app_database.dart';
import 'package:aftersalary/core/database/database_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:aftersalary/core/services/free_balance_service.dart';
import 'package:aftersalary/core/services/sms_parser_service.dart';
import 'package:aftersalary/core/utils/currency_formatter.dart';
import 'package:aftersalary/core/utils/jalali_helper.dart';
import 'package:aftersalary/core/widgets/currency_input_field.dart';
import 'package:aftersalary/features/accounts/accounts_screen.dart';
import 'package:aftersalary/features/settings/settings_screen.dart';
import 'package:aftersalary/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shamsi_date/shamsi_date.dart';

void main() {
  group('CurrencyFormatter Tests', () {
    test('converts English digits to Persian and vice versa', () {
      expect(CurrencyFormatter.toPersianDigits('1234567890'), '۱۲۳۴۵۶۷۸۹۰');
      expect(CurrencyFormatter.toEnglishDigits('۱۲۳۴۵۶۷۸۹۰'), '1234567890');
    });

    test('parses clean amount from formatted string', () {
      expect(CurrencyFormatter.parseCleanAmount('۱,۵۰۰,۰۰۰ ریال'), 1500000);
      expect(CurrencyFormatter.parseCleanAmount('25,000,000'), 25000000);
    });

    test('converts Rial to Toman correctly', () {
      expect(CurrencyFormatter.rialToToman(10000000), 1000000);
      expect(CurrencyFormatter.tomanToRial(1000000), 10000000);
    });

    test('formats numbers with thousand separators and Persian digits', () {
      expect(CurrencyFormatter.formatNumber(1500000), '۱,۵۰۰,۰۰۰');
      expect(CurrencyFormatter.formatTomanFromRial(15000000), '۱,۵۰۰,۰۰۰ تومان');
    });

    test('converts numbers to Persian words', () {
      expect(CurrencyFormatter.numberToPersianWords(0), 'صفر تومان');
      expect(CurrencyFormatter.numberToPersianWords(50000), 'پنجاه هزار تومان');
      expect(CurrencyFormatter.numberToPersianWords(1250000), 'یک میلیون و دویست و پنجاه هزار تومان');
    });

    testWidgets('CurrencyInputField accepts multiple digits without 1-char limit', (WidgetTester tester) async {
      final controller = TextEditingController();
      int lastValue = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencyInputField(
              controller: controller,
              label: 'موجودی اولیه',
              onAmountChanged: (val) => lastValue = val,
            ),
          ),
        ),
      );

      // Enter 50000000 (50 million rials)
      await tester.enterText(find.byType(TextFormField), '50000000');
      await tester.pumpAndSettle();

      expect(controller.text, '۵۰,۰۰۰,۰۰۰');
      expect(lastValue, 50000000);
      expect(find.textContaining('۵,۰۰۰,۰۰۰ تومان'), findsOneWidget);

      // Now append more digits to test editing (e.g. 500000000)
      await tester.enterText(find.byType(TextFormField), '۵۰,۰۰۰,۰۰۰0');
      await tester.pumpAndSettle();

      expect(controller.text, '۵۰۰,۰۰۰,۰۰۰');
      expect(lastValue, 500000000);
    });
  });

  group('JalaliHelper & Salary Period Tests', () {
    test('calculates correct salary period range for mid-month payday', () {
      // فرض کنیم امروز روز ۱۵ام است و حقوق روز ۵ام ماه واریز می‌شود
      final midMonth = Jalali(1403, 6, 15);
      final range = JalaliHelper.getSalaryPeriodRange(startDayOfMonth: 5, targetDate: midMonth);

      expect(range.start.year, 1403);
      expect(range.start.month, 6);
      expect(range.start.day, 5);

      expect(range.end.year, 1403);
      expect(range.end.month, 7);
      expect(range.end.day, 4);
    });

    test('calculates correct salary period range for days before payday', () {
      // فرض کنیم امروز روز ۲ام است و حقوق روز ۵ام ماه واریز می‌شود
      final earlyMonth = Jalali(1403, 6, 2);
      final range = JalaliHelper.getSalaryPeriodRange(startDayOfMonth: 5, targetDate: earlyMonth);

      expect(range.start.year, 1403);
      expect(range.start.month, 5);
      expect(range.start.day, 5);

      expect(range.end.year, 1403);
      expect(range.end.month, 6);
      expect(range.end.day, 4);
    });

    test('calculates correct salary period range for 1st of month payday (full calendar month)', () {
      final midMonth = Jalali(1403, 6, 15);
      final range = JalaliHelper.getSalaryPeriodRange(startDayOfMonth: 1, targetDate: midMonth);

      expect(range.start.year, 1403);
      expect(range.start.month, 6);
      expect(range.start.day, 1);

      expect(range.end.year, 1403);
      expect(range.end.month, 6);
      expect(range.end.day, 31);
      expect(range.label, 'از ۱۴۰۳/۰۶/۰۱ تا ۱۴۰۳/۰۶/۳۱');
    });
  });

  group('FreeBalanceService Core Calculation Tests', () {
    test('calculates free balance accurately by deducting period commitments', () {
      final accounts = [
        const Account(
          id: 1,
          bankId: 1,
          title: 'حساب جاری ۱',
          accountNumber: '1111',
          currentBalanceRial: 100000000, // ۱۰ میلیون تومان
          includeInFreeBalance: true,
        ),
        const Account(
          id: 2,
          bankId: 2,
          title: 'حساب جاری ۲',
          accountNumber: '2222',
          currentBalanceRial: 50000000, // ۵ میلیون تومان
          includeInFreeBalance: true,
        ),
      ];

      // کل موجودی: ۱۵ میلیون تومان (۱۵۰ میلیون ریال)

      final now = DateTime.now();
      final payments = [
        PlannedPayment(
          id: 1,
          accountId: 1,
          title: 'قسط وام',
          amountRial: 30000000, // ۳ میلیون تومان
          dueDate: now.add(const Duration(days: 3)),
          status: 'pending',
          isRecurring: false,
        ),
        PlannedPayment(
          id: 2,
          accountId: 2,
          title: 'اجاره خانه',
          amountRial: 50000000, // ۵ میلیون تومان
          dueDate: now.add(const Duration(days: 7)),
          status: 'pending',
          isRecurring: false,
        ),
        PlannedPayment(
          id: 3,
          accountId: 1,
          title: 'قبض تسویه شده قبلی',
          amountRial: 2000000, // نباید کسر شود چون paid است
          dueDate: now.subtract(const Duration(days: 2)),
          status: 'paid',
          isRecurring: false,
        ),
      ];

      const period = SalaryPeriod(id: 1, startDayOfMonth: 1, isActive: true);

      final summary = FreeBalanceService.calculate(
        accounts: accounts,
        plannedPayments: payments,
        activePeriod: period,
      );

      // کل موجودی: ۱۵۰,۰۰۰,۰۰۰ ریال
      expect(summary.totalBalanceRial, 150000000);
      // مجموع تعهدات معلق این دوره: ۳۰,۰۰۰,۰۰۰ + ۵۰,۰۰۰,۰۰۰ = ۸۰,۰۰۰,۰۰۰ ریال
      expect(summary.totalCommitmentsRial, 80000000);
      // موجودی آزاد واقعی: ۱۵۰,۰۰۰,۰۰۰ - ۸۰,۰۰۰,۰۰۰ = ۷۰,۰۰۰,۰۰۰ ریال (۷ میلیون تومان)
      expect(summary.freeBalanceRial, 70000000);
      expect(summary.status, FreeBalanceStatus.safe);
      expect(summary.pendingCommitmentsCount, 2);
    });

    test('detects danger status when commitments exceed total balance', () {
      final accounts = [
        const Account(
          id: 1,
          bankId: 1,
          title: 'حساب',
          accountNumber: '111',
          currentBalanceRial: 20000000, // ۲ میلیون تومان
          includeInFreeBalance: true,
        ),
      ];

      final payments = [
        PlannedPayment(
          id: 1,
          accountId: 1,
          title: 'چک سنگین',
          amountRial: 50000000, // ۵ میلیون تومان
          dueDate: DateTime.now().add(const Duration(days: 2)),
          status: 'pending',
          isRecurring: false,
        ),
      ];

      const period = SalaryPeriod(id: 1, startDayOfMonth: 1, isActive: true);

      final summary = FreeBalanceService.calculate(
        accounts: accounts,
        plannedPayments: payments,
        activePeriod: period,
      );

      expect(summary.freeBalanceRial, -30000000);
      expect(summary.status, FreeBalanceStatus.danger);
    });
  });

  group('SmsParserService Tests', () {
    test('correctly parses BluBank format SMS', () {
      const sample = 'برداشت مبلغ 1,500,000 ریال از حساب شما ... مانده: 10,000,000 ریال';
      final templates = [
        const SmsTemplate(
          id: 1,
          bankId: 2,
          patternName: 'بلو بانک استاندارد',
          regex: r'(واریز|برداشت)\s*(?:مبلغ)?\s*([0-9,]+)\s*ریال(?:.*?مانده:?\s*([0-9,]+)\s*ریال)?',
          amountGroupIndex: 2,
          balanceGroupIndex: 3,
          withdrawKeyword: 'برداشت',
          depositKeyword: 'واریز',
        ),
      ];
      final banks = [
        const Bank(id: 2, name: 'بلو بانک', colorHex: '#2979FF', iconName: 'credit_card'),
      ];

      final result = SmsParserService.parse(
        rawText: sample,
        templates: templates,
        banks: banks,
      );

      expect(result.isMatched, true);
      expect(result.amountRial, 1500000);
      expect(result.type, 'withdraw');
      expect(result.remainingBalanceRial, 10000000);
    });

    test('correctly parses Bank Resalat withdraw and deposit SMS', () {
      final banks = [
        const Bank(id: 10, name: 'بانک قرض‌الحسنه رسالت', colorHex: '#2E7D32', iconName: 'account_balance'),
      ];

      // نمونه یک رسالت (برداشت)
      const resalatSample1 = '10.13580900.1\n-1,630,000 \n06/07_17:04\nمانده: 2,916,248';
      final res1 = SmsParserService.parse(rawText: resalatSample1, templates: [], banks: banks);
      expect(res1.isMatched, true);
      expect(res1.amountRial, 1630000);
      expect(res1.type, 'withdraw');
      expect(res1.remainingBalanceRial, 2916248);
      expect(res1.accountNumber, '10.13580900.1');

      // نمونه دو رسالت (واریز)
      const resalatSample2 = '10.13580900.1\n+587,284,399 \n06/15_09:56\nمانده: 591,500,647';
      final res2 = SmsParserService.parse(rawText: resalatSample2, templates: [], banks: banks);
      expect(res2.isMatched, true);
      expect(res2.amountRial, 587284399);
      expect(res2.type, 'deposit');
      expect(res2.remainingBalanceRial, 591500647);
      expect(res2.accountNumber, '10.13580900.1');
    });

    test('correctly parses Bank Melli transfer and internet purchase SMS', () {
      final banks = [
        const Bank(id: 3, name: 'بانک ملی', colorHex: '#1565C0', iconName: 'account_balance'),
      ];

      // نمونه یک بانک ملی (انتقال / واریز با علامت + در انتها)
      const melliSample1 = 'بانك ملي ايران\nانتقال:8,250,000+\nحساب:77003\nمانده:11,038,317\n0609-19:54';
      final res1 = SmsParserService.parse(rawText: melliSample1, templates: [], banks: banks);
      expect(res1.isMatched, true);
      expect(res1.amountRial, 8250000);
      expect(res1.type, 'deposit');
      expect(res1.remainingBalanceRial, 11038317);
      expect(res1.accountNumber, '77003');
      expect(res1.description, 'انتقال');

      // نمونه دو بانک ملی (خرید اینترنتی / برداشت با علامت - در انتها)
      const melliSample2 = 'بانك ملي ايران\nخريداينترنتي:3,850,000-\nحساب:77003\nمانده:7,188,317\n0614-12:54';
      final res2 = SmsParserService.parse(rawText: melliSample2, templates: [], banks: banks);
      expect(res2.isMatched, true);
      expect(res2.amountRial, 3850000);
      expect(res2.type, 'withdraw');
      expect(res2.remainingBalanceRial, 7188317);
      expect(res2.accountNumber, '77003');
      expect(res2.description, 'خریداینترنتی');
    });

    test('falls back to generic parser if template does not match', () {
      const sample = 'واریز 45,000,000 ریال به حساب بانک ملی';
      final banks = [
        const Bank(id: 3, name: 'بانک ملی', colorHex: '#1565C0', iconName: 'account_balance'),
      ];

      final result = SmsParserService.parse(
        rawText: sample,
        templates: [],
        banks: banks,
      );

      expect(result.isMatched, true);
      expect(result.amountRial, 45000000);
      expect(result.type, 'deposit');
    });
  });

  group('AppIcons Tests', () {
    test('returns correct Material icon for category codes', () {
      expect(AppIcons.getCategoryIcon(0xe532), Icons.restaurant);
      expect(AppIcons.getCategoryIcon(0xe318), Icons.home);
      expect(AppIcons.getCategoryIcon(null), Icons.category_outlined);
    });
  });

  group('Widget & App Smoke Tests', () {
    testWidgets('AftersalaryApp loads with ProviderScope and displays title', (WidgetTester tester) async {
      GoogleFonts.config.allowRuntimeFetching = false;
      final db = AppDatabase(NativeDatabase.memory());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const AftersalaryApp(),
        ),
      );
      await db.close();
    });

    testWidgets('Can navigate through all bottom navigation destinations', (WidgetTester tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const AftersalaryApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'تراکنش‌ها'
      await tester.tap(find.text('تراکنش‌ها'));
      await tester.pumpAndSettle();
      expect(find.text('تراکنش جدید'), findsOneWidget);

      // Tap 'تعهدات'
      await tester.tap(find.text('تعهدات'));
      await tester.pumpAndSettle();
      expect(find.text('تعهد جدید'), findsOneWidget);

      // Tap 'گزارش‌ها'
      await tester.tap(find.text('گزارش‌ها'));
      await tester.pumpAndSettle();
      expect(find.text('گزارش و تحلیل مالی'), findsOneWidget);

      // Tap 'تنظیمات'
      await tester.tap(find.text('تنظیمات'));
      await tester.pumpAndSettle();
      expect(find.text('تنظیمات برنامه'), findsOneWidget);

      await db.close();
    });
  });

  group('Transaction & Account Impact Tests', () {
    test('recording and deleting transactions updates and reverses account balance', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final bankId = await db.addBank(BanksCompanion.insert(name: 'تست بانک', colorHex: '#123456'));
      final accId = await db.addAccount(AccountsCompanion.insert(
        bankId: bankId,
        title: 'حساب جاری تست',
        currentBalanceRial: const drift.Value(10000000), // 1 million toman
      ));

      // 1. Record withdrawal of 2,000,000 rials
      await db.recordTransaction(
        accountId: accId,
        amountRial: 2000000,
        type: 'withdraw',
        occurredAt: DateTime.now(),
      );

      var acc = await db.getAccountById(accId);
      expect(acc!.currentBalanceRial, 8000000); // 800,000 toman

      // 2. Record deposit of 5,000,000 rials
      await db.recordTransaction(
        accountId: accId,
        amountRial: 5000000,
        type: 'deposit',
        occurredAt: DateTime.now(),
      );

      acc = await db.getAccountById(accId);
      expect(acc!.currentBalanceRial, 13000000); // 1,300,000 toman

      // 3. Delete deposit transaction and verify balance reverts
      final txs = await db.getTransactions();
      final depositTx = txs.firstWhere((t) => t.type == 'deposit');
      await db.deleteTransaction(depositTx.id);

      acc = await db.getAccountById(accId);
      expect(acc!.currentBalanceRial, 8000000); // Reverted back to 8,000,000

      // 4. Verify that FreeBalanceService directly reflects this balance
      final summary = FreeBalanceService.calculate(
        accounts: [acc],
        plannedPayments: [],
        activePeriod: const SalaryPeriod(id: 1, startDayOfMonth: 1, isActive: true),
      );
      expect(summary.totalBalanceRial, 8000000);
      expect(summary.freeBalanceRial, 8000000);

      await db.close();
    });

    test('adding account with new custom bank name dynamically creates the bank', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final initialBanks = await db.getAllBanks();
      expect(initialBanks.any((b) => b.name == 'بانک آینده مهر'), isFalse);

      final bankId = await db.addBank(BanksCompanion.insert(
        name: 'بانک آینده مهر',
        colorHex: '#1E56A0',
      ));
      final accId = await db.addAccount(AccountsCompanion.insert(
        bankId: bankId,
        title: 'حساب پس‌انداز',
        currentBalanceRial: const drift.Value(25000000),
      ));

      final acc = await db.getAccountById(accId);
      expect(acc!.title, 'حساب پس‌انداز');
      expect(acc.currentBalanceRial, 25000000);

      final banksAfter = await db.getAllBanks();
      expect(banksAfter.any((b) => b.name == 'بانک آینده مهر'), isTrue);

      await db.close();
    });

    test('distinguishes multiple cards of the same bank using ownerName and updates details', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final banks = await db.getAllBanks();
      final samanBank = banks.firstWhere((b) => b.name.contains('سامان'));

      // Card 1: Personal card for Ali
      final card1Id = await db.addAccount(AccountsCompanion.insert(
        bankId: samanBank.id,
        title: 'کارت شخصی',
        accountNumber: const drift.Value('6219-8610-1111-2222'),
        ownerName: const drift.Value('علی'),
        currentBalanceRial: const drift.Value(10000000),
      ));

      // Card 2: Spouse card from same bank
      final card2Id = await db.addAccount(AccountsCompanion.insert(
        bankId: samanBank.id,
        title: 'کارت خرید منزل',
        accountNumber: const drift.Value('6219-8610-3333-4444'),
        ownerName: const drift.Value('همسر'),
        currentBalanceRial: const drift.Value(5000000),
      ));

      final acc1 = await db.getAccountById(card1Id);
      final acc2 = await db.getAccountById(card2Id);

      expect(acc1!.ownerName, 'علی');
      expect(acc2!.ownerName, 'همسر');
      expect(acc1.bankId, acc2.bankId);

      // Update card 1 owner name and title
      await db.updateAccount(acc1.copyWith(
        title: 'کارت حقوق و پس‌انداز',
        ownerName: const drift.Value('علی شهبازی'),
      ));

      final updatedAcc1 = await db.getAccountById(card1Id);
      expect(updatedAcc1!.title, 'کارت حقوق و پس‌انداز');
      expect(updatedAcc1.ownerName, 'علی شهبازی');

      await db.close();
    });

    test('editTransaction correctly reverses old balance and applies new balance', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final banks = await db.getAllBanks();

      // Create two accounts with 10,000,000 Rials each
      final acc1Id = await db.addAccount(AccountsCompanion.insert(
        bankId: banks[0].id,
        title: 'حساب اول',
        currentBalanceRial: const drift.Value(10000000),
      ));
      final acc2Id = await db.addAccount(AccountsCompanion.insert(
        bankId: banks[1].id,
        title: 'حساب دوم',
        currentBalanceRial: const drift.Value(10000000),
      ));

      // Record a withdraw of 3,000,000 on Account 1
      final txId = await db.recordTransaction(
        accountId: acc1Id,
        amountRial: 3000000,
        type: 'withdraw',
        occurredAt: DateTime.now(),
        description: 'خرید اشتباه',
      );

      var a1 = await db.getAccountById(acc1Id);
      expect(a1!.currentBalanceRial, 7000000);

      // Edit transaction: change amount to 1,000,000 on Account 1 (fixing a mistaken amount)
      await db.editTransaction(
        transactionId: txId,
        newAccountId: acc1Id,
        newAmountRial: 1000000,
        newType: 'withdraw',
        newOccurredAt: DateTime.now(),
        newDescription: 'مبلغ اصلاح شد به ۱۰۰ هزار تومان',
      );

      a1 = await db.getAccountById(acc1Id);
      expect(a1!.currentBalanceRial, 9000000); // 10,000,000 - 1,000,000

      // Edit transaction: switch account to Account 2 and make it deposit
      await db.editTransaction(
        transactionId: txId,
        newAccountId: acc2Id,
        newAmountRial: 5000000,
        newType: 'deposit',
        newOccurredAt: DateTime.now(),
        newDescription: 'انتقال به حساب دوم و واریز',
      );

      a1 = await db.getAccountById(acc1Id);
      var a2 = await db.getAccountById(acc2Id);
      // Account 1: withdraw of 1,000,000 was reversed -> back to 10,000,000
      expect(a1!.currentBalanceRial, 10000000);
      // Account 2: received 5,000,000 deposit -> 15,000,000
      expect(a2!.currentBalanceRial, 15000000);

      await db.close();
    });

    test('excludes card balance from free balance calculation when includeInFreeBalance is false', () {
      final accounts = [
        const Account(
          id: 1,
          bankId: 1,
          title: 'کارت روزمره',
          accountNumber: '1111',
          currentBalanceRial: 10000000, // ۱ میلیون تومان
          includeInFreeBalance: true,
        ),
        const Account(
          id: 2,
          bankId: 1,
          title: 'کارت پس‌انداز مسکن',
          accountNumber: '2222',
          currentBalanceRial: 50000000, // ۵ میلیون تومان پس‌انداز
          includeInFreeBalance: false, // مستثنی شده از موجودی آزاد
        ),
      ];

      final summary = FreeBalanceService.calculate(
        accounts: accounts,
        plannedPayments: [],
        activePeriod: const SalaryPeriod(id: 1, startDayOfMonth: 1, isActive: true),
      );

      // موجودی حساب‌های آزاد فقط ۱ میلیون تومان است
      expect(summary.totalBalanceRial, 10000000);
      expect(summary.freeBalanceRial, 10000000);
      // مجموع کل دارایی‌ها با احتساب پس‌انداز ۶ میلیون تومان است
      expect(summary.grossBalanceRial, 60000000);
    });

    test('immediately deducts all pending commitments from free balance', () {
      final accounts = [
        const Account(
          id: 1,
          bankId: 1,
          title: 'حساب جاری',
          accountNumber: '1111',
          currentBalanceRial: 20000000, // ۲ میلیون تومان
          includeInFreeBalance: true,
        ),
      ];

      // تعهد با تاریخ دور دست (مثلا دو ماه دیگر)
      final farFuturePayment = PlannedPayment(
        id: 1,
        accountId: 1,
        title: 'چک بلندمدت',
        amountRial: 8000000, // ۸۰۰ هزار تومان
        dueDate: DateTime.now().add(const Duration(days: 60)),
        status: 'pending',
        isRecurring: false,
      );

      final summary = FreeBalanceService.calculate(
        accounts: accounts,
        plannedPayments: [farFuturePayment],
        activePeriod: const SalaryPeriod(id: 1, startDayOfMonth: 1, isActive: true),
      );

      // بلافاصله از موجودی آزاد کسر می‌شود
      expect(summary.totalCommitmentsRial, 8000000);
      expect(summary.freeBalanceRial, 12000000); // 20,000,000 - 8,000,000
    });

    test('resetAllData clears all user accounts, transactions, and planned payments', () async {
      final db = AppDatabase(NativeDatabase.memory());

      final bank = (await db.getAllBanks()).first;
      final accId = await db.addAccount(AccountsCompanion.insert(
        bankId: bank.id,
        title: 'حساب موقت',
        currentBalanceRial: const drift.Value(10000000),
      ));

      await db.recordTransaction(
        accountId: accId,
        amountRial: 2000000,
        type: 'withdraw',
        occurredAt: DateTime.now(),
      );

      await db.addPlannedPayment(PlannedPaymentsCompanion.insert(
        accountId: accId,
        title: 'قسط موقت',
        amountRial: 3000000,
        dueDate: DateTime.now().add(const Duration(days: 3)),
      ));

      // بررسی قبل از ریست
      expect((await db.getAllAccounts()).isNotEmpty, isTrue);
      expect((await db.getTransactions()).isNotEmpty, isTrue);
      expect((await db.getPlannedPayments()).isNotEmpty, isTrue);

      // ریست کامل
      await db.resetAllData();

      // بررسی پس از ریست
      expect((await db.getAllAccounts()).isEmpty, isTrue);
      expect((await db.getTransactions()).isEmpty, isTrue);
      expect((await db.getPlannedPayments()).isEmpty, isTrue);

      await db.close();
    });

    test('editing commitment updates title, amount, due date, and assigned card', () async {
      final db = AppDatabase(NativeDatabase.memory());

      final bank = (await db.getAllBanks()).first;
      final acc1 = await db.addAccount(AccountsCompanion.insert(
        bankId: bank.id,
        title: 'کارت یک',
        currentBalanceRial: const drift.Value(50000000),
      ));
      final acc2 = await db.addAccount(AccountsCompanion.insert(
        bankId: bank.id,
        title: 'کارت دو',
        currentBalanceRial: const drift.Value(30000000),
      ));

      final initialDue = DateTime.now().add(const Duration(days: 5));
      final pId = await db.addPlannedPayment(PlannedPaymentsCompanion.insert(
        accountId: acc1,
        title: 'قسط خودرو',
        amountRial: 10000000,
        dueDate: initialDue,
      ));

      final payment = (await db.getPlannedPayments()).firstWhere((p) => p.id == pId);
      expect(payment.amountRial, 10000000);
      expect(payment.accountId, acc1);

      // ویرایش تعهد: تغییر به کارت دو، افزایش مبلغ، و تغییر تاریخ
      final newDue = DateTime.now().add(const Duration(days: 10));
      final updated = payment.copyWith(
        title: 'قسط خودرو ویرایش شده',
        amountRial: 12000000,
        accountId: acc2,
        dueDate: newDue,
      );
      final updateSuccess = await db.updatePlannedPayment(updated);
      expect(updateSuccess, isTrue);

      final reloaded = (await db.getPlannedPayments()).firstWhere((p) => p.id == pId);
      expect(reloaded.title, 'قسط خودرو ویرایش شده');
      expect(reloaded.amountRial, 12000000);
      expect(reloaded.accountId, acc2);
      expect(reloaded.dueDate.day, newDue.day);

      await db.close();
    });

    test('settling commitment (markPlannedPaymentAsPaid) records withdraw tx and deducts account balance', () async {
      final db = AppDatabase(NativeDatabase.memory());

      final bank = (await db.getAllBanks()).first;
      final accId = await db.addAccount(AccountsCompanion.insert(
        bankId: bank.id,
        title: 'کارت پرداخت',
        currentBalanceRial: const drift.Value(50000000), // ۵۰ میلیون ریال
      ));

      final pId = await db.addPlannedPayment(PlannedPaymentsCompanion.insert(
        accountId: accId,
        title: 'اجاره مسکن',
        amountRial: 15000000, // ۱۵ میلیون ریال
        dueDate: DateTime.now(),
      ));

      final payment = (await db.getPlannedPayments()).firstWhere((p) => p.id == pId);
      expect(payment.status, 'pending');

      // تسویه تعهد
      await db.markPlannedPaymentAsPaid(payment);

      // بررسی وضعیت تعهد
      final settledPayment = (await db.getPlannedPayments()).firstWhere((p) => p.id == pId);
      expect(settledPayment.status, 'paid');

      // بررسی مانده حساب (باید ۱۵ میلیون کسر شده باشد => ۳۵ میلیون ریال)
      final account = await db.getAccountById(accId);
      expect(account!.currentBalanceRial, 35000000);

      // بررسی تراکنش ثبت شده
      final txs = await db.getTransactions();
      expect(txs.length, 1);
      expect(txs.first.type, 'withdraw');
      expect(txs.first.amountRial, 15000000);
      expect(txs.first.description, contains('تسویه تعهد: اجاره مسکن'));

      await db.close();
    });

    testWidgets('SettingsScreen displays Mohammad Mahdi Shahbazi developer profile and about card', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final devHeaderFinder = find.text('درباره توسعه‌دهنده');
      await tester.scrollUntilVisible(devHeaderFinder, 500);
      await tester.pumpAndSettle();

      expect(devHeaderFinder, findsOneWidget);
      expect(find.text('محمد مهدی شهبازی'), findsOneWidget);
      expect(find.text('مهندسی نرم‌افزار و مهندس تضمین کیفیت نرم‌افزار'), findsOneWidget);
      expect(find.text('mmshahbazi85@gmail.com'), findsOneWidget);
      expect(find.text('@ByShahbazi'), findsOneWidget);
      expect(find.text('mmshahbazi'), findsOneWidget);

      await db.close();
    });

    testWidgets('AccountsScreen displays bank, cardholder name, balance, and free balance status in 4 lines', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final bank = await db.getOrCreateBankByName('بلو بانک', '#1E56A0');
      await db.addAccount(AccountsCompanion.insert(
        bankId: bank.id,
        title: 'حساب روزمره',
        ownerName: const drift.Value('محمد شهبازی'),
        accountNumber: const drift.Value('6219861012345678'),
        currentBalanceRial: const drift.Value(25000000),
        includeInFreeBalance: const drift.Value(true),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: AccountsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('بانک صادر کننده: '), findsOneWidget);
      expect(find.text('بلو بانک'), findsOneWidget);
      expect(find.text('نام دارنده کارت: '), findsOneWidget);
      expect(find.text('محمد شهبازی'), findsOneWidget);
      expect(find.text('موجودی: '), findsOneWidget);
      expect(find.text('۲,۵۰۰,۰۰۰ تومان'), findsOneWidget);
      expect(find.text('مشمول آزاد: '), findsOneWidget);
      expect(find.text('مشمول در موجودی آزاد'), findsOneWidget);

      await db.close();
    });

    testWidgets('SettingsScreen export modal shows guide and copy button without raw preview container', (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final exportTile = find.text('خروجی گرفتن از تمام اطلاعات (Export JSON)');
      await tester.scrollUntilVisible(exportTile, 500);
      await tester.pumpAndSettle();
      await tester.tap(exportTile);
      await tester.pumpAndSettle();

      expect(find.text('خروجی گرفتن از تمام اطلاعات'), findsOneWidget);
      expect(find.text('راهنمای استفاده و نگهداری:'), findsOneWidget);
      expect(find.text('کپی کردن اطلاعات'), findsOneWidget);
      expect(find.byType(SelectableText), findsNothing);

      await db.close();
    });
  });
}
