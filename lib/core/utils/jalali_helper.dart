import 'package:shamsi_date/shamsi_date.dart';
import 'currency_formatter.dart';

class JalaliDateRange {
  final Jalali start;
  final Jalali end;

  const JalaliDateRange({required this.start, required this.end});

  DateTime get startDateTime => start.toDateTime();
  DateTime get endDateTime => end.toDateTime().add(const Duration(hours: 23, minutes: 59, seconds: 59));

  String get label {
    return 'از ${JalaliHelper.formatShortDate(start)} تا ${JalaliHelper.formatShortDate(end)}';
  }
}

class JalaliHelper {
  static const List<String> monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند'
  ];

  static const List<String> weekDayNames = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه‌شنبه',
    'چهارشنبه',
    'پنج‌شنبه',
    'جمعه'
  ];

  /// تبدیل DateTime میلادی به Jalali شمسی
  static Jalali fromDateTime(DateTime dateTime) {
    return Jalali.fromDateTime(dateTime);
  }

  /// تاریخ شمسی امروز
  static Jalali now() {
    return Jalali.now();
  }

  /// فرمت کوتاه تاریخ: مثلاً ۱۴۰۳/۰۶/۱۵
  static String formatShortDate(Jalali jalali) {
    final year = CurrencyFormatter.toPersianDigits(jalali.year);
    final month = CurrencyFormatter.toPersianDigits(jalali.month.toString().padLeft(2, '0'));
    final day = CurrencyFormatter.toPersianDigits(jalali.day.toString().padLeft(2, '0'));
    return '$year/$month/$day';
  }

  /// فرمت متنی روان تاریخ: مثلاً ۱۵ شهریور ۱۴۰۳
  static String formatFullDate(Jalali jalali) {
    final day = CurrencyFormatter.toPersianDigits(jalali.day);
    final monthName = monthNames[jalali.month - 1];
    final year = CurrencyFormatter.toPersianDigits(jalali.year);
    return '$day $monthName $year';
  }

  /// فرمت تاریخ و ساعت: مثلاً ۱۵ شهریور - ساعت ۱۴:۳۰
  static String formatDateTime(DateTime dateTime) {
    final j = fromDateTime(dateTime);
    final hour = CurrencyFormatter.toPersianDigits(dateTime.hour.toString().padLeft(2, '0'));
    final minute = CurrencyFormatter.toPersianDigits(dateTime.minute.toString().padLeft(2, '0'));
    return '${formatFullDate(j)} - ساعت $hour:$minute';
  }

  /// محاسبه دوره مالی و حقوقی فعال بر اساس روز شروع در ماه (مثلاً روز ۵ام)
  static JalaliDateRange getSalaryPeriodRange({
    required int startDayOfMonth,
    Jalali? targetDate,
  }) {
    final current = targetDate ?? Jalali.now();
    final day = current.day;

    Jalali start;
    Jalali end;

    if (startDayOfMonth <= 1) {
      // دوره حقوقی مطابق ماه تقویمی جاری است (از ۱ام تا آخرین روز ماه)
      start = Jalali(current.year, current.month, 1);
      end = Jalali(current.year, current.month, current.monthLength);
    } else if (day >= startDayOfMonth) {
      // دوره از همین ماه جاری شروع شده و در ماه بعد به پایان می‌رسد
      start = Jalali(current.year, current.month, startDayOfMonth);
      final nextMonth = current.addMonths(1);
      final daysInNextMonth = nextMonth.monthLength;
      final endDay = (startDayOfMonth - 1).clamp(1, daysInNextMonth);
      end = Jalali(nextMonth.year, nextMonth.month, endDay);
    } else {
      // روز جاری کمتر از روز حقوقی است؛ بنابراین دوره در ماه قبل شروع شده
      final prevMonth = current.addMonths(-1);
      final daysInPrevMonth = prevMonth.monthLength;
      final actualStartDay = startDayOfMonth.clamp(1, daysInPrevMonth);
      start = Jalali(prevMonth.year, prevMonth.month, actualStartDay);
      final endDay = (startDayOfMonth - 1).clamp(1, current.monthLength);
      end = Jalali(current.year, current.month, endDay);
    }

    return JalaliDateRange(start: start, end: end);
  }

  /// تعداد روزهای باقیمانده تا یک تاریخ
  static int daysRemaining(DateTime targetDateTime) {
    final today = DateTime.now();
    final cleanToday = DateTime(today.year, today.month, today.day);
    final cleanTarget = DateTime(targetDateTime.year, targetDateTime.month, targetDateTime.day);
    return cleanTarget.difference(cleanToday).inDays;
  }

  /// برچسب فارسی روزهای باقیمانده
  static String daysRemainingLabel(DateTime targetDateTime) {
    final diff = daysRemaining(targetDateTime);
    if (diff < 0) {
      return '${CurrencyFormatter.toPersianDigits(diff.abs())} روز گذشته (سررسید منقضی)';
    } else if (diff == 0) {
      return 'امروز (سررسید)';
    } else if (diff == 1) {
      return 'فردا';
    } else {
      return '${CurrencyFormatter.toPersianDigits(diff)} روز باقیمانده';
    }
  }
}
