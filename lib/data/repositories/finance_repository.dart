import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/user_profile_model.dart';
import 'sample_data.dart';

class FinanceRepository {
  static const String _transactionsKey = 'fintrack_transactions';
  static const String _budgetsKey = 'fintrack_budgets';
  static const String _profileKey = 'fintrack_user_profile';
  static const String _firstLaunchKey = 'fintrack_first_launch_done';

  final SharedPreferences _prefs;

  FinanceRepository(this._prefs);

  static Future<FinanceRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    final repo = FinanceRepository(prefs);
    await repo.initDefaultDataIfFirstLaunch();
    return repo;
  }

  Future<void> initDefaultDataIfFirstLaunch() async {
    final isInitialized = _prefs.getBool(_firstLaunchKey) ?? false;
    if (!isInitialized) {
      await saveTransactions([]);
      await saveBudgets([]);
      await saveProfile(SampleData.initialProfile);
      await _prefs.setBool(_firstLaunchKey, true);
    }
  }

  // Transactions
  List<TransactionModel> getTransactions() {
    final rawList = _prefs.getStringList(_transactionsKey);
    if (rawList == null || rawList.isEmpty) {
      return [];
    }
    try {
      final list = rawList
          .map(
            (item) => TransactionModel.fromMap(
              jsonDecode(item) as Map<String, dynamic>,
            ),
          )
          .toList();
      if (list.any((t) => t.id.startsWith('tx') && t.title == 'Gaji Bulanan - UI/UX Designer')) {
        return [];
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    final encoded = transactions.map((tx) => jsonEncode(tx.toMap())).toList();
    await _prefs.setStringList(_transactionsKey, encoded);
  }

  // Budgets
  List<BudgetModel> getBudgets() {
    final rawList = _prefs.getStringList(_budgetsKey);
    if (rawList == null || rawList.isEmpty) {
      return [];
    }
    try {
      final list = rawList
          .map(
            (item) =>
                BudgetModel.fromMap(jsonDecode(item) as Map<String, dynamic>),
          )
          .toList();
      if (list.any((b) => b.id.startsWith('b') && b.name == 'Kuliner & Kopi')) {
        return [];
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBudgets(List<BudgetModel> budgets) async {
    final encoded = budgets.map((b) => jsonEncode(b.toMap())).toList();
    await _prefs.setStringList(_budgetsKey, encoded);
  }

  // Profile
  UserProfileModel getProfile() {
    final raw = _prefs.getString(_profileKey);
    if (raw == null) {
      return SampleData.initialProfile;
    }
    try {
      final profile = UserProfileModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
      if (profile.name == 'Rifki Pratama' || profile.email == 'rifki.pratama@gmail.com') {
        return SampleData.initialProfile;
      }
      return profile;
    } catch (_) {
      return SampleData.initialProfile;
    }
  }

  Future<void> saveProfile(UserProfileModel profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile.toMap()));
  }

  // Reset to initial clean state
  Future<void> resetData() async {
    await _prefs.remove(_transactionsKey);
    await _prefs.remove(_budgetsKey);
    await _prefs.remove(_profileKey);
    await _prefs.remove(_firstLaunchKey);
    await saveTransactions([]);
    await saveBudgets([]);
    await saveProfile(SampleData.initialProfile);
  }
}
