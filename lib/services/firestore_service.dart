import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/models/user_profile_model.dart';
import '../data/models/transaction_model.dart';
import '../data/models/budget_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  // -------------------------------------------------------------
  // USER PROFILE
  // -------------------------------------------------------------
  Future<UserProfileModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfileModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Firestore getUserProfile error: $e');
      return null;
    }
  }

  Future<void> saveUserProfile(String uid, UserProfileModel profile) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        ...profile.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveUserProfile error: $e');
    }
  }

  // -------------------------------------------------------------
  // TRANSACTIONS
  // -------------------------------------------------------------
  Future<List<TransactionModel>> getTransactions(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Firestore getTransactions error: $e');
      return [];
    }
  }

  Future<void> saveTransaction(String uid, TransactionModel tx) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(tx.id)
          .set(tx.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveTransaction error: $e');
    }
  }

  Future<void> deleteTransaction(String uid, String txId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(txId)
          .delete();
    } catch (e) {
      debugPrint('Firestore deleteTransaction error: $e');
    }
  }

  // -------------------------------------------------------------
  // BUDGETS
  // -------------------------------------------------------------
  Future<List<BudgetModel>> getBudgets(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .get();

      return snapshot.docs
          .map((doc) => BudgetModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Firestore getBudgets error: $e');
      return [];
    }
  }

  Future<void> saveBudget(String uid, BudgetModel budget) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .doc(budget.id)
          .set(budget.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore saveBudget error: $e');
    }
  }

  Future<void> deleteBudget(String uid, String budgetId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .doc(budgetId)
          .delete();
    } catch (e) {
      debugPrint('Firestore deleteBudget error: $e');
    }
  }
}
