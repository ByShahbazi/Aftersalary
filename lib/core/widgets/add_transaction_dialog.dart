import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../constants/app_icons.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/jalali_helper.dart';
import 'app_date_picker.dart';
import 'currency_input_field.dart';

class AddTransactionDialog extends ConsumerStatefulWidget {
  final Transaction? transactionToEdit;
  final int? preselectedAccountId;
  final String? initialType;
  final int? initialAmountRial;
  final String? initialDescription;

  const AddTransactionDialog({
    super.key,
    this.transactionToEdit,
    this.preselectedAccountId,
    this.initialType,
    this.initialAmountRial,
    this.initialDescription,
  });

  static Future<bool?> show(
    BuildContext context, {
    int? preselectedAccountId,
    String? initialType,
    int? initialAmountRial,
    String? initialDescription,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        preselectedAccountId: preselectedAccountId,
        initialType: initialType,
        initialAmountRial: initialAmountRial,
        initialDescription: initialDescription,
      ),
    );
  }

  static Future<bool?> showEdit(
    BuildContext context,
    Transaction transaction,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AddTransactionDialog(
        transactionToEdit: transaction,
      ),
    );
  }

  @override
  ConsumerState<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends ConsumerState<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _type;
  int? _selectedAccountId;
  int? _selectedCategoryId;
  late Jalali _selectedDate;
  int _amountRial = 0;

  @override
  void initState() {
    super.initState();
    final tx = widget.transactionToEdit;
    if (tx != null) {
      _type = tx.type;
      _selectedAccountId = tx.accountId;
      _selectedCategoryId = tx.categoryId;
      _selectedDate = Jalali.fromDateTime(tx.occurredAt);
      _amountRial = tx.amountRial;
      _amountController.text = CurrencyFormatter.formatNumber(tx.amountRial);
      if (tx.description != null) {
        _descriptionController.text = tx.description!;
      }
    } else {
      _type = widget.initialType ?? 'withdraw';
      _selectedAccountId = widget.preselectedAccountId;
      _selectedDate = Jalali.now();
      if (widget.initialAmountRial != null) {
        _amountRial = widget.initialAmountRial!;
      }
      if (widget.initialDescription != null) {
        _descriptionController.text = widget.initialDescription!;
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showAppPersianDatePicker(
      context: context,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    final cleanAmount = CurrencyFormatter.parseCleanAmount(_amountController.text);
    final amount = cleanAmount > 0 ? cleanAmount : _amountRial;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً مبلغ معتبری وارد کنید.')),
      );
      return;
    }
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً حساب بانکی را انتخاب کنید.')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final occurredAt = _selectedDate.toDateTime();

    if (widget.transactionToEdit != null) {
      await db.editTransaction(
        transactionId: widget.transactionToEdit!.id,
        newAccountId: _selectedAccountId!,
        newAmountRial: amount,
        newType: _type,
        newOccurredAt: occurredAt,
        newCategoryId: _selectedCategoryId,
        newDescription: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تراکنش با موفقیت اصلاح شد و موجودی حساب تعدیل گردید.')),
        );
      }
    } else {
      await db.recordTransaction(
        accountId: _selectedAccountId!,
        amountRial: amount,
        type: _type,
        occurredAt: occurredAt,
        categoryId: _selectedCategoryId,
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        isCategorized: _selectedCategoryId != null,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تراکنش با موفقیت ثبت شد و موجودی حساب بروز گردید.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(allAccountsProvider);
    final banksAsync = ref.watch(allBanksProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final isWithdraw = _type == 'withdraw';
    final isEdit = widget.transactionToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'ویرایش و اصلاح تراکنش' : 'ثبت تراکنش جدید',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // انتخاب نوع تراکنش: واریز یا برداشت
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'withdraw',
                      label: Text('برداشت (هزینه)'),
                      icon: Icon(Icons.arrow_downward, color: Colors.red),
                    ),
                    ButtonSegment(
                      value: 'deposit',
                      label: Text('واریز (درآمد)'),
                      icon: Icon(Icons.arrow_upward, color: Colors.green),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (set) {
                    setState(() {
                      _type = set.first;
                      _selectedCategoryId = null; // ریست دسته‌بندی با تغییر نوع
                    });
                  },
                ),
                const SizedBox(height: 16),

                // انتخاب حساب
                accountsAsync.when(
                  data: (accounts) {
                    if (accounts.isEmpty) {
                      return const Text(
                        'ابتدا باید از بخش حساب‌ها یک حساب بانکی ایجاد کنید.',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    _selectedAccountId ??= accounts.first.id;
                    final banks = banksAsync.asData?.value ?? [];

                    return DropdownButtonFormField<int>(
                      initialValue: _selectedAccountId,
                      decoration: const InputDecoration(
                        labelText: 'کارت و حساب بانکی',
                        helperText: 'مشخص کنید این تراکنش برای کدام بانک و کارت بوده است',
                        prefixIcon: Icon(Icons.credit_card_outlined),
                      ),
                      isExpanded: true,
                      items: accounts.map((acc) {
                        final bank = banks.where((b) => b.id == acc.bankId).firstOrNull;
                        final bankTitle = bank != null ? bank.name : 'بانک';
                        final ownerSuffix = (acc.ownerName != null && acc.ownerName!.trim().isNotEmpty)
                            ? ' [👤 ${acc.ownerName!.trim()}]'
                            : '';
                        final cardNumSuffix = (acc.accountNumber != null && acc.accountNumber!.trim().isNotEmpty)
                            ? ' (${acc.accountNumber!.trim()})'
                            : '';
                        final balanceStr = CurrencyFormatter.formatTomanFromRial(acc.currentBalanceRial);

                        return DropdownMenuItem<int>(
                          value: acc.id,
                          child: Text(
                            '${acc.title} ($bankTitle)$ownerSuffix$cardNumSuffix - موجودی: $balanceStr',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAccountId = val;
                        });
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => const SizedBox(),
                ),
                const SizedBox(height: 14),

                // فیلد ورود مبلغ با پیش‌نمایش تومان
                CurrencyInputField(
                  controller: _amountController,
                  label: 'مبلغ تراکنش',
                  initialValueRial: widget.initialAmountRial,
                  onAmountChanged: (val) {
                    _amountRial = val;
                  },
                ),
                const SizedBox(height: 14),

                // انتخاب دسته‌بندی
                categoriesAsync.when(
                  data: (categories) {
                    final filtered = categories
                        .where((c) => isWithdraw ? c.type == 'expense' : c.type == 'income')
                        .toList();

                    return DropdownButtonFormField<int?>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'دسته‌بندی (اختیاری)',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('بدون دسته‌بندی (تعیین بعداً)'),
                        ),
                        ...filtered.map((cat) {
                          final color = Color(int.parse(cat.colorHex.replaceFirst('#', '0xFF')));
                          return DropdownMenuItem<int?>(
                            value: cat.id,
                            child: Row(
                              children: [
                                Icon(AppIcons.getCategoryIcon(cat.iconCode), size: 18, color: color),
                                const SizedBox(width: 8),
                                Text(cat.title),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                        });
                      },
                    );
                  },
                  loading: () => const SizedBox(),
                  error: (err, stack) => const SizedBox(),
                ),
                const SizedBox(height: 14),

                // انتخاب تاریخ شمسی همراه با دکمه اختصاصی امروز
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'تاریخ تراکنش',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          child: Text(
                            JalaliHelper.formatFullDate(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'تنظیم بر روی تاریخ امروز',
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.today, size: 16),
                        label: const Text('امروز'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDate = Jalali.now();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // توضیحات / یادداشت
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات (اختیاری)',
                    prefixIcon: Icon(Icons.notes_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 20),

                // دکمه ثبت
                ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWithdraw ? Colors.red.shade700 : Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(isEdit ? 'ذخیره اصلاحات' : 'ثبت تراکنش', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
