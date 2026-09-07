import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/jalali_helper.dart';
import '../../core/widgets/add_planned_payment_dialog.dart';

class PlannedPaymentsScreen extends ConsumerStatefulWidget {
  const PlannedPaymentsScreen({super.key});

  @override
  ConsumerState<PlannedPaymentsScreen> createState() => _PlannedPaymentsScreenState();
}

class _PlannedPaymentsScreenState extends ConsumerState<PlannedPaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allPaymentsAsync = ref.watch(allPlannedPaymentsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final accountsAsync = ref.watch(allAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعهدات و پرداخت‌های آینده', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'در انتظار پرداخت'),
            Tab(text: 'پرداخت‌شده‌ها'),
            Tab(text: 'همه تعهدات'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddPlannedPaymentDialog.show(context),
        icon: const Icon(Icons.add_task),
        label: const Text('تعهد جدید'),
        backgroundColor: const Color(0xFFE65100),
        foregroundColor: Colors.white,
      ),
      body: allPaymentsAsync.when(
        data: (payments) {
          final categories = categoriesAsync.asData?.value ?? [];
          final accounts = accountsAsync.asData?.value ?? [];

          final pendingPayments = payments.where((p) => p.status == 'pending').toList();
          final paidPayments = payments.where((p) => p.status == 'paid').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPaymentsList(pendingPayments, categories, accounts, isPendingTab: true),
              _buildPaymentsList(paidPayments, categories, accounts, isPendingTab: false),
              _buildPaymentsList(payments, categories, accounts, isPendingTab: false),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
      ),
    );
  }

  Widget _buildPaymentsList(
    List<PlannedPayment> payments,
    List<Category> categories,
    List<Account> accounts, {
    required bool isPendingTab,
  }) {
    if (payments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPendingTab ? Icons.check_circle_outline : Icons.assignment_outlined,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              isPendingTab ? 'هیچ تعهد در انتظاری وجود ندارد.' : 'تعهدی در این بخش یافت نشد.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    int totalAmount = 0;
    for (final p in payments) {
      totalAmount += p.amountRial;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // کادر سرجمع مبلغ
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isPendingTab ? const Color(0xFFFFF3E0) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isPendingTab ? const Color(0xFFFFB74D) : Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مجموع مبالغ (${CurrencyFormatter.toPersianDigits(payments.length)} مورد):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isPendingTab ? const Color(0xFFE65100) : Colors.black87,
                ),
              ),
              Text(
                CurrencyFormatter.formatTomanFromRial(totalAmount),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isPendingTab ? const Color(0xFFE65100) : Colors.black87,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        ...payments.map((payment) {
          final category = categories.where((c) => c.id == payment.categoryId).firstOrNull;
          final account = accounts.where((a) => a.id == payment.accountId).firstOrNull;
          final isPending = payment.status == 'pending';

          Color catColor = const Color(0xFFE65100);
          IconData catIcon = Icons.assignment_outlined;

          if (category != null) {
            catColor = Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));
            catIcon = AppIcons.getCategoryIcon(category.iconCode);
          }

          final remainingDays = JalaliHelper.daysRemaining(payment.dueDate);
          Color statusBadgeColor = Colors.blue;
          if (remainingDays < 0) {
            statusBadgeColor = Colors.red;
          } else if (remainingDays <= 2) {
            statusBadgeColor = Colors.deepOrange;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: catColor.withAlpha(25),
                        radius: 20,
                        child: Icon(catIcon, color: catColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              payment.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              'اساین به کارت: ${account?.title ?? 'حساب نامشخص'}${account?.ownerName != null && account!.ownerName!.trim().isNotEmpty ? ' [👤 ${account.ownerName!.trim()}]' : ''}',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.formatTomanFromRial(payment.amountRial),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            CurrencyFormatter.formatRial(payment.amountRial),
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'سررسید: ${JalaliHelper.formatFullDate(JalaliHelper.fromDateTime(payment.dueDate))}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      if (isPending)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBadgeColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            JalaliHelper.daysRemainingLabel(payment.dueDate),
                            style: TextStyle(fontSize: 11, color: statusBadgeColor, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'پرداخت‌شده',
                            style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _confirmAndMarkPaid(context, payment, account),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('تسویه و کسر از موجودی'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.freeBalanceSafe,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                          tooltip: 'ویرایش تعهد',
                          onPressed: () => AddPlannedPaymentDialog.showEdit(context, payment: payment),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          tooltip: 'حذف تعهد',
                          onPressed: () => _confirmDeletePayment(context, payment),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 64),
      ],
    );
  }

  Future<void> _confirmAndMarkPaid(BuildContext context, PlannedPayment payment, Account? account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسویه تعهد مالی'),
        content: Text(
          'با تایید این مرحله، مبلغ ${CurrencyFormatter.formatTomanFromRial(payment.amountRial)} از حساب «${account?.title ?? 'مرتبط'}» کسر شده و یک تراکنش برداشت در سوابق ثبت می‌گردد. آیا تایید می‌کنید؟',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.freeBalanceSafe, foregroundColor: Colors.white),
            child: const Text('تایید و پرداخت'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.markPlannedPaymentAsPaid(payment);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعهد با موفقیت تسویه شد و از حساب بانکی کسر گردید.')),
        );
      }
    }
  }

  Future<void> _confirmDeletePayment(BuildContext context, PlannedPayment payment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف تعهد'),
        content: const Text('آیا از حذف این تعهد اطمینان دارید؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.deletePlannedPayment(payment.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعهد با موفقیت حذف شد.')),
        );
      }
    }
  }
}
