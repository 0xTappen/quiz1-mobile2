import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/currency_formatter.dart';
import '../data/models/budget_model.dart';
import '../providers/finance_provider.dart';
import 'custom_text_field.dart';
import 'primary_button.dart';

class AddBudgetModal extends StatefulWidget {
  const AddBudgetModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddBudgetModal(),
    );
  }

  @override
  State<AddBudgetModal> createState() => _AddBudgetModalState();
}

class _AddBudgetModalState extends State<AddBudgetModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _selectedCategory = AppConstants.expenseCategories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final rawAmount = CurrencyFormatter.parse(_amountController.text.trim());
    if (rawAmount == null || rawAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batas anggaran harus lebih dari 0'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final newBudget = BudgetModel(
      id: 'bg_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      amount: rawAmount,
      category: _selectedCategory,
    );

    final provider = FinanceScope.of(context);
    await provider.addBudget(newBudget);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anggaran "${newBudget.name}" berhasil ditambahkan'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tambah Anggaran Bulanan',
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
              const SizedBox(height: 16),

              // Budget Name Input
              CustomTextField(
                label: 'Nama Anggaran',
                hint: 'Contoh: Belanja Bulanan, Transportasi',
                controller: _nameController,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama anggaran wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Limit Amount Input
              CustomTextField(
                label: 'Batas Nominal',
                hint: '0',
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefixText: 'Rp ',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nominal batas anggaran wajib diisi';
                  }
                  final parsed = CurrencyFormatter.parse(val);
                  if (parsed == null || parsed <= 0) {
                    return 'Masukkan nominal yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Category dropdown
              const Text(
                'Kategori Terkait',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
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
                items: AppConstants.expenseCategories.map((cat) {
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
              const SizedBox(height: 24),

              // Save button
              PrimaryButton(
                text: 'Simpan Anggaran',
                icon: Icons.check_rounded,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
