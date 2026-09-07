import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/jalali_helper.dart';
import '../../core/widgets/add_transaction_dialog.dart';
import '../../core/widgets/quick_categorize_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filterType = 'all'; // 'all', 'withdraw', 'deposit', 'uncategorized'
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final accountsAsync = ref.watch(allAccountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تراکنش‌ها', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddTransactionDialog.show(context),
        icon: const Icon(Icons.add),
        label: const Text('تراکنش جدید'),
      ),
      body: Column(
        children: [
          // فیلترهای بالا
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('همه', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('هزینه‌ها (برداشت)', 'withdraw'),
                  const SizedBox(width: 8),
                  _buildFilterChip('درآمدها (واریز)', 'deposit'),
                  const SizedBox(width: 8),
                  _buildFilterChip('نیازمند دسته‌بندی', 'uncategorized'),
                ],
              ),
            ),
          ),

          // جستجو
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'جستجو در توضیحات یا مبلغ...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim();
                });
              },
            ),
          ),

          const SizedBox(height: 8),

          // لیست تراکنش‌ها
          Expanded(
            child: transactionsAsync.when(
              data: (txList) {
                final categories = categoriesAsync.asData?.value ?? [];
                final accounts = accountsAsync.asData?.value ?? [];

                var filtered = txList;

                // فیلتر بر اساس نوع
                if (_filterType == 'withdraw') {
                  filtered = filtered.where((t) => t.type == 'withdraw').toList();
                } else if (_filterType == 'deposit') {
                  filtered = filtered.where((t) => t.type == 'deposit').toList();
                } else if (_filterType == 'uncategorized') {
                  filtered = filtered.where((t) => !t.isCategorized).toList();
                }

                // فیلتر بر اساس جستجو
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((t) {
                    final desc = t.description?.toLowerCase() ?? '';
                    final rawSms = t.rawSmsText?.toLowerCase() ?? '';
                    final amount = t.amountRial.toString();
                    return desc.contains(_searchQuery.toLowerCase()) ||
                        rawSms.contains(_searchQuery.toLowerCase()) ||
                        amount.contains(_searchQuery);
                  }).toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'هیچ تراکنشی با این مشخصات یافت نشد.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, idx) {
                    final tx = filtered[idx];
                    final isWithdraw = tx.type == 'withdraw';
                    final category = categories.where((c) => c.id == tx.categoryId).firstOrNull;
                    final account = accounts.where((a) => a.id == tx.accountId).firstOrNull;

                    Color catColor = isWithdraw ? Colors.red : Colors.green;
                    IconData catIcon = isWithdraw ? Icons.arrow_downward : Icons.arrow_upward;

                    if (category != null) {
                      catColor = Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));
                      catIcon = AppIcons.getCategoryIcon(category.iconCode);
                    }

                    final ownerText = (account?.ownerName != null && account!.ownerName!.isNotEmpty)
                        ? ' [👤 ${account.ownerName}]'
                        : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: catColor.withAlpha(25),
                          child: Icon(catIcon, color: catColor),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                category?.title ?? (tx.description ?? (isWithdraw ? 'برداشت' : 'واریز')),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                            if (!tx.isCategorized) ...[
                              InkWell(
                                onTap: () => QuickCategorizeSheet.show(context, tx),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: const Text(
                                    'تعیین دسته',
                                    style: TextStyle(fontSize: 10, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${account?.title ?? 'حساب'}$ownerText • ${JalaliHelper.formatDateTime(tx.occurredAt)}',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            if (tx.description != null && tx.description!.isNotEmpty && category != null)
                              Text(
                                tx.description!,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${isWithdraw ? '-' : '+'}${CurrencyFormatter.formatTomanFromRial(tx.amountRial)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isWithdraw ? Colors.red.shade700 : Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  '${CurrencyFormatter.formatRial(tx.amountRial, includeUnit: false)} ریال',
                                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                              tooltip: 'گزینه‌های تراکنش',
                              onSelected: (action) {
                                if (action == 'edit') {
                                  AddTransactionDialog.showEdit(context, tx);
                                } else if (action == 'categorize') {
                                  QuickCategorizeSheet.show(context, tx);
                                } else if (action == 'delete') {
                                  _confirmDeleteTransaction(context, tx);
                                }
                              },
                              itemBuilder: (pCtx) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                      SizedBox(width: 8),
                                      Text('ویرایش و اصلاح'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'categorize',
                                  child: Row(
                                    children: [
                                      Icon(Icons.category_outlined, size: 18, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text('تغییر دسته‌بندی'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('حذف تراکنش'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () => _showTransactionActions(context, tx),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطا: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionActions(BuildContext context, Transaction tx) {
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
                onTap: () {
                  Navigator.pop(bCtx);
                  _confirmDeleteTransaction(context, tx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterType == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _filterType = value;
        });
      },
    );
  }

  Future<void> _confirmDeleteTransaction(BuildContext context, Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف تراکنش'),
        content: const Text('آیا از حذف این تراکنش اطمینان دارید؟\nبا حذف این تراکنش، اثر مبلغ بر موجودی حساب مربوطه به صورت خودکار بازگردانده می‌شود.'),
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
      await db.deleteTransaction(tx.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تراکنش حذف شد و مانده حساب بازگردانده گردید.')),
        );
      }
    }
  }
}
