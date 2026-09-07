import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/jalali_helper.dart';

enum FreeBalanceStatus {
  safe,    // موجودی آزاد مثبت و امن
  warning, // موجودی آزاد نزدیک به صفر
  danger,  // موجودی آزاد منفی (تعهد بیش از موجودی)
}

class FreeBalanceSummary {
  final int totalBalanceRial; // موجودی کل حساب‌های مشمول موجودی آزاد
  final int grossBalanceRial; // موجودی کل تمام حساب‌ها (شامل پس‌انداز و غیرآزاد)
  final int totalCommitmentsRial; // مجموع کل تعهدات در انتظار پرداخت
  final int freeBalanceRial;
  final int pendingCommitmentsCount;
  final JalaliDateRange periodRange;
  final FreeBalanceStatus status;
  final double commitmentPercentage;

  const FreeBalanceSummary({
    required this.totalBalanceRial,
    this.grossBalanceRial = 0,
    required this.totalCommitmentsRial,
    required this.freeBalanceRial,
    required this.pendingCommitmentsCount,
    required this.periodRange,
    required this.status,
    required this.commitmentPercentage,
  });

  factory FreeBalanceSummary.empty() {
    final range = JalaliHelper.getSalaryPeriodRange(startDayOfMonth: 1);
    return FreeBalanceSummary(
      totalBalanceRial: 0,
      grossBalanceRial: 0,
      totalCommitmentsRial: 0,
      freeBalanceRial: 0,
      pendingCommitmentsCount: 0,
      periodRange: range,
      status: FreeBalanceStatus.safe,
      commitmentPercentage: 0,
    );
  }
}

class FreeBalanceService {
  static FreeBalanceSummary calculate({
    required List<Account> accounts,
    required List<PlannedPayment> plannedPayments,
    required SalaryPeriod? activePeriod,
  }) {
    final startDay = activePeriod?.startDayOfMonth ?? 1;
    final periodRange = JalaliHelper.getSalaryPeriodRange(startDayOfMonth: startDay);

    // ۱. مجموع موجودی حساب‌ها (تفکیک حساب‌های مشمول موجودی آزاد از حساب‌های پس‌انداز/جداگانه)
    int totalFreeAssetBalance = 0;
    int grossBalance = 0;
    for (final acc in accounts) {
      grossBalance += acc.currentBalanceRial;
      if (acc.includeInFreeBalance) {
        totalFreeAssetBalance += acc.currentBalanceRial;
      }
    }

    // ۲. محاسبه کل تعهدات در انتظار:
    // هر تعهدی که ثبت می‌شود بلافاصله و بدون قید شرط زمانی از موجودی آزاد کسر می‌گردد
    int totalCommitments = 0;
    int pendingCount = 0;

    for (final payment in plannedPayments) {
      if (payment.status == 'pending') {
        totalCommitments += payment.amountRial;
        pendingCount++;
      }
    }

    // ۳. محاسبه موجودی آزاد واقعی: موجودی حساب‌های آزاد منهای تمام تعهدات معوق و آینده
    final freeBalance = totalFreeAssetBalance - totalCommitments;

    // ۴. تعیین وضعیت و درصد تعهد
    FreeBalanceStatus status;
    if (freeBalance < 0) {
      status = FreeBalanceStatus.danger;
    } else if (freeBalance == 0 || (totalFreeAssetBalance > 0 && freeBalance < totalFreeAssetBalance * 0.1)) {
      status = FreeBalanceStatus.warning;
    } else {
      status = FreeBalanceStatus.safe;
    }

    double percent = 0.0;
    if (totalFreeAssetBalance > 0) {
      percent = (totalCommitments / totalFreeAssetBalance).clamp(0.0, 1.0);
    } else if (totalCommitments > 0) {
      percent = 1.0;
    }

    return FreeBalanceSummary(
      totalBalanceRial: totalFreeAssetBalance,
      grossBalanceRial: grossBalance,
      totalCommitmentsRial: totalCommitments,
      freeBalanceRial: freeBalance,
      pendingCommitmentsCount: pendingCount,
      periodRange: periodRange,
      status: status,
      commitmentPercentage: percent,
    );
  }
}

/// پرودوایدر واکنشی برای دریافت خلاصه وضعیت موجودی آزاد در کل برنامه
final freeBalanceSummaryProvider = Provider<FreeBalanceSummary>((ref) {
  final accountsAsync = ref.watch(allAccountsProvider);
  final paymentsAsync = ref.watch(pendingPlannedPaymentsProvider);
  final periodAsync = ref.watch(activeSalaryPeriodProvider);

  final accounts = accountsAsync.asData?.value ?? [];
  final payments = paymentsAsync.asData?.value ?? [];
  final period = periodAsync.asData?.value;

  return FreeBalanceService.calculate(
    accounts: accounts,
    plannedPayments: payments,
    activePeriod: period,
  );
});
