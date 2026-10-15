import 'package:flutter/material.dart';
import '../data/models/transaction_model.dart';
import '../data/models/budget_model.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/finance_repository.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceRepository _repo;

  List<TransactionModel> _transactions = [];
  List<BudgetModel> _budgets = [];
  UserProfileModel _profile = const UserProfileModel(
    name: 'Rifki Pratama',
    email: 'rifki.pratama@gmail.com',
    occupation: 'Product Designer & Developer',
  );
  bool _isLoading = true;

  FinanceProvider(this._repo) {
    loadData();
  }

  bool get isLoading => _isLoading;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  UserProfileModel get profile => _profile;

  void loadData() {
    _transactions = _repo.getTransactions();
    _budgets = _repo.getBudgets();
    _profile = _repo.getProfile();
    // Sort transactions by date descending
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _isLoading = false;
    notifyListeners();
  }

  // Financial Calculations
  double get totalIncome {
    return _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalBalance => totalIncome - totalExpense;

  // Monthly statistics (current month)
  List<TransactionModel> get currentMonthTransactions {
    final now = DateTime.now();
    return _transactions.where((t) {
      return t.date.year == now.year && t.date.month == now.month;
    }).toList();
  }

  double get monthlyIncome {
    return currentMonthTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    return currentMonthTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlySavings => monthlyIncome - monthlyExpense;

  // Budget calculations
  double get totalBudgetAmount {
    return _budgets.fold(0.0, (sum, b) => sum + b.amount);
  }

  double getCategoryExpense(String category) {
    return currentMonthTransactions
        .where((t) => t.isExpense && t.category == category)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalBudgetSpent {
    double spent = 0;
    for (final budget in _budgets) {
      spent += getCategoryExpense(budget.category);
    }
    return spent;
  }

  double get remainingBudget {
    final remaining = totalBudgetAmount - totalBudgetSpent;
    return remaining < 0 ? 0 : remaining;
  }

  double get budgetProgress {
    if (totalBudgetAmount <= 0) return 0;
    final progress = totalBudgetSpent / totalBudgetAmount;
    return progress.clamp(0.0, 1.0);
  }

  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  Map<String, double> get expenseCategoryBreakdown {
    final Map<String, double> map = {};
    for (final t in currentMonthTransactions.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0.0) + t.amount;
    }
    return map;
  }

  // Transactions Actions
  Future<void> addTransaction(TransactionModel tx) async {
    _transactions.insert(0, tx);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    await _repo.saveTransactions(_transactions);
    notifyListeners();
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _repo.saveTransactions(_transactions);
    notifyListeners();
  }

  // Budgets Actions
  Future<void> addBudget(BudgetModel budget) async {
    _budgets.add(budget);
    await _repo.saveBudgets(_budgets);
    notifyListeners();
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _repo.saveBudgets(_budgets);
    notifyListeners();
  }

  // Profile Actions
  Future<void> updateProfile(UserProfileModel updated) async {
    _profile = updated;
    await _repo.saveProfile(_profile);
    notifyListeners();
  }

  // Reset
  Future<void> resetAllData() async {
    await _repo.resetData();
    loadData();
  }
}

class FinanceScope extends InheritedNotifier<FinanceProvider> {
  const FinanceScope({
    super.key,
    required FinanceProvider super.notifier,
    required super.child,
  });

  static FinanceProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FinanceScope>();
    assert(scope != null, 'No FinanceScope found in context');
    return scope!.notifier!;
  }
}
