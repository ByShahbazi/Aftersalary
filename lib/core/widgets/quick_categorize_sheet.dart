import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_icons.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/jalali_helper.dart';

class QuickCategorizeSheet extends ConsumerWidget {
  final Transaction transaction;

  const QuickCategorizeSheet({super.key, required this.transaction});

  static Future<void> show(BuildContext context, Transaction transaction) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => QuickCategorizeSheet(transaction: transaction),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final theme = Theme.of(context);
    final isWithdraw = transaction.type == 'withdraw';

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تعیین دسته‌بندی تراکنش',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // اطلاعات تراکنش
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isWithdraw ? Colors.red.withAlpha(20) : Colors.green.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  isWithdraw ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isWithdraw ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isWithdraw ? 'برداشت' : 'واریز'}: ${CurrencyFormatter.formatTomanFromRial(transaction.amountRial)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        JalaliHelper.formatDateTime(transaction.occurredAt),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'علت این تراکنش چه بوده است؟',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 12),
          // لیست گزینه‌های دسته‌بندی
          categoriesAsync.when(
            data: (categories) {
              final filtered = categories
                  .where((c) => isWithdraw ? c.type == 'expense' : c.type == 'income')
                  .toList();

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: filtered.map((cat) {
                  final color = Color(int.parse(cat.colorHex.replaceFirst('#', '0xFF')));
                  return InkWell(
                    onTap: () async {
                      final db = ref.read(databaseProvider);
                      await db.updateTransactionCategory(transaction.id, cat.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تراکنش به دسته‌بندی «${cat.title}» اختصاص یافت.'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        border: Border.all(color: color.withAlpha(80)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.getCategoryIcon(cat.iconCode), size: 18, color: color),
                          const SizedBox(width: 6),
                          Text(
                            cat.title,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('خطا در بارگذاری دسته‌بندی‌ها: $err'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
