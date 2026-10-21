import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/transaction_model.dart';
import '../data/models/budget_model.dart';
import '../data/models/user_profile_model.dart';
import '../data/repositories/finance_repository.dart';
import '../data/repositories/sample_data.dart';
import '../services/firestore_service.dart';

class FinanceProvider extends ChangeNotifier {
  final FinanceRepository _repo;
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<User?>? _authSubscription;

  List<TransactionModel> _transactions = [];
  List<BudgetModel> _budgets = [];
  UserProfileModel _profile = SampleData.initialProfile;
  bool _isLoading = true;

  FinanceProvider(this._repo) {
    loadLocalData();

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        syncWithFirestore(user);
      } else {
        loadLocalData();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  bool get isLoading => _isLoading;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  List<BudgetModel> get budgets => List.unmodifiable(_budgets);
  UserProfileModel get profile => _profile;

  void loadLocalData() {
    _profile = _repo.getProfile();
    final email = _profile.email.toLowerCase();
    final isErwin = email.contains('erwin_wijay') || email.contains('erwin');
    if (isErwin && (_profile.occupation.isEmpty || _profile.name == 'Pengguna FinTrack')) {
      _profile = SampleData.erwinProfile;
      _repo.saveProfile(_profile);
    }

    _transactions = _repo.getTransactions();
    if (isErwin && _transactions.isEmpty) {
      _transactions = SampleData.getTransactionsWithLastMonth();
      _repo.saveTransactions(_transactions);
    }

    _budgets = _repo.getBudgets();
    if (isErwin && _budgets.isEmpty) {
      _budgets = SampleData.initialBudgets;
      _repo.saveBudgets(_budgets);
    }

    _transactions.sort((a, b) => b.date.compareTo(a.date));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await syncWithFirestore(user);
    } else {
      loadLocalData();
    }
  }

  Future<void> syncWithFirestore(User user) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userEmail = (user.email ?? '').toLowerCase().trim();
      final isErwin = userEmail.contains('erwin_wijay') || userEmail.contains('erwin');

      // 1. Fetch Profile from Firestore
      var cloudProfile = await _firestoreService.getUserProfile(user.uid);
      if (cloudProfile == null) {
        if (isErwin) {
          cloudProfile = SampleData.erwinProfile.copyWith(
            avatarUrl: user.photoURL,
          );
        } else {
          final newName = (user.displayName != null && user.displayName!.trim().isNotEmpty)
              ? user.displayName!.trim()
              : 'Pengguna FinTrack';
          cloudProfile = UserProfileModel(
            name: newName,
            email: user.email ?? '',
            occupation: '',
            avatarUrl: user.photoURL,
          );
        }
        await _firestoreService.saveUserProfile(user.uid, cloudProfile);
      } else {
        if (isErwin) {
          if (cloudProfile.name.isEmpty || cloudProfile.name == 'Pengguna FinTrack') {
            cloudProfile = cloudProfile.copyWith(name: 'Erwin Wijaya');
          }
          if (cloudProfile.occupation.isEmpty) {
            cloudProfile = cloudProfile.copyWith(occupation: 'Mahasiswa Informatika / Mobile Dev');
          }
          if (cloudProfile.email.isEmpty) {
            cloudProfile = cloudProfile.copyWith(email: 'erwin_wijaya@teknokrat.ac.id');
          }
          if (cloudProfile.avatarUrl == null && user.photoURL != null) {
            cloudProfile = cloudProfile.copyWith(avatarUrl: user.photoURL);
          }
          await _firestoreService.saveUserProfile(user.uid, cloudProfile);
        } else {
          // Fill in missing Google profile info if empty
          if ((cloudProfile.name.isEmpty || cloudProfile.name == 'Pengguna FinTrack') &&
              user.displayName != null &&
              user.displayName!.isNotEmpty) {
            cloudProfile = cloudProfile.copyWith(name: user.displayName);
          }
          if (cloudProfile.email.isEmpty && user.email != null) {
            cloudProfile = cloudProfile.copyWith(email: user.email);
          }
          if (cloudProfile.avatarUrl == null && user.photoURL != null) {
            cloudProfile = cloudProfile.copyWith(avatarUrl: user.photoURL);
          }
        }
      }
      _profile = cloudProfile;
      await _repo.saveProfile(_profile);

