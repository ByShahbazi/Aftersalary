import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../utils/currency_formatter.dart';

class CurrencyInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final ValueChanged<int>? onAmountChanged;
  final int? initialValueRial;

  const CurrencyInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.onAmountChanged,
    this.initialValueRial,
  });

  @override
  State<CurrencyInputField> createState() => _CurrencyInputFieldState();
}

class _CurrencyInputFieldState extends State<CurrencyInputField> {
  int _amountRial = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialValueRial != null && widget.initialValueRial! > 0) {
      _amountRial = widget.initialValueRial!;
      widget.controller.text = CurrencyFormatter.formatNumber(_amountRial);
    }
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final clean = CurrencyFormatter.parseCleanAmount(widget.controller.text);
    if (clean != _amountRial) {
      setState(() {
        _amountRial = clean;
      });
      widget.onAmountChanged?.call(clean);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toman = CurrencyFormatter.rialToToman(_amountRial);
    final tomanFormatted = CurrencyFormatter.formatToman(toman);
    final tomanInWords = _amountRial > 0 ? CurrencyFormatter.numberToPersianWords(toman) : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            _ThousandsSeparatorInputFormatter(),
          ],
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint ?? 'مبلغ به ریال',
            suffixText: 'ریال',
            suffixStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            prefixIcon: const Icon(Icons.monetization_on_outlined),
          ),
        ),
        const SizedBox(height: 6),
        // پیش‌نمایش زنده به تومان و حروف فارسی
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _amountRial > 0
                ? (theme.brightness == Brightness.dark
                    ? Colors.teal.shade900.withAlpha(80)
                    : AppColors.freeBalanceSafeBg)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.currency_exchange,
                size: 16,
                color: _amountRial > 0 ? AppColors.freeBalanceSafe : Colors.grey,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _amountRial > 0
                      ? 'معادل: $tomanFormatted ($tomanInWords)'
                      : 'مبلغ را به ریال وارد کنید تا معادل تومان نمایش داده شود',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: _amountRial > 0 ? FontWeight.w600 : FontWeight.normal,
                    color: _amountRial > 0
                        ? (theme.brightness == Brightness.dark ? Colors.tealAccent : AppColors.freeBalanceSafe)
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Convert any Persian/Arabic digits to English digits and extract only 0-9
    final englishDigits = CurrencyFormatter.toEnglishDigits(newValue.text);
    final cleanDigits = englishDigits.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanDigits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final intValue = int.tryParse(cleanDigits);
    if (intValue == null) {
      return oldValue;
    }

    // formatNumber formats with thousand separators and Persian digits
    final newFormatted = CurrencyFormatter.formatNumber(intValue);

    return TextEditingValue(
      text: newFormatted,
      selection: TextSelection.collapsed(offset: newFormatted.length),
    );
  }
}
