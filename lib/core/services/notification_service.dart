import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../database/app_database.dart';
import '../utils/currency_formatter.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  // مجموعه‌ای از شناسه‌های تعهداتی که اعلان آن‌ها قبلاً ارسال شده تا تکرار بی‌مورد نشود
  static final Set<int> _notifiedPaymentIds = {};

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings();
      const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open');
      const windowsSettings = WindowsInitializationSettings(
        appName: 'Aftersalary',
        appUserModelId: 'com.aftersalary.app',
        guid: 'c8851493-27f9-4674-beae-a7c5c0a3e35d',
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
        linux: linuxSettings,
        windows: windowsSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification initialization failed (safe fallback): $e');
    }
  }

  /// ارسال اعلان یادآوری برای دسته‌بندی تراکنش جدید
  Future<void> showCategorizationPrompt({
    required int transactionId,
    required int amountRial,
    String? bankName,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final tomanStr = CurrencyFormatter.formatTomanFromRial(amountRial);
      final bankStr = bankName != null ? ' در $bankName' : '';

      const androidDetails = AndroidNotificationDetails(
        'transaction_categorization',
        'دسته‌بندی تراکنش‌ها',
        channelDescription: 'اعلان‌های یادآوری دسته‌بندی هزینه‌های جدید',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: transactionId,
        title: 'تراکنش جدید ثبت شد',
        body: 'مبلغ $tomanStr$bankStr ثبت شد. علت این هزینه چیست؟ لمس کنید.',
        notificationDetails: details,
        payload: 'tx_$transactionId',
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  /// بررسی خودکار و ارسال نوتیفیکیشن برای تعهداتی که موعد پرداخت آن‌ها فرا رسیده است
  Future<void> checkAndTriggerDueReminders({
    required List<PlannedPayment> payments,
    required List<Account> accounts,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final p in payments) {
      if (p.status != 'pending') continue;
      final due = DateTime(p.dueDate.year, p.dueDate.month, p.dueDate.day);
      final diffDays = due.difference(today).inDays;

      // اگر سررسید گذشته باشد یا امروز/فردا باشد و قبلاً اطلاع‌رسانی نشده باشد
      if (diffDays <= 1 && !_notifiedPaymentIds.contains(p.id)) {
        _notifiedPaymentIds.add(p.id);
        final account = accounts.where((a) => a.id == p.accountId).firstOrNull;
        final accountTitle = account?.title ?? 'حساب بانکی';

        await showPlannedPaymentReminder(
          paymentId: p.id,
          title: p.title,
          amountRial: p.amountRial,
          accountTitle: accountTitle,
          remainingDays: diffDays,
        );
      }
    }
  }

  /// ارسال اعلان یادآوری سررسید تعهد
  Future<void> showPlannedPaymentReminder({
    required int paymentId,
    required String title,
    required int amountRial,
    required String accountTitle,
    required int remainingDays,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final tomanStr = CurrencyFormatter.formatTomanFromRial(amountRial);
      final String duePrefix = remainingDays < 0
          ? 'سررسید گذشته!'
          : (remainingDays == 0 ? 'امروز موعد پرداخت است!' : 'فردا موعد پرداخت است!');

      const androidDetails = AndroidNotificationDetails(
        'planned_payments_reminder',
        'یادآوری سررسید تعهدات',
        channelDescription: 'اعلان‌های یادآوری سررسید چک، اقساط و تعهدات مالی',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const details = NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: 100000 + paymentId,
        title: '⏰ یادآوری تعهد: $title ($duePrefix)',
        body: 'مبلغ $tomanStr باید از «$accountTitle» پرداخت شود. برای تسویه لمس کنید.',
        notificationDetails: details,
        payload: 'payment_$paymentId',
      );
    } catch (e) {
      debugPrint('Error showing planned payment notification: $e');
    }
  }
}
