import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/services/free_balance_service.dart';
import '../../core/constants/app_icons.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/jalali_helper.dart';
import '../../core/widgets/add_planned_payment_dialog.dart';
import '../../core/widgets/add_transaction_dialog.dart';
import '../../core/widgets/quick_categorize_sheet.dart';
import '../accounts/accounts_screen.dart';
import '../sms_parser/sms_parser_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToTransactions;
  final VoidCallback onNavigateToPlannedPayments;

  const DashboardScreen({
    super.key,
    required this.onNavigateToTransactions,
    required this.onNavigateToPlannedPayments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(freeBalanceSummaryProvider);
    final accountsAsync = ref.watch(allAccountsProvider);
    final banksAsync = ref.watch(allBanksProvider);
    final uncategorizedAsync = ref.watch(uncategorizedTransactionsProvider);
    final plannedPaymentsAsync = ref.watch(pendingPlannedPaymentsProvider);
    final recentTransactionsAsync = ref.watch(allTransactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    // بررسی و فعال‌سازی خودکار اعلان‌های یادآوری موعد پرداخت تعهدات
    plannedPaymentsAsync.whenData((payments) {
      accountsAsync.whenData((accounts) {
        NotificationService().checkAndTriggerDueReminders(
          payments: payments,
          accounts: accounts,
        );
      });
    });

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'Aftersalary | موجودی آزاد',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'امروز: ${JalaliHelper.formatFullDate(Jalali.now())}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sms_outlined),
            tooltip: 'پردازشگر پیامک بانکی',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SmsParserScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allAccountsProvider);
          ref.invalidate(pendingPlannedPaymentsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8, bottom: 84),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ۱. کارت اصلی و ویژه «موجودی آزاد برای خرج کردن»
              _buildFreeBalanceHeroCard(context, summary, isDark),

              // بنر یادآوری تعهداتی که امروز موعد پرداخت دارند یا سررسیدشان گذشته است
              plannedPaymentsAsync.when(
                data: (payments) {
                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);
                  final dueList = payments.where((p) {
                    if (p.status != 'pending') return false;
                    final due = DateTime(p.dueDate.year, p.dueDate.month, p.dueDate.day);
                    return due.difference(today).inDays <= 0;
                  }).toList();
                  if (dueList.isEmpty) return const SizedBox.shrink();
                  final accounts = accountsAsync.asData?.value ?? [];
                  return _buildDueCommitmentBanner(context, ref, dueList, accounts);
                },
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              // ۲. بنر هشدار تراکنش‌های نیازمند دسته‌بندی
              uncategorizedAsync.when(
                data: (txList) {
                  if (txList.isEmpty) return const SizedBox.shrink();
                  return _buildUncategorizedAlertBanner(context, txList.first, txList.length);
                },
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),

              const SizedBox(height: 12),

              // ۳. کارت‌های بانک‌ها و حساب‌ها (افقی)
              _buildAccountsSection(context, accountsAsync, banksAsync),

              const SizedBox(height: 16),

              // ۴. تعهدات و پرداخت‌های پیش‌رو
              _buildUpcomingCommitmentsSection(
                context,
                ref,
                plannedPaymentsAsync,
                categoriesAsync,
                accountsAsync,
              ),

              const SizedBox(height: 16),

              // ۵. آخرین تراکنش‌ها
              _buildRecentTransactionsSection(
                context,
                ref,
                recentTransactionsAsync,
                categoriesAsync,
                accountsAsync,
              ),

              const SizedBox(height: 80), // فاصله برای Floating Action Button
            ],
          ),
        ),
      ),
    );
  }

  /// کارت اصلی موجودی آزاد
  Widget _buildFreeBalanceHeroCard(BuildContext context, FreeBalanceSummary summary, bool isDark) {
    Color gradientStart;
    Color gradientEnd;
    Color statusBadgeColor;
    String statusTitle;
    IconData statusIcon;

    switch (summary.status) {
      case FreeBalanceStatus.safe:
        gradientStart = isDark ? const Color(0xFF004D40) : const Color(0xFF00796B);
        gradientEnd = isDark ? const Color(0xFF00695C) : const Color(0xFF009688);
        statusBadgeColor = Colors.tealAccent;
        statusTitle = 'وضعیت مالی امن | پول آزاد برای خرج کردن';
        statusIcon = Icons.check_circle_outline;
        break;
      case FreeBalanceStatus.warning:
        gradientStart = isDark ? const Color(0xFFE65100) : const Color(0xFFEF6C00);
        gradientEnd = isDark ? const Color(0xFFF57C00) : const Color(0xFFFFA000);
        statusBadgeColor = Colors.yellowAccent;
        statusTitle = 'موجودی آزاد ناچیز | نزدیک به مرز تعهدات';
        statusIcon = Icons.warning_amber_rounded;
        break;
      case FreeBalanceStatus.danger:
        gradientStart = isDark ? const Color(0xFFB71C1C) : const Color(0xFFC62828);
        gradientEnd = isDark ? const Color(0xFFD32F2F) : const Color(0xFFE53935);
        statusBadgeColor = Colors.amberAccent;
        statusTitle = 'کسری بودجه! تعهدات بیش از موجودی کل است';
        statusIcon = Icons.error_outline;
        break;
    }

    final freeToman = CurrencyFormatter.rialToToman(summary.freeBalanceRial);
    final freeTomanFormatted = CurrencyFormatter.formatToman(freeToman);
    final totalTomanFormatted = CurrencyFormatter.formatTomanFromRial(summary.totalBalanceRial);
    final commitmentsTomanFormatted = CurrencyFormatter.formatTomanFromRial(summary.totalCommitmentsRial);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [gradientStart, gradientEnd],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withAlpha(100),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // برچسب وضعیت بالا
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(50),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusBadgeColor, size: 16),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          statusTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: statusBadgeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                summary.periodRange.label,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'موجودی آزاد واقعی شما',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),

          // رقم بزرگ موجودی آزاد
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              freeTomanFormatted,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),

          Text(
            CurrencyFormatter.numberToPersianWords(freeToman),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 16),

          // نوار درصد تعهد
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: summary.commitmentPercentage,
              backgroundColor: Colors.white.withAlpha(40),
              valueColor: AlwaysStoppedAnimation<Color>(
                summary.commitmentPercentage > 0.8 ? Colors.amber : Colors.white,
              ),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 14),

          // ردیف تفکیک موجودی کل منهای تعهدات
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(40),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBreakdownColumn(
                  title: 'موجودی حساب‌های آزاد',
                  value: totalTomanFormatted,
                  color: Colors.white,
                ),
                Container(width: 1, height: 28, color: Colors.white24),
                _buildBreakdownColumn(
                  title: 'کسر کل تعهدات',
                  value: commitmentsTomanFormatted,
                  color: Colors.amberAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownColumn({required String title, required String value, required Color color}) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// بنر هشدار تراکنش‌های نیازمند دسته‌بندی
  Widget _buildUncategorizedAlertBanner(
    BuildContext context,
    Transaction sampleTransaction,
    int totalUncategorized,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFFA726),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${CurrencyFormatter.toPersianDigits(totalUncategorized)} تراکنش جدید نیازمند دسته‌بندی!',
                  style: const TextStyle(
                    color: Color(0xFFE65100),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'برای گزارش‌های دقیق، مشخص کنید این پول بابت چه چیزی هزینه شده است.',
                  style: TextStyle(color: Color(0xFF795548), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              QuickCategorizeSheet.show(context, sampleTransaction);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE65100),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('دسته‌بندی', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// بنر یادآوری تعهداتی که امروز سررسید دارند
  Widget _buildDueCommitmentBanner(
    BuildContext context,
    WidgetRef ref,
    List<PlannedPayment> duePayments,
    List<Account> accounts,
  ) {
    if (duePayments.isEmpty) return const SizedBox.shrink();
    final firstPayment = duePayments.first;
    final account = accounts.where((a) => a.id == firstPayment.accountId).firstOrNull;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBE9E7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF8A65)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE64A19),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.alarm_on, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⏰ سررسید تعهد: ${firstPayment.title} (${CurrencyFormatter.formatTomanFromRial(firstPayment.amountRial)})',
                  style: const TextStyle(
                    color: Color(0xFFBF360C),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  duePayments.length > 1
                      ? 'همچنین ${CurrencyFormatter.toPersianDigits(duePayments.length - 1)} تعهد دیگر موعد پرداخت دارد.'
                      : 'موعد پرداخت از کارت «${account?.title ?? 'مرتبط'}» فرا رسیده است.',
                  style: const TextStyle(color: Color(0xFF5D4037), fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _confirmAndSettlePayment(context, ref, firstPayment, account),
            icon: const Icon(Icons.check, size: 16),
            label: const Text('تسویه الان', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE64A19),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }

  /// تایید و تسویه تعهد مستقیم از داشبورد
  Future<void> _confirmAndSettlePayment(
    BuildContext context,
    WidgetRef ref,
    PlannedPayment payment,
    Account? account,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.freeBalanceSafe),
            SizedBox(width: 8),
            Text('تسویه تعهد مالی'),
          ],
        ),
        content: Text(
          'آیا تعهد «${payment.title}» با مبلغ ${CurrencyFormatter.formatTomanFromRial(payment.amountRial)} تسویه شده است؟\n\nبا تایید شما، این مبلغ از حساب «${account?.title ?? 'مرتبط'}» کسر و به عنوان تراکنش برداشت در سوابق ثبت می‌گردد.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.freeBalanceSafe,
              foregroundColor: Colors.white,
            ),
            child: const Text('بله، تسویه شد'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.markPlannedPaymentAsPaid(payment);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعهد «${payment.title}» با موفقیت تسویه و از حساب کسر شد.'),
            backgroundColor: AppColors.freeBalanceSafe,
          ),
        );
      }
    }
  }

  /// بخش حساب‌های بانکی (Carousel)
  Widget _buildAccountsSection(
    BuildContext context,
    AsyncValue<List<Account>> accountsAsync,
    AsyncValue<List<Bank>> banksAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'حساب‌ها و کارت‌های بانکی',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AccountsScreen()),
                  );
                },
                child: const Text('مدیریت حساب‌ها'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: accountsAsync.when(
            data: (accounts) {
              final banks = banksAsync.asData?.value ?? [];

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: accounts.length + 1,
                itemBuilder: (ctx, idx) {
                  if (idx == accounts.length) {
                    // دکمه افزودن حساب
                    return Container(
                      width: 130,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AccountsScreen()),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_card, size: 28, color: AppColors.primary),
                              SizedBox(height: 6),
                              Text('افزودن حساب', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final account = accounts[idx];
                  final bank = banks.where((b) => b.id == account.bankId).firstOrNull;
                  final bankColor = bank != null
                      ? Color(int.parse(bank.colorHex.replaceFirst('#', '0xFF')))
                      : AppColors.primary;

                  return Container(
                    width: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [bankColor, bankColor.withAlpha(200)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: bankColor.withAlpha(60),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // خط اول: بانک صادر کننده
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                bank?.name ?? 'بانک',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!account.includeInFreeBalance)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(60),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '🔒',
                                  style: TextStyle(fontSize: 10),
                                ),
                              )
                            else
                              const Icon(Icons.credit_card, color: Colors.white70, size: 18),
                          ],
                        ),

                        // خط دوم: نام دارنده ی کارت
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 14, color: Colors.white70),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                (account.ownerName != null && account.ownerName!.trim().isNotEmpty)
                                    ? account.ownerName!.trim()
                                    : (account.title.trim().isNotEmpty ? account.title : 'دارنده ثبت‌نشده'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // خط سوم: موجودی
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'موجودی:',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                            Text(
                              CurrencyFormatter.formatTomanFromRial(account.currentBalanceRial),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('خطا: $e'),
          ),
        ),
      ],
    );
  }

  /// بخش تعهدات پیش‌رو
  Widget _buildUpcomingCommitmentsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<PlannedPayment>> paymentsAsync,
    AsyncValue<List<Category>> categoriesAsync,
    AsyncValue<List<Account>> accountsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'تعهدات و پرداخت‌های آینده',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onNavigateToPlannedPayments,
                child: const Text('مشاهده همه و تعریف'),
              ),
            ],
          ),
        ),
        paymentsAsync.when(
          data: (payments) {
            if (payments.isEmpty) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.task_alt, size: 36, color: Colors.green),
                        const SizedBox(height: 6),
                        const Text(
                          'هیچ تعهد در انتظاری برای این دوره ندارید!',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'تمام پول شما آزاد برای خرج کردن یا پس‌انداز است.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final top4 = payments.take(4).toList();
            final accounts = accountsAsync.asData?.value ?? [];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: top4.map((payment) {
                  final remainingDays = JalaliHelper.daysRemaining(payment.dueDate);
                  Color badgeColor = Colors.blue;
                  if (remainingDays < 0) {
                    badgeColor = Colors.red;
                  } else if (remainingDays == 0) {
                    badgeColor = Colors.deepOrange;
                  } else if (remainingDays <= 3) {
                    badgeColor = Colors.orange;
                  }

                  final account = accounts.where((a) => a.id == payment.accountId).firstOrNull;
                  final ownerSuffix = (account?.ownerName != null && account!.ownerName!.trim().isNotEmpty)
                      ? ' [👤 ${account.ownerName!.trim()}]'
                      : '';
                  final cardDisplay = account != null ? '${account.title}$ownerSuffix' : 'حساب نامشخص';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.orange.withAlpha(30),
                                child: const Icon(Icons.assignment_late_outlined, color: Colors.orange),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '💳 اساین به کارت: $cardDisplay',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.formatTomanFromRial(payment.amountRial),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 2),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withAlpha(25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      JalaliHelper.daysRemainingLabel(payment.dueDate),
                                      style: TextStyle(fontSize: 10, color: badgeColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(height: 1),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'سررسید: ${JalaliHelper.formatFullDate(JalaliHelper.fromDateTime(payment.dueDate))}',
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // دکمه ویرایش تعهد
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                    tooltip: 'ویرایش تعهد',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () => AddPlannedPaymentDialog.showEdit(context, payment: payment),
                                  ),
                                  const SizedBox(width: 4),
                                  // دکمه تسویه مستقیم در داشبورد (دان کردن تعهد)
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.check_circle_outline, size: 16),
                                    label: const Text('تسویه (دان)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.freeBalanceSafe,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _confirmAndSettlePayment(context, ref, payment, account),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('خطا: $e'),
        ),
      ],
    );
  }

  /// بخش آخرین تراکنش‌ها
  Widget _buildRecentTransactionsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Transaction>> transactionsAsync,
    AsyncValue<List<Category>> categoriesAsync,
    AsyncValue<List<Account>> accountsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'آخرین تراکنش‌ها',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton(
                onPressed: onNavigateToTransactions,
                child: const Text('مشاهده همه'),
              ),
            ],
          ),
        ),
        transactionsAsync.when(
          data: (txList) {
            if (txList.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'هنوز تراکنشی ثبت نشده است.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              );
            }

            final categories = categoriesAsync.asData?.value ?? [];
            final accounts = accountsAsync.asData?.value ?? [];
            final top4 = txList.take(4).toList();

            return Column(
              children: top4.map((tx) {
                final isWithdraw = tx.type == 'withdraw';
                final category = categories.where((c) => c.id == tx.categoryId).firstOrNull;
                final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;

                Color catColor = isWithdraw ? Colors.red : Colors.green;
                IconData catIcon = isWithdraw ? Icons.arrow_downward : Icons.arrow_upward;

                if (category != null) {
                  catColor = Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));
                  catIcon = AppIcons.getCategoryIcon(category.iconCode);
                }

                final ownerInfo = (account?.ownerName != null && account!.ownerName!.trim().isNotEmpty)
                    ? ' [👤 ${account.ownerName!.trim()}]'
                    : '';

                return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: catColor.withAlpha(25),
                          child: Icon(catIcon, color: catColor, size: 20),
                        ),
                        title: Row(
                          children: [
                            Text(
                              category?.title ?? (tx.description ?? (isWithdraw ? 'برداشت' : 'واریز')),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            if (!tx.isCategorized) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'دسته‌بندی‌نشده',
                                  style: TextStyle(fontSize: 9, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Text(
                          '${account?.title ?? 'حساب'}$ownerInfo • ${JalaliHelper.formatDateTime(tx.occurredAt)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        trailing: Text(
                          '${isWithdraw ? '-' : '+'}${CurrencyFormatter.formatTomanFromRial(tx.amountRial)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isWithdraw ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                        onTap: () => _showRecentTransactionSheet(context, ref, tx),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('خطا: $e'),
            ),
          ],
        );
      }

  void _showRecentTransactionSheet(BuildContext context, WidgetRef ref, Transaction tx) {
    final isWithdraw = tx.type == 'withdraw';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tx.description ?? (isWithdraw ? 'برداشت' : 'واریز'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${isWithdraw ? '-' : '+'}${CurrencyFormatter.formatTomanFromRial(tx.amountRial)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isWithdraw ? Colors.red.shade700 : Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                title: const Text('ویرایش و اصلاح تراکنش'),
                subtitle: const Text('اصلاح مبلغ، حساب بانکی، تاریخ یا توضیحات'),
                onTap: () {
                  Navigator.pop(bCtx);
                  AddTransactionDialog.showEdit(context, tx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.category_outlined, color: Colors.orange),
                title: const Text('تعیین یا تغییر دسته‌بندی'),
                subtitle: const Text('انتخاب دسته برای گزارش‌ها و تحلیل مالی'),
                onTap: () {
                  Navigator.pop(bCtx);
                  QuickCategorizeSheet.show(context, tx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('حذف تراکنش'),
                subtitle: const Text('حذف تراکنش و بازگرداندن اثر آن بر مانده حساب'),
                onTap: () async {
                  Navigator.pop(bCtx);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      title: const Text('حذف تراکنش'),
                      content: const Text('آیا از حذف این تراکنش اطمینان دارید؟\nبا حذف این تراکنش، اثر مبلغ بر موجودی حساب مربوطه بازگردانده می‌شود.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('انصراف')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(dCtx, true),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          child: const Text('حذف'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    final db = ref.read(databaseProvider);
                    await db.deleteTransaction(tx.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تراکنش حذف شد و مانده حساب بازگردانده گردید.')),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
