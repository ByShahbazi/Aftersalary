import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/database/app_database.dart';
import '../../core/database/database_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/currency_input_field.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(allAccountsProvider);
    final banksAsync = ref.watch(allBanksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('بانک‌ها و حساب‌ها', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_outlined),
            tooltip: 'افزودن بانک جدید',
            onPressed: () => _showAddBankDialog(context, ref),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: accountsAsync.when(
        data: (accounts) {
          final banks = banksAsync.asData?.value ?? [];
          int totalAssets = 0;
          int freeAssets = 0;
          for (final a in accounts) {
            totalAssets += a.currentBalanceRial;
            if (a.includeInFreeBalance) {
              freeAssets += a.currentBalanceRial;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // کارت سرجمع دارایی‌ها
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('دارایی‌های آزاد (مشمول در موجودی آزاد)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.formatTomanFromRial(freeAssets),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalAssets != freeAssets
                          ? 'مجموع کل دارایی‌ها (با احتساب پس‌انداز): ${CurrencyFormatter.formatTomanFromRial(totalAssets)}'
                          : 'معادل ${CurrencyFormatter.formatRial(totalAssets)}',
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'حساب‌های فعال (${CurrencyFormatter.toPersianDigits(accounts.length)})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddAccountDialog(context, ref, banks),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('حساب جدید'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              if (accounts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('هیچ حسابی ثبت نشده است. یک حساب بانکی اضافه کنید.'),
                  ),
                )
              else
                ...accounts.map((account) {
                  final bank = banks.where((b) => b.id == account.bankId).firstOrNull;
                  final bankColor = bank != null
                      ? Color(int.parse(bank.colorHex.replaceFirst('#', '0xFF')))
                      : AppColors.primary;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: bankColor.withAlpha(50), width: 1.2),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showAccountOptions(context, ref, account),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // خط اول: بانک صادر کننده
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: bankColor.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.account_balance, size: 16, color: bankColor),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'بانک صادر کننده: ',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: bank?.name ?? account.title,
                                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: bankColor),
                                        ),
                                        if (account.title.isNotEmpty && account.title != (bank?.name ?? ''))
                                          TextSpan(
                                            text: '  (${account.title})',
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.normal),
                                          ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.more_vert, size: 18, color: Colors.grey.shade400),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // خط دوم: نام دارنده کارت
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person_outline, size: 16, color: Colors.blueGrey),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'نام دارنده کارت: ',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: (account.ownerName != null && account.ownerName!.trim().isNotEmpty)
                                              ? account.ownerName!.trim()
                                              : 'ثبت نشده',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: (account.ownerName != null && account.ownerName!.trim().isNotEmpty)
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: (account.ownerName != null && account.ownerName!.trim().isNotEmpty)
                                                ? Colors.black87
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                        if (account.accountNumber != null && account.accountNumber!.trim().isNotEmpty)
                                          TextSpan(
                                            text: '  •  ${account.accountNumber!.trim()}',
                                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                          ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // خط سوم: موجودی
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.primary),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'موجودی: ',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                                Expanded(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: CurrencyFormatter.formatTomanFromRial(account.currentBalanceRial),
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const TextSpan(text: ' '),
                                        TextSpan(
                                          text: '(${CurrencyFormatter.formatRial(account.currentBalanceRial, includeUnit: false)} ریال)',
                                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // خط چهارم: مشمول ازاد
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: (account.includeInFreeBalance ? Colors.green : Colors.deepOrange).withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    account.includeInFreeBalance ? Icons.check_circle_outline : Icons.lock_outline,
                                    size: 16,
                                    color: account.includeInFreeBalance ? Colors.green.shade700 : Colors.deepOrange,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'مشمول آزاد: ',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.black54),
                                ),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: account.includeInFreeBalance ? Colors.green.shade50 : Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: account.includeInFreeBalance ? Colors.green.shade300 : Colors.orange.shade300,
                                      ),
                                    ),
                                    child: Text(
                                      account.includeInFreeBalance ? 'مشمول در موجودی آزاد' : 'غیرمشمول (پس‌انداز / صندوق)',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: account.includeInFreeBalance ? Colors.green.shade800 : Colors.deepOrange.shade800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطا: $e')),
      ),
    ),
  ),
);
  }

  void _showAccountOptions(BuildContext context, WidgetRef ref, Account account) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(account.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
              title: const Text('بروزرسانی مستقیم موجودی (تطبیق با بانک)'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditBalanceDialog(context, ref, account);
              },
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined, color: Colors.teal),
              title: const Text('ویرایش مشخصات، عنوان و دارنده کارت'),
              onTap: () {
                Navigator.pop(ctx);
                _showEditAccountDetailsDialog(context, ref, account);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('حذف حساب بانکی'),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    title: const Text('حذف حساب'),
                    content: const Text('آیا از حذف این حساب و تمام تراکنش‌های وابسته به آن اطمینان دارید؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(dCtx, false), child: const Text('انصراف')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dCtx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  final db = ref.read(databaseProvider);
                  await db.deleteAccount(account.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('حساب با موفقیت حذف شد.')),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBalanceDialog(BuildContext context, WidgetRef ref, Account account) {
    final controller = TextEditingController();
    int newAmount = account.currentBalanceRial;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('ویرایش موجودی ${account.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'موجودی جدید حساب را به ریال وارد کنید:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            CurrencyInputField(
              controller: controller,
              label: 'موجودی جدید',
              initialValueRial: account.currentBalanceRial,
              onAmountChanged: (val) {
                newAmount = val;
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () async {
              final parsed = CurrencyFormatter.parseCleanAmount(controller.text);
              final finalAmount = controller.text.trim().isNotEmpty ? parsed : newAmount;
              final db = ref.read(databaseProvider);
              await db.updateAccount(account.copyWith(currentBalanceRial: finalAmount));
              if (context.mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('موجودی حساب با موفقیت بروزرسانی شد.')),
                );
              }
            },
            child: const Text('ذخیره تغییرات'),
          ),
        ],
      ),
    );
  }

  void _showEditAccountDetailsDialog(BuildContext context, WidgetRef ref, Account account) {
    final titleController = TextEditingController(text: account.title);
    final ownerController = TextEditingController(text: account.ownerName ?? '');
    final numberController = TextEditingController(text: account.accountNumber ?? '');
    bool includeInFreeBalance = account.includeInFreeBalance;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setDState) => AlertDialog(
          title: const Text('ویرایش مشخصات حساب'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'عنوان حساب (مثلاً جاری، کارت خرید)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: ownerController,
                  decoration: const InputDecoration(
                    labelText: 'نام دارنده / مالک کارت',
                    hintText: 'مثلاً: علی، همسر، شرکت، پدر (جهت تفکیک)',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: 'شماره کارت / حساب (اختیاری)'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('محاسبه در مجموع دارایی‌های آزاد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: const Text('اگر خاموش باشد، موجودی این کارت در موجودی آزاد شمرده نمی‌شود (مناسب برای پس‌انداز یا صندوق).', style: TextStyle(fontSize: 11)),
                  value: includeInFreeBalance,
                  onChanged: (val) {
                    setDState(() {
                      includeInFreeBalance = val;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final db = ref.read(databaseProvider);
                await db.updateAccount(account.copyWith(
                  title: titleController.text.trim(),
                  ownerName: drift.Value(ownerController.text.trim().isEmpty ? null : ownerController.text.trim()),
                  accountNumber: drift.Value(numberController.text.trim().isEmpty ? null : numberController.text.trim()),
                  includeInFreeBalance: includeInFreeBalance,
                ));
                if (context.mounted) {
                  Navigator.pop(dCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('مشخصات حساب با موفقیت بروزرسانی شد.')),
                  );
                }
              },
              child: const Text('ذخیره تغییرات'),
            ),
          ],
        ),
      ),
    );
  }

  static String _generateBankColor(String name) {
    const palette = [
      '#1E56A0', '#1565C0', '#0277BD', '#00838F',
      '#00695C', '#2E7D32', '#F57F17', '#E65100',
      '#C62828', '#AD1457', '#6A1B9A', '#4527A0',
    ];
    final hash = name.codeUnits.fold(0, (acc, c) => acc + c);
    return palette[hash % palette.length];
  }

  void _showAddAccountDialog(BuildContext context, WidgetRef ref, List<Bank> banks) {
    final formKey = GlobalKey<FormState>();
    final bankNameController = TextEditingController(text: banks.isNotEmpty ? banks.first.name : '');
    final titleController = TextEditingController();
    final ownerNameController = TextEditingController();
    final numberController = TextEditingController();
    final balanceController = TextEditingController();

    int initialBalanceRial = 0;
    bool includeInFreeBalance = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('افزودن حساب جدید', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: bankNameController,
                    decoration: InputDecoration(
                      labelText: 'بانک صادرکننده *',
                      hintText: 'نام بانک را بنویسید یا انتخاب کنید',
                      prefixIcon: const Icon(Icons.account_balance),
                      suffixIcon: banks.isNotEmpty
                          ? PopupMenuButton<String>(
                              icon: const Icon(Icons.arrow_drop_down),
                              tooltip: 'انتخاب از بانک‌های موجود',
                              onSelected: (name) {
                                setState(() {
                                  bankNameController.text = name;
                                });
                              },
                              itemBuilder: (pCtx) => banks.map((b) => PopupMenuItem<String>(
                                value: b.name,
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 8,
                                      backgroundColor: Color(int.parse(b.colorHex.replaceFirst('#', '0xFF'))),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(b.name),
                                  ],
                                ),
                              )).toList(),
                            )
                          : null,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'نام بانک را وارد کنید' : null,
                  ),
                  const SizedBox(height: 6),
                  const Text('پیشنهاد سریع بانک‌ها:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'بلو بانک', 'بانک ملی', 'بانک ملت', 'بانک سپه',
                        'بانک صادرات', 'بانک پاسارگاد', 'بانک تجارت', 'بانک سامان',
                        'بانک مسکن', 'بانک قرض‌الحسنه رسالت', 'بانک پارسیان', 'بانک کشاورزی',
                      ].map((bName) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
                          label: Text(bName, style: const TextStyle(fontSize: 11)),
                          onPressed: () {
                            setState(() {
                              bankNameController.text = bName;
                            });
                          },
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'عنوان حساب (مثلاً جاری، کارت خرید)'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'عنوان را وارد کنید' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ownerNameController,
                    decoration: const InputDecoration(
                      labelText: 'نام دارنده / مالک کارت (اختیاری)',
                      hintText: 'مثلاً: علی، همسر، شرکت، پدر (جهت تفکیک کارت‌ها)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: numberController,
                    decoration: const InputDecoration(labelText: 'شماره کارت / حساب (اختیاری)'),
                  ),
                  const SizedBox(height: 12),
                  CurrencyInputField(
                    controller: balanceController,
                    label: 'موجودی اولیه (ریال)',
                    onAmountChanged: (val) => initialBalanceRial = val,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('محاسبه در موجودی آزاد', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('اگر خاموش باشد، موجودی این کارت در موجودی آزاد شمرده نمی‌شود (مناسب برای پس‌انداز یا صندوق).', style: TextStyle(fontSize: 11)),
                    value: includeInFreeBalance,
                    onChanged: (val) {
                      setState(() {
                        includeInFreeBalance = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final db = ref.read(databaseProvider);
                final enteredBankName = bankNameController.text.trim();

                final allBanks = await db.getAllBanks();
                final existingBank = allBanks.where(
                  (b) => b.name.trim().toLowerCase() == enteredBankName.toLowerCase(),
                ).firstOrNull;

                int bankId;
                if (existingBank != null) {
                  bankId = existingBank.id;
                } else {
                  final colorHex = _generateBankColor(enteredBankName);
                  bankId = await db.addBank(BanksCompanion.insert(
                    name: enteredBankName,
                    colorHex: colorHex,
                    iconName: const drift.Value('account_balance'),
                  ));
                }

                final parsedBalance = CurrencyFormatter.parseCleanAmount(balanceController.text);
                final finalBalance = balanceController.text.trim().isNotEmpty ? parsedBalance : initialBalanceRial;

                await db.addAccount(AccountsCompanion.insert(
                  bankId: bankId,
                  title: titleController.text.trim(),
                  ownerName: drift.Value(ownerNameController.text.trim().isEmpty ? null : ownerNameController.text.trim()),
                  accountNumber: drift.Value(numberController.text.trim().isEmpty ? null : numberController.text.trim()),
                  currentBalanceRial: drift.Value(finalBalance),
                  includeInFreeBalance: drift.Value(includeInFreeBalance),
                ));
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('حساب جدید با موفقیت اضافه شد.')),
                  );
                }
              },
              child: const Text('ایجاد حساب'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBankDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final smsNumberController = TextEditingController();
    String selectedColor = '#1E56A0';

    final presetColors = [
      '#1E56A0', '#C62828', '#2979FF', '#1565C0',
      '#00838F', '#0097A7', '#F57F17', '#2E7D32',
      '#37474F', '#AD1457', '#388E3C', '#7B1FA2',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('افزودن بانک سفارشی', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'نام بانک یا موسسه مالی'),
                    validator: (v) => v == null || v.trim().isEmpty ? 'نام بانک را وارد کنید' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: smsNumberController,
                    decoration: const InputDecoration(labelText: 'سرشماره پیامک بانک (اختیاری)'),
                  ),
                  const SizedBox(height: 16),
                  const Text('رنگ نماد بانک:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presetColors.map((hex) {
                      final c = Color(int.parse(hex.replaceFirst('#', '0xFF')));
                      final isSelected = selectedColor == hex;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = hex),
                        child: CircleAvatar(
                          backgroundColor: c,
                          radius: 16,
                          child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final db = ref.read(databaseProvider);
                await db.addBank(BanksCompanion.insert(
                  name: nameController.text.trim(),
                  colorHex: selectedColor,
                  smsSenderNumber: drift.Value(smsNumberController.text.trim().isEmpty ? null : smsNumberController.text.trim()),
                ));
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('بانک با موفقیت اضافه شد.')),
                  );
                }
              },
              child: const Text('ذخیره بانک'),
            ),
          ],
        ),
      ),
    );
  }
}
