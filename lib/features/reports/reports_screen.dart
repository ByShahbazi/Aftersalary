import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/jalali_helper.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _monthOffset = 0; // 0: current period, -1: previous month period, etc.
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final activePeriodAsync = ref.watch(activeSalaryPeriodProvider);
    final transactionsAsync = ref.watch(allTransactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    final startDay = activePeriodAsync.asData?.value?.startDayOfMonth ?? 1;
    final targetJalali = Jalali.now().addMonths(_monthOffset);
    final periodRange = JalaliHelper.getSalaryPeriodRange(
      startDayOfMonth: startDay,
      targetDate: targetJalali,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('گزارش و تحلیل مالی', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: transactionsAsync.when(
        data: (allTransactions) {
          final categories = categoriesAsync.asData?.value ?? [];

          // فیلتر تراکنش‌های متعلق به بازه دوره انتخابی
          final periodTransactions = allTransactions.where((t) {
            return !t.occurredAt.isBefore(periodRange.startDateTime) &&
                !t.occurredAt.isAfter(periodRange.endDateTime);
          }).toList();

          int totalIncome = 0;
          int totalExpense = 0;
          final Map<int, int> categoryExpenseMap = {};

          for (final t in periodTransactions) {
            if (t.type == 'deposit') {
              totalIncome += t.amountRial;
            } else if (t.type == 'withdraw') {
              totalExpense += t.amountRial;
              final catId = t.categoryId ?? -1;
              categoryExpenseMap[catId] = (categoryExpenseMap[catId] ?? 0) + t.amountRial;
            }
          }

          final netBalance = totalIncome - totalExpense;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // نوار انتخاب دوره با دکمه‌های قبلی/بعدی
              _buildPeriodNavigator(periodRange),

              const SizedBox(height: 16),

              // کارت‌های خلاصه درآمد، هزینه و مانده دوره
              _buildSummaryCards(totalIncome, totalExpense, netBalance),

              const SizedBox(height: 20),

              // نمودار دایره‌ای تفکیک هزینه‌ها
              if (totalExpense > 0) ...[
                Text(
                  'تفکیک هزینه‌های این دوره',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildExpensePieChart(categoryExpenseMap, categories, totalExpense),
                const SizedBox(height: 20),
                Text(
                  'ریز سهم دسته‌بندی‌ها',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildCategoryList(categoryExpenseMap, categories, totalExpense),
              ] else ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'در این دوره هیچ هزینه‌ای ثبت نشده است.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
      ),
    );
  }

  Widget _buildPeriodNavigator(JalaliDateRange range) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blueGrey.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            tooltip: 'دوره قبل',
            onPressed: () {
              setState(() {
                _monthOffset--;
              });
            },
          ),
          Column(
            children: [
              const Text('دوره مالی انتخابی', style: TextStyle(fontSize: 11, color: Colors.grey)),
              Text(
                range.label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            tooltip: 'دوره بعد',
            onPressed: () {
              setState(() {
                _monthOffset++;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(int income, int expense, int net) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            title: 'درآمد کل',
            amountRial: income,
            color: Colors.green,
            icon: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            title: 'هزینه کل',
            amountRial: expense,
            color: Colors.red,
            icon: Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            title: 'تراز دوره',
            amountRial: net,
            color: net >= 0 ? AppColors.freeBalanceSafe : Colors.deepOrange,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required int amountRial,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        border: Border.all(color: color.withAlpha(50)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyFormatter.formatTomanFromRial(amountRial),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensePieChart(
    Map<int, int> categoryExpenseMap,
    List<Category> categories,
    int totalExpense,
  ) {
    final entries = categoryExpenseMap.entries.toList();

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse == null ||
                    pieTouchResponse.touchedSection == null) {
                  _touchedIndex = -1;
                  return;
                }
                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 3,
          centerSpaceRadius: 46,
          sections: List.generate(entries.length, (i) {
            final entry = entries[i];
            final isTouched = i == _touchedIndex;
            final radius = isTouched ? 58.0 : 48.0;

            final cat = categories.where((c) => c.id == entry.key).firstOrNull;
            final color = cat != null
                ? Color(int.parse(cat.colorHex.replaceFirst('#', '0xFF')))
                : Colors.grey;

            final percentage = (entry.value / totalExpense * 100);

            return PieChartSectionData(
              color: color,
              value: entry.value.toDouble(),
              title: '${CurrencyFormatter.toPersianDigits(percentage.toStringAsFixed(0))}٪',
              radius: radius,
              titleStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    Map<int, int> categoryExpenseMap,
    List<Category> categories,
    int totalExpense,
  ) {
    final sortedEntries = categoryExpenseMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sortedEntries.map((entry) {
        final cat = categories.where((c) => c.id == entry.key).firstOrNull;
        final color = cat != null
            ? Color(int.parse(cat.colorHex.replaceFirst('#', '0xFF')))
            : Colors.grey;
        final title = cat?.title ?? 'بدون دسته‌بندی';
        final icon = AppIcons.getCategoryIcon(cat?.iconCode);

        final percentage = totalExpense > 0 ? (entry.value / totalExpense) : 0.0;
        final percentFormatted = CurrencyFormatter.toPersianDigits((percentage * 100).toStringAsFixed(1));

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withAlpha(40)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withAlpha(25),
                    radius: 18,
                    child: Icon(icon, color: color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('$percentFormatted٪ از کل هزینه‌ها', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.formatTomanFromRial(entry.value),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.withAlpha(30),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
