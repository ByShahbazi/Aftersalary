import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/add_planned_payment_dialog.dart';
import '../../core/widgets/add_transaction_dialog.dart';
import 'accounts/accounts_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'planned_payments/planned_payments_screen.dart';
import 'reports/reports_screen.dart';
import 'settings/settings_screen.dart';
import 'sms_parser/sms_parser_screen.dart';
import 'transactions/transactions_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _navigateToIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        onNavigateToTransactions: () => _navigateToIndex(1),
        onNavigateToPlannedPayments: () => _navigateToIndex(2),
      ),
      const TransactionsScreen(),
      const PlannedPaymentsScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1115) : const Color(0xFFF1F5F9),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161A22) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
              floatingActionButton: _currentIndex == 0
                  ? FloatingActionButton.extended(
                      onPressed: () => _showQuickActionMenu(context),
                      icon: const Icon(Icons.bolt),
                      label: const Text('ثبت سریع'),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    )
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (idx) {
                  setState(() {
                    _currentIndex = idx;
                  });
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon: Icon(Icons.dashboard),
                    label: 'داشبورد',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long),
                    label: 'تراکنش‌ها',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment),
                    label: 'تعهدات',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.pie_chart_outline),
                    selectedIcon: Icon(Icons.pie_chart),
                    label: 'گزارش‌ها',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: 'تنظیمات',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 540),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'عملیات سریع مالی',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFEBEE),
                child: Icon(Icons.arrow_downward, color: Colors.red),
              ),
              title: const Text('ثبت هزینه (برداشت)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('ثبت خرید، کارت‌به‌کارت یا پرداخت حضوری'),
              onTap: () {
                Navigator.pop(ctx);
                AddTransactionDialog.show(context, initialType: 'withdraw');
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F5E9),
                child: Icon(Icons.arrow_upward, color: Colors.green),
              ),
              title: const Text('ثبت درآمد (واریز)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('واریز حقوق، دستمزد، سود بانکی و سایر دریافتی‌ها'),
              onTap: () {
                Navigator.pop(ctx);
                AddTransactionDialog.show(context, initialType: 'deposit');
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF3E0),
                child: Icon(Icons.assignment_outlined, color: Colors.orange),
              ),
              title: const Text('ثبت تعهد مالی جدید (قسط، اجاره، بدهی)', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('کسر خودکار از موجودی آزاد تا پایان دوره جاری'),
              onTap: () {
                Navigator.pop(ctx);
                AddPlannedPaymentDialog.show(context);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.sms_outlined, color: AppColors.primary),
              ),
              title: const Text('پردازش پیامک بانک', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('پیست متن پیامک و استخراج خودکار مشخصات تراکنش'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SmsParserScreen()),
                );
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEDE7F6),
                child: Icon(Icons.account_balance, color: Colors.deepPurple),
              ),
              title: const Text('مدیریت حساب‌ها و کارت‌های بانکی', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('مشاهده و ویرایش کارت‌ها و موجودی‌ها'),
              onTap: () {
                Navigator.pop(ctx);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
}