      // 2. Fetch Transactions from Firestore
      _transactions = await _firestoreService.getTransactions(user.uid);
      if (isErwin && _transactions.isEmpty) {
        // Otomatis seed data bulan ini & bulan kemarin untuk presentasi
        final demoTransactions = SampleData.getTransactionsWithLastMonth();
        for (final tx in demoTransactions) {
          await _firestoreService.saveTransaction(user.uid, tx);
        }
        _transactions = demoTransactions;
      }
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      await _repo.saveTransactions(_transactions);

      // 3. Fetch Budgets from Firestore
      _budgets = await _firestoreService.getBudgets(user.uid);
      if (isErwin && _budgets.isEmpty) {
        final demoBudgets = SampleData.initialBudgets;
        for (final b in demoBudgets) {
          await _firestoreService.saveBudget(user.uid, b);
        }
        _budgets = demoBudgets;
      }
      await _repo.saveBudgets(_budgets);
    } catch (e) {
      debugPrint('Error syncing with Firestore: $e');
      loadLocalData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Explicit demo seeder for presentation
  Future<void> seedErwinDemoData() async {
    _isLoading = true;
    notifyListeners();
    try {
      final user = FirebaseAuth.instance.currentUser;
      final demoProfile = SampleData.erwinProfile;
      final demoTransactions = SampleData.getTransactionsWithLastMonth();
      final demoBudgets = SampleData.initialBudgets;

      _profile = demoProfile;
      _transactions = List.from(demoTransactions);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _budgets = List.from(demoBudgets);

      await _repo.saveProfile(_profile);
      await _repo.saveTransactions(_transactions);
      await _repo.saveBudgets(_budgets);

      if (user != null) {
        await _firestoreService.saveUserProfile(user.uid, _profile);
        for (final tx in _transactions) {
          await _firestoreService.saveTransaction(user.uid, tx);
        }
        for (final b in _budgets) {
          await _firestoreService.saveBudget(user.uid, b);
        }
      }
    } catch (e) {
      debugPrint('Error seeding Erwin demo data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  // Last month statistics
  List<TransactionModel> get lastMonthTransactions {
    final now = DateTime.now();
    final prevMonthRef = DateTime(now.year, now.month - 1, 1);
    return _transactions.where((t) {
      return t.date.year == prevMonthRef.year &&
          t.date.month == prevMonthRef.month;
    }).toList();
  }

  double get lastMonthIncome {
    return lastMonthTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get lastMonthExpense {
    return lastMonthTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get lastMonthSavings => lastMonthIncome - lastMonthExpense;

  Map<String, double> get lastMonthExpenseCategoryBreakdown {
    final Map<String, double> map = {};
    for (final t in lastMonthTransactions.where((t) => t.isExpense)) {
      map[t.category] = (map[t.category] ?? 0.0) + t.amount;
    }
    return map;
  }

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

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.saveTransaction(user.uid, tx);
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    await _repo.saveTransactions(_transactions);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.deleteTransaction(user.uid, id);
    }
  }

  // Budgets Actions
  Future<void> addBudget(BudgetModel budget) async {
    _budgets.add(budget);
    await _repo.saveBudgets(_budgets);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.saveBudget(user.uid, budget);
    }
  }

  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _repo.saveBudgets(_budgets);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.deleteBudget(user.uid, id);
    }
  }

  // Profile Actions
  Future<void> updateProfile(UserProfileModel updated) async {
    _profile = updated;
    await _repo.saveProfile(_profile);
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.saveUserProfile(user.uid, updated);
      if (updated.name.isNotEmpty && updated.name != user.displayName) {
        try {
          await user.updateDisplayName(updated.name);
        } catch (_) {}
      }
    }
  }

  // Reset
  Future<void> resetAllData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      for (final tx in _transactions) {
        await _firestoreService.deleteTransaction(user.uid, tx.id);
      }
      for (final b in _budgets) {
        await _firestoreService.deleteBudget(user.uid, b.id);
      }
      final cleanProfile = UserProfileModel(
        name: user.displayName ?? 'Pengguna FinTrack',
        email: user.email ?? '',
        occupation: '',
        avatarUrl: user.photoURL,
      );
      await _firestoreService.saveUserProfile(user.uid, cleanProfile);
      _profile = cleanProfile;
    }
    await _repo.resetData();
    _transactions = [];
    _budgets = [];
    if (user == null) {
      _profile = SampleData.initialProfile;
    }
    notifyListeners();
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
