import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/sms_parser_service.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/quick_categorize_sheet.dart';

class SmsParserScreen extends ConsumerStatefulWidget {
  const SmsParserScreen({super.key});

  @override
  ConsumerState<SmsParserScreen> createState() => _SmsParserScreenState();
}

class _SmsParserScreenState extends ConsumerState<SmsParserScreen> {
  final _smsController = TextEditingController();
  ParsedSmsResult? _parsedResult;

  final List<String> _sampleSms = [
    'بلو بانک\nبرداشت مبلغ 1,250,000 ریال از حساب شما\nمانده: 14,800,000 ریال',
    'بانک ملت\nبرداشت: 350,000 ریال\nاز حساب 123456\nمانده: 8,200,000',
    'بانک ملی\nواریز مبلغ 25,000,000 ریال\nبابت حقوق و دستمزد',
  ];

  @override
  void dispose() {
    _smsController.dispose();
    super.dispose();
  }

  void _parseSms() {
    final text = _smsController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _parsedResult = null;
      });
      return;
    }

    final templates = ref.read(allSmsTemplatesProvider).asData?.value ?? [];
    final banks = ref.read(allBanksProvider).asData?.value ?? [];

    final result = SmsParserService.parse(
      rawText: text,
      templates: templates,
      banks: banks,
    );

    setState(() {
      _parsedResult = result;
    });
  }

  Future<void> _recordParsedTransaction() async {
    if (_parsedResult == null || !_parsedResult!.isMatched || _parsedResult!.amountRial == null) {
      return;
    }

    final accounts = ref.read(allAccountsProvider).asData?.value ?? [];
    if (accounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا باید یک حساب بانکی تعریف کنید.')),
      );
      return;
    }

    // انتخاب حساب پیش‌فرض بر اساس بانک تطبیق‌یافته
    int targetAccountId = accounts.first.id;
    if (_parsedResult!.bankId != null) {
      final matchedAcc = accounts.where((a) => a.bankId == _parsedResult!.bankId).firstOrNull;
      if (matchedAcc != null) {
        targetAccountId = matchedAcc.id;
      }
    }

    // تاییدیه و انتخاب حساب
    final selectedAccountId = await showDialog<int>(
      context: context,
      builder: (ctx) {
        int tempAccountId = targetAccountId;
        return StatefulBuilder(
          builder: (ctx, setDState) => AlertDialog(
            title: const Text('ثبت تراکنش پیامکی'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نوع: ${_parsedResult!.type == 'withdraw' ? 'برداشت (هزینه)' : 'واریز (درآمد)'}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'مبلغ: ${CurrencyFormatter.formatTomanFromRial(_parsedResult!.amountRial!)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 14),
                const Text('تراکنش به کدام حساب اعمال شود؟', style: TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  initialValue: tempAccountId,
                  decoration: const InputDecoration(isDense: true),
                  items: accounts.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.title))).toList(),
                  onChanged: (v) {
                    if (v != null) setDState(() => tempAccountId = v);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, tempAccountId),
                child: const Text('ثبت در حساب'),
              ),
            ],
          ),
        );
      },
    );

    if (selectedAccountId != null) {
      final db = ref.read(databaseProvider);
      final txId = await db.recordTransaction(
        accountId: selectedAccountId,
        amountRial: _parsedResult!.amountRial!,
        type: _parsedResult!.type,
        occurredAt: DateTime.now(),
        rawSmsText: _parsedResult!.rawText,
        description: 'ثبت خودکار از پیامک (${_parsedResult!.bankName ?? 'بانک'})',
        isCategorized: false,
      );

      // ارسال نوتیفیکیشن محلی برای یادآوری دسته‌بندی
      NotificationService().showCategorizationPrompt(
        transactionId: txId,
        amountRial: _parsedResult!.amountRial!,
        bankName: _parsedResult!.bankName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تراکنش با موفقیت ثبت شد و مانده حساب بروز گردید.')),
        );

        // باز کردن سریع شیت دسته‌بندی
        final txList = await db.getTransactions();
        final newlyAdded = txList.where((t) => t.id == txId).firstOrNull;
        if (newlyAdded != null && mounted) {
          QuickCategorizeSheet.show(context, newlyAdded);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(allSmsTemplatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('پردازشگر پیامک بانکی', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: ListView(
            padding: const EdgeInsets.all(16),
        children: [
          // راهنمای ماژول
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.blue.withAlpha(50)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'پیامک بانکی دریافتی را در کادر زیر قرار دهید تا مبلغ، نوع واریز/برداشت و نام بانک به صورت خودکار استخراج شود.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // کادر متن پیامک
          TextField(
            controller: _smsController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'متن پیامک بانک را اینجا پیست (Paste) کنید...',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _smsController.clear();
                  setState(() => _parsedResult = null);
                },
              ),
            ),
            onChanged: (_) => _parseSms(),
          ),

          const SizedBox(height: 10),

          // دکمه‌های پیامک نمونه برای تست سریع
          Row(
            children: [
              const Text('نمونه تست:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _sampleSms.asMap().entries.map((entry) {
                      final names = ['بلو بانک', 'بانک ملت', 'بانک ملی'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          label: Text(names[entry.key], style: const TextStyle(fontSize: 11)),
                          onPressed: () {
                            _smsController.text = entry.value;
                            _parseSms();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // نتیجه پردازش پیامک
          if (_parsedResult != null) ...[
            if (_parsedResult!.isMatched)
              _buildMatchedCard(_parsedResult!)
            else
              _buildUnmatchedCard(),
          ],

          const SizedBox(height: 24),

          // مدیریت الگوهای ثبت‌شده
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('الگوهای پیامک فعال بانک‌ها', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              TextButton.icon(
                onPressed: () => _showAddTemplateDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('الگوی جدید'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          templatesAsync.when(
            data: (templates) {
              return Column(
                children: templates.map((tmpl) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.pattern, color: AppColors.primary),
                      title: Text(tmpl.patternName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(tmpl.regex, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        onPressed: () async {
                          final db = ref.read(databaseProvider);
                          await db.deleteSmsTemplate(tmpl.id);
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('خطا: $e'),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildMatchedCard(ParsedSmsResult result) {
    final isWithdraw = result.type == 'withdraw';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWithdraw ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isWithdraw ? Colors.red.shade300 : Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isWithdraw ? Icons.arrow_downward : Icons.arrow_upward,
                color: isWithdraw ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 8),
              Text(
                'پیامک با موفقیت تفسیر شد! (${result.templateName ?? 'الگوی عمومی'})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isWithdraw ? Colors.red.shade900 : Colors.green.shade900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('بانک شناسایی‌شده:'),
              Text(result.bankName ?? 'عمومی / نامشخص', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('نوع تراکنش:'),
              Text(
                isWithdraw ? 'برداشت (هزینه)' : 'واریز (درآمد)',
                style: TextStyle(fontWeight: FontWeight.bold, color: isWithdraw ? Colors.red : Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('مبلغ استخراج‌شده:'),
              Text(
                CurrencyFormatter.formatTomanFromRial(result.amountRial ?? 0),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
              ),
            ],
          ),
          if (result.remainingBalanceRial != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('مانده اعلام‌شده در پیامک:'),
                Text(
                  CurrencyFormatter.formatTomanFromRial(result.remainingBalanceRial!),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _recordParsedTransaction,
              icon: const Icon(Icons.check),
              label: const Text('ثبت مستقیم این تراکنش در حساب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isWithdraw ? Colors.red.shade700 : Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnmatchedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'الگوی مناسبی برای استخراج مبلغ از این متن یافت نشد. می‌توانید الگوی جدید تعریف کنید یا تراکنش را دستی وارد فرمایید.',
              style: TextStyle(fontSize: 12, color: Colors.brown),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTemplateDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final regexController = TextEditingController();
    final banks = ref.read(allBanksProvider).asData?.value ?? [];

    if (banks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ابتدا باید یک بانک تعریف کنید.')),
      );
      return;
    }

    int selectedBankId = banks.first.id;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          title: const Text('تعریف الگوی جدید پیامک'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: selectedBankId,
                  decoration: const InputDecoration(labelText: 'بانک مربوطه'),
                  items: banks.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                  onChanged: (v) {
                    if (v != null) setDState(() => selectedBankId = v);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'نام الگو'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'نام الگو را وارد کنید' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: regexController,
                  decoration: const InputDecoration(labelText: 'عبارت باقاعده (Regex)'),
                  validator: (v) => v == null || v.trim().isEmpty ? 'الگوی Regex را وارد کنید' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final db = ref.read(databaseProvider);
                await db.addSmsTemplate(SmsTemplatesCompanion.insert(
                  bankId: selectedBankId,
                  patternName: nameController.text.trim(),
                  regex: regexController.text.trim(),
                  amountGroupIndex: const drift.Value(1),
                ));
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الگو ذخیره شد.')),
                  );
                }
              },
              child: const Text('ذخیره الگو'),
            ),
          ],
        ),
      ),
    );
  }
}
