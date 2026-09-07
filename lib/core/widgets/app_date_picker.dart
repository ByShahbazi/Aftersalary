import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../utils/jalali_helper.dart';

/// بازکننده تقویم شمسی برنامه با نمایش تضمینی تقویم فارسی، تاریخ پیش‌فرض امروز و دکمه انتخاب سریع امروز
Future<Jalali?> showAppPersianDatePicker({
  required BuildContext context,
  Jalali? initialDate,
  Jalali? firstDate,
  Jalali? lastDate,
}) async {
  final today = Jalali.now();

  return await showPersianDatePicker(
    context: context,
    // هر وقت تقویم باز می‌شود تاریخ دقیقاً روی امروز شمسی باشد
    initialDate: today,
    firstDate: firstDate ?? Jalali(1400, 1, 1),
    lastDate: lastDate ?? Jalali(1430, 12, 29),
    currentDate: today,
    initialEntryMode: PersianDatePickerEntryMode.calendar,
    initialDatePickerMode: PersianDatePickerMode.day,
    holidayConfig: const PersianHolidayConfig(weekendDays: {7}), // جمعه تعطیل
    confirmText: 'تایید تاریخ',
    cancelText: 'انصراف',
    helpText: 'انتخاب تاریخ شمسی',
    locale: const Locale('fa', 'IR'),
    textDirection: TextDirection.rtl,
    builder: (context, child) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Theme(
          data: Theme.of(context),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: child ?? const SizedBox()),
                const SizedBox(height: 10),
                // دکمه اختصاصی رفتن به تاریخ امروز درون تقویم
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.today, size: 18),
                    label: Text(
                      'برو به تاریخ امروز (${JalaliHelper.formatFullDate(today)})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(today);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
