import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/date_formatter.dart';
import '../data/models/transaction_model.dart';
import '../providers/finance_provider.dart';
import 'custom_text_field.dart';
import 'primary_button.dart';

import 'receipt_scanner_sheet.dart';

class AddTransactionModal extends StatefulWidget {
  final String? initialTitle;
  final double? initialAmount;
  final TransactionType? initialType;
  final String? initialCategory;
  final DateTime? initialDate;
  final String? initialDescription;

  const AddTransactionModal({
    super.key,
    this.initialTitle,
    this.initialAmount,
    this.initialType,
    this.initialCategory,
    this.initialDate,
    this.initialDescription,
  });

  static Future<void> show(
    BuildContext context, {
    String? initialTitle,
    double? initialAmount,
    TransactionType? initialType,
    String? initialCategory,
    DateTime? initialDate,
    String? initialDescription,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionModal(
        initialTitle: initialTitle,
        initialAmount: initialAmount,
        initialType: initialType,
        initialCategory: initialCategory,
        initialDate: initialDate,
        initialDescription: initialDescription,
      ),
    );
  }

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _formKey = GlobalKey<FormState>();
  TransactionType _selectedType = TransactionType.expense;

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _descController;

  late String _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _amountController = TextEditingController(
      text: widget.initialAmount != null && widget.initialAmount! > 0
          ? CurrencyFormatter.format(widget.initialAmount!).replaceAll('Rp ', '')
          : '',
    );
    _descController = TextEditingController(text: widget.initialDescription ?? '');
    _selectedCategory = widget.initialCategory ??
        (_selectedType == TransactionType.expense
            ? AppConstants.expenseCategories.first
            : AppConstants.incomeCategories.first);
    if (widget.initialDate != null) {
      _selectedDate = widget.initialDate!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      _selectedCategory = type == TransactionType.expense
          ? AppConstants.expenseCategories.first
          : AppConstants.incomeCategories.first;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Pilih Tanggal Transaksi',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = CurrencyFormatter.parse(_amountController.text.trim());
    if (rawAmount == null || rawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nominal harus lebih dari 0'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final newTransaction = TransactionModel(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      amount: rawAmount,
      type: _selectedType,
      category: _selectedCategory,
      date: _selectedDate,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
    );

    final provider = FinanceScope.of(context);
    await provider.addTransaction(newTransaction);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Transaksi "${newTransaction.title}" berhasil disimpan',
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openReceiptScanner() {
    ReceiptScannerSheet.show(
      context: context,
      onReceiptScanned: (result) {
        setState(() {
          _selectedType = TransactionType.expense;
          _titleController.text = result.merchant;
          _amountController.text =
              CurrencyFormatter.format(result.totalAmount).replaceAll('Rp ', '');
          if (AppConstants.expenseCategories.contains(result.category)) {
            _selectedCategory = result.category;
          } else {
            _selectedCategory = 'Belanja';
          }
          if (result.date != null) {
            _selectedDate = result.date!;
          }
          final itemsText =
              result.items.isNotEmpty ? result.items.join(', ') : '';
          _descController.text = result.notes.isNotEmpty
              ? result.notes
              : (itemsText.isNotEmpty ? 'Item: $itemsText' : '');
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '✨ Berhasil mengisi data dari struk "${result.merchant}"!'),
            backgroundColor: const Color(0xFF4F46E5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = _selectedType == TransactionType.expense
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // OCR Receipt Scan Button
              InkWell(
                onTap: _openReceiptScanner,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.document_scanner_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Scan Bon / Struk Belanja',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4338CA),
                                  ),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '✨ AI Vision',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF7C3AED),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'Otomatis isi nominal & merchant dari foto struk',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF6366F1),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Type Selector: Pengeluaran vs Pemasukan
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTypeButton(
                        type: TransactionType.expense,
                        label: 'Pengeluaran',
                        icon: Icons.arrow_upward_rounded,
                        activeColor: AppColors.expense,
                      ),
                    ),
                    Expanded(
                      child: _buildTypeButton(
                        type: TransactionType.income,
                        label: 'Pemasukan',
                        icon: Icons.arrow_downward_rounded,
                        activeColor: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Nominal Amount Input
              CustomTextField(
                label: 'Nominal',
                hint: '0',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixText: 'Rp ',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nominal tidak boleh kosong';
                  }
                  final parsed = CurrencyFormatter.parse(val);
                  if (parsed == null || parsed <= 0) {
                    return 'Masukkan nominal yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Title Input
              CustomTextField(
                label: 'Nama Transaksi',
                hint: 'Contoh: Makan Siang, Kopi, Gaji Bulanan',
                controller: _titleController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama transaksi wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category Dropdown
              const Text(
                'Kategori',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                key: ValueKey('${_selectedType.name}-$_selectedCategory'),
                initialValue: _selectedCategory,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                items: categories.map((cat) {
                  final catColor = AppColors.getCategoryColor(cat);
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            AppConstants.getCategoryIcon(cat),
                            size: 16,
                            color: catColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          cat,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newCat) {
                  if (newCat != null) {
                    setState(() => _selectedCategory = newCat);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Date Picker Field
              CustomTextField(
                label: 'Tanggal',
                readOnly: true,
                onTap: _pickDate,
                controller: TextEditingController(
                  text: DateFormatter.full(_selectedDate),
                ),
                suffixIcon: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 14),

              // Description / Notes
              CustomTextField(
                label: 'Catatan (Opsional)',
                hint: 'Tambahkan catatan tambahan jika ada',
                controller: _descController,
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              // Save Button
              PrimaryButton(
                text: 'Simpan Transaksi',
                icon: Icons.check_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton({
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color activeColor,
  }) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => _onTypeChanged(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? activeColor : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
