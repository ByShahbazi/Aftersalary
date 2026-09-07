import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_icons.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/services/backup_service.dart';
import '../../core/utils/currency_formatter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodAsync = ref.watch(activeSalaryPeriodProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final currentStartDay = periodAsync.asData?.value?.startDayOfMonth ?? 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تنظیمات برنامه', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بخش دوره حقوقی و مالی
          _buildSectionHeader(context, 'دوره حقوقی و مالی', Icons.calendar_month_outlined),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.date_range, color: AppColors.primary),
              ),
              title: const Text('روز شروع دوره مالی در ماه شمسی', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'شروع از روز ${CurrencyFormatter.toPersianDigits(currentStartDay)} هر ماه (مثلاً روز واریز حقوق)',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => _showChangeSalaryDayDialog(context, ref, currentStartDay),
            ),
          ),

          const SizedBox(height: 20),

          // بخش پشتیبان‌گیری و بازیابی
          _buildSectionHeader(context, 'پشتیبان‌گیری و انتقال داده‌ها', Icons.backup_outlined),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.file_download_outlined, color: Colors.green),
                  ),
                  title: const Text('خروجی گرفتن از تمام اطلاعات (Export JSON)'),
                  subtitle: const Text('دانلود نسخه پشتیبان از تمام حساب‌ها، تراکنش‌ها و تعهدات', style: TextStyle(fontSize: 11)),
                  onTap: () => _exportData(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(Icons.file_upload_outlined, color: Colors.orange),
                  ),
                  title: const Text('بازیابی اطلاعات از فایل پشتیبان (Import JSON)'),
                  subtitle: const Text('بازگردانی اطلاعات از فایل یا متن ذخیره‌شده قبلی', style: TextStyle(fontSize: 11)),
                  onTap: () => _importData(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.delete_forever_outlined, color: Colors.red),
                  ),
                  title: const Text('بازنشانی کامل داده‌ها (شروع تازه)', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: const Text('حذف تمامی حساب‌ها، تراکنش‌ها و تعهدات و ریست اپلیکیشن', style: TextStyle(fontSize: 11)),
                  onTap: () => _confirmResetAllData(context, ref),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // بخش مدیریت دسته‌بندی‌ها
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildSectionHeader(context, 'دسته‌بندی‌های هزینه و درآمد', Icons.category_outlined),
              ),
              TextButton.icon(
                onPressed: () => _showAddCategoryDialog(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('دسته جدید'),
              ),
            ],
          ),
          categoriesAsync.when(
            data: (categories) {
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((cat) {
                      final color = Color(int.parse(cat.colorHex.replaceFirst('#', '0xFF')));
                      return Chip(
                        avatar: Icon(AppIcons.getCategoryIcon(cat.iconCode), size: 16, color: color),
                        label: Text(cat.title, style: const TextStyle(fontSize: 12)),
                        deleteIcon: cat.isDefault ? null : const Icon(Icons.close, size: 14),
                        onDeleted: cat.isDefault
                            ? null
                            : () async {
                                final db = ref.read(databaseProvider);
                                await db.deleteCategory(cat.id);
                              },
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('خطا: $e'),
          ),

          const SizedBox(height: 24),

          // درباره اپلیکیشن
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withAlpha(25),
                        child: const Icon(Icons.shield_outlined, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'درباره Aftersalary',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'این برنامه به صورت ۱۰۰٪ آفلاین (Local-first) کار می‌کند. کلیه داده‌ها در حافظه اختصاصی دستگاه شما ذخیره شده و هیچ حسابی به اینترنت منتقل نمی‌شود.',
                    style: TextStyle(fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'فرمول موجودی آزاد: موجودی کل حساب‌ها منهای تعهدات در انتظار تا پایان دوره مالی جاری.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeSalaryDayDialog(BuildContext context, WidgetRef ref, int currentDay) {
    int selectedDay = currentDay;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('انتخاب روز واریز حقوق / شروع دوره'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'روز ${CurrencyFormatter.toPersianDigits(selectedDay)} هر ماه شمسی',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Slider(
                value: selectedDay.toDouble(),
                min: 1,
                max: 31,
                divisions: 30,
                label: CurrencyFormatter.toPersianDigits(selectedDay),
                onChanged: (val) {
                  setDState(() {
                    selectedDay = val.round();
                  });
                },
              ),
              const Text(
                'تعهدات و گزارش‌های دوره‌ای از این روز تا روز قبل در ماه بعد محاسبه می‌شوند.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                final db = ref.read(databaseProvider);
                await db.updateSalaryPeriodStartDay(selectedDay);
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('روز شروع دوره به روز $selectedDay تغییر یافت.')),
                  );
                }
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final jsonStr = await BackupService.exportDatabase(db);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('خروجی نسخه پشتیبان (JSON)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('متن پشتیبان تولید شد. می‌توانید آن را کپی و در محلی امن نگهداری کنید:'),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonStr,
                      style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('کد پشتیبان در کلیپ‌بورد کپی شد.')),
                );
                Navigator.pop(ctx);
              },
              child: const Text('کپی کردن کد'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('بستن'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('بازیابی اطلاعات از متن پشتیبان'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('متن JSON پشتیبان را در کادر زیر قرار دهید:', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Paste backup JSON here...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;

              final db = ref.read(databaseProvider);
              final success = await BackupService.importDatabase(db, text);

              if (context.mounted) {
                Navigator.pop(ctx);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('اطلاعات با موفقیت بازیابی شد.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('خطا در بازیابی: فایل نامعتبر است.')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
            child: const Text('بازیابی داده‌ها'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    String selectedType = 'expense';
    String selectedColor = '#FF7043';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('افزودن دسته‌بندی جدید'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'عنوان دسته (مثلاً کتاب و آموزش)'),
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('هزینه')),
                  ButtonSegment(value: 'income', label: Text('درآمد')),
                ],
                selected: {selectedType},
                onSelectionChanged: (s) => setDState(() => selectedType = s.first),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                final db = ref.read(databaseProvider);
                await db.addCategory(CategoriesCompanion.insert(
                  title: title,
                  iconCode: 0xe59c,
                  colorHex: selectedColor,
                  type: selectedType,
                  isDefault: const drift.Value(false),
                ));

                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('دسته‌بندی جدید اضافه شد.')),
                  );
                }
              },
              child: const Text('ذخیره دسته'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmResetAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('بازنشانی کامل داده‌ها'),
          ],
        ),
        content: const Text(
          'آیا از حذف تمام حساب‌ها، تراکنش‌ها و تعهدات مالی اطمینان دارید؟\n\n'
          'با این اقدام، تمام اطلاعات وارد شده پاک شده و برنامه به حالت خام اولیه برمی‌گردد. این عمل غیرقابل بازگشت است.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('بله، همه‌چیز را پاک کن'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.resetAllData();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('تمامی داده‌های برنامه با موفقیت ریست شدند.'),
          ),
        );
      }
    }
  }
}
