import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../constants/app_colors.dart';
import '../constants/app_icons.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/jalali_helper.dart';
import 'app_date_picker.dart';
import 'currency_input_field.dart';

class AddPlannedPaymentDialog extends ConsumerStatefulWidget {
  final int? preselectedAccountId;
  final PlannedPayment? paymentToEdit;

  const AddPlannedPaymentDialog({
    super.key,
    this.preselectedAccountId,
    this.paymentToEdit,
  });

  static Future<bool?> show(BuildContext context, {int? preselectedAccountId}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AddPlannedPaymentDialog(preselectedAccountId: preselectedAccountId),
    );
  }

  static Future<bool?> showEdit(BuildContext context, {required PlannedPayment payment}) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AddPlannedPaymentDialog(paymentToEdit: payment),
    );
  }

  @override
  ConsumerState<AddPlannedPaymentDialog> createState() => _AddPlannedPaymentDialogState();
}

class _AddPlannedPaymentDialogState extends ConsumerState<AddPlannedPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  int? _selectedAccountId;
  int? _selectedCategoryId;
  late Jalali _selectedDueDate;
  int _amountRial = 0;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    final p = widget.paymentToEdit;
    if (p != null) {
      _titleController.text = p.title;
      _amountRial = p.amountRial;
      _amountController.text = CurrencyFormatter.formatNumber(p.amountRial);
      _selectedAccountId = p.accountId;
      _selectedCategoryId = p.categoryId;
      _selectedDueDate = Jalali.fromDateTime(p.dueDate);
      _isRecurring = p.isRecurring;
    } else {
      _selectedAccountId = widget.preselectedAccountId;
      // پیش‌فرض سررسید: تاریخ امروز
      _selectedDueDate = Jalali.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showAppPersianDatePicker(
      context: context,
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _savePlannedPayment() async {
    if (!_formKey.currentState!.validate()) return;
    final cleanAmount = CurrencyFormatter.parseCleanAmount(_amountController.text);
    final amount = cleanAmount > 0 ? cleanAmount : _amountRial;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً مبلغ تعهد را به درستی وارد کنید.')),
      );
      return;
    }
    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً کارتی که می‌خواهید تعهد به آن اساین شود را انتخاب کنید.')),
      );
      return;
    }

    final db = ref.read(databaseProvider);
    final dueDate = _selectedDueDate.toDateTime();

    if (widget.paymentToEdit != null) {
      // ویرایش تعهد موجود
      final updated = widget.paymentToEdit!.copyWith(
        title: _titleController.text.trim(),
        amountRial: amount,
        accountId: _selectedAccountId!,
        categoryId: drift.Value(_selectedCategoryId),
        dueDate: dueDate,
        isRecurring: _isRecurring,
      );
      await db.updatePlannedPayment(updated);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعهد با موفقیت بروزرسانی شد.')),
        );
      }
    } else {
      // ثبت تعهد جدید
      await db.addPlannedPayment(PlannedPaymentsCompanion.insert(
        accountId: _selectedAccountId!,
        categoryId: drift.Value(_selectedCategoryId),
        title: _titleController.text.trim(),
        amountRial: amount,
        dueDate: dueDate,
        status: const drift.Value('pending'),
        isRecurring: drift.Value(_isRecurring),
      ));

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعهد با موفقیت ثبت شد و از موجودی آزاد کسر گردید.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(allAccountsProvider);
    final banksAsync = ref.watch(allBanksProvider);
    final expenseCategoriesAsync = ref.watch(expenseCategoriesProvider);
    final isEdit = widget.paymentToEdit != null;

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
                      isEdit ? 'ویرایش تعهد مالی' : 'ثبت تعهد / پرداخت آینده',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // عنوان تعهد
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'عنوان تعهد (مثلاً قسط وام مسکن یا اجاره)',
                    prefixIcon: Icon(Icons.assignment_outlined),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'لطفاً عنوان تعهد را وارد کنید.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // فیلد ورود مبلغ تعهد
                CurrencyInputField(
                  controller: _amountController,
                  label: 'مبلغ تعهد',
                  initialValueRial: isEdit ? widget.paymentToEdit!.amountRial : null,
                  onAmountChanged: (val) {
                    _amountRial = val;
                  },
                ),
                const SizedBox(height: 14),

                // انتخاب کارت و اساین به حساب
                accountsAsync.when(
                  data: (accounts) {
                    if (accounts.isEmpty) {
                      return const Text(
                        'ابتدا باید یک حساب بانکی ایجاد کنید.',
                        style: TextStyle(color: Colors.red),
                      );
                    }
                    _selectedAccountId ??= accounts.first.id;
                    final banks = banksAsync.asData?.value ?? [];

                    return DropdownButtonFormField<int>(
                      initialValue: _selectedAccountId,
                      decoration: const InputDecoration(
                        labelText: 'اساین به کارت / حساب پرداخت‌کننده',
                        helperText: 'مشخص کنید این تعهد قرار است از کدام کارت پرداخت و کسر شود',
                        prefixIcon: Icon(Icons.credit_card_outlined),
                      ),
                      isExpanded: true,
                      items: accounts.map((acc) {
                        final bank = banks.where((b) => b.id == acc.bankId).firstOrNull;
                        final bankName = bank?.name ?? 'بانک';
                        final ownerStr = (acc.ownerName != null && acc.ownerName!.trim().isNotEmpty)
                            ? ' [👤 ${acc.ownerName!.trim()}]'
                            : '';
                        final balanceStr = CurrencyFormatter.formatTomanFromRial(acc.currentBalanceRial);

                        return DropdownMenuItem<int>(
                          value: acc.id,
                          child: Text(
                            '${acc.title} ($bankName)$ownerStr - موجودی: $balanceStr',
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

                // انتخاب دسته‌بندی
                expenseCategoriesAsync.when(
                  data: (categories) {
                    return DropdownButtonFormField<int?>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'دسته‌بندی تعهد (اختیاری)',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('بدون دسته‌بندی مشخص'),
                        ),
                        ...categories.map((cat) {
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

                // انتخاب تاریخ شمسی سررسید همراه با دکمه اختصاصی امروز
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'تاریخ سررسید شمسی',
                            prefixIcon: Icon(Icons.event_outlined),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  JalaliHelper.formatFullDate(_selectedDueDate),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  JalaliHelper.daysRemainingLabel(_selectedDueDate.toDateTime()),
                                  style: const TextStyle(fontSize: 10, color: Colors.blue),
                                ),
                              ),
                            ],
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
                            _selectedDueDate = Jalali.now();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // سوئیچ تکرار ماهانه
                SwitchListTile(
                  title: const Text('تکرار ماهانه این پرداخت', style: TextStyle(fontSize: 14)),
                  subtitle: const Text('برای هزینه‌های ثابت مانند اجاره و اقساط ماهانه', style: TextStyle(fontSize: 12)),
                  value: _isRecurring,
                  onChanged: (val) {
                    setState(() {
                      _isRecurring = val;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                // دکمه ثبت / ویرایش
                ElevatedButton(
                  onPressed: _savePlannedPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdit ? AppColors.primary : const Color(0xFFE65100),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEdit ? 'ذخیره تغییرات تعهد' : 'ثبت تعهد مالی',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
