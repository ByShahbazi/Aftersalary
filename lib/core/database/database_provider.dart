import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

/// فراهم‌کننده نمونه واحد پایگاه‌داده AppDatabase
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// جریان لیست همه بانک‌ها
final allBanksProvider = StreamProvider<List<Bank>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllBanks();
});

/// جریان لیست حساب‌های کاربر
final allAccountsProvider = StreamProvider<List<Account>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllAccounts();
});

/// جریان دسته‌بندی‌ها
final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCategories();
});

/// جریان دسته‌بندی‌های هزینه
final expenseCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCategories(type: 'expense');
});

/// جریان دسته‌بندی‌های درآمد
final incomeCategoriesProvider = StreamProvider<List<Category>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchCategories(type: 'income');
});

/// جریان تمام تعهدات آینده
final allPlannedPaymentsProvider = StreamProvider<List<PlannedPayment>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchPlannedPayments();
});

/// جریان تعهدات در انتظار (pending)
final pendingPlannedPaymentsProvider = StreamProvider<List<PlannedPayment>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchPlannedPayments(status: 'pending');
});

/// جریان تمام تراکنش‌ها
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTransactions();
});

/// جریان تراکنش‌های نیازمند دسته‌بندی (uncategorized)
final uncategorizedTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTransactions(uncategorizedOnly: true);
});

/// جریان دوره حقوقی فعال
final activeSalaryPeriodProvider = StreamProvider<SalaryPeriod?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchActiveSalaryPeriod();
});

/// جریان الگوهای پیامک
final allSmsTemplatesProvider = StreamProvider<List<SmsTemplate>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSmsTemplates();
});
