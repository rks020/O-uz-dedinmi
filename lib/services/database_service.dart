import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/transaction.dart' as model;

class DatabaseService {
  final String userId;
  late final DatabaseReference _userRef;

  DatabaseService(this.userId) {
    _userRef = FirebaseDatabase.instance.ref().child('users').child(userId);
  }

  // --- Transactions ---

  Future<void> addTransaction(model.Transaction txn) async {
    await _userRef.child('transactions').child(txn.id).set(txn.toMap());
  }

  Future<void> updateTransaction(model.Transaction txn) async {
    await _userRef.child('transactions').child(txn.id).update(txn.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await _userRef.child('transactions').child(id).remove();
  }

  Stream<List<model.Transaction>> get transactionsStream {
    return _userRef.child('transactions').onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      try {
        final Map<dynamic, dynamic> data =
            snapshot.value as Map<dynamic, dynamic>;

        return data.entries.map((e) {
          final val = Map<String, dynamic>.from(e.value as Map);
          val['id'] = e.key;
          return model.Transaction.fromMap(val);
        }).toList();
      } catch (e) {
        debugPrint("Error parsing transactions: $e");
        return [];
      }
    });
  }

  // --- Groups ---

  Future<void> createGroup(Map<String, dynamic> groupData) async {
    final id = groupData['id'];
    await _userRef.child('groups').child(id).set(groupData);
  }

  Future<void> deleteGroup(String id) async {
    await _userRef.child('groups').child(id).remove();
  }

  Stream<List<Map<String, dynamic>>> get groupsStream {
    return _userRef.child('groups').onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      try {
        final Map<dynamic, dynamic> data =
            snapshot.value as Map<dynamic, dynamic>;

        return data.entries.map((e) {
          final val = Map<String, dynamic>.from(e.value as Map);
          val['id'] = e.key;
          return val;
        }).toList();
      } catch (e) {
        debugPrint("Error parsing groups: $e");
        return [];
      }
    });
  }

  // --- Categories ---

  Future<void> addCategory(Map<String, dynamic> categoryData) async {
    final id = categoryData['id'];
    await _userRef.child('categories').child(id).set(categoryData);
  }

  Stream<List<Map<String, dynamic>>> get categoriesStream {
    return _userRef.child('categories').onValue.map((event) {
      final snapshot = event.snapshot;
      if (snapshot.value == null) return [];

      try {
        final Map<dynamic, dynamic> data =
            snapshot.value as Map<dynamic, dynamic>;

        return data.entries.map((e) {
          final val = Map<String, dynamic>.from(e.value as Map);
          val['id'] = e.key;
          return val;
        }).toList();
      } catch (e) {
        debugPrint("Error parsing categories: $e");
        return [];
      }
    });
  }

  Future<void> initializeCategories() async {
    final List<Map<String, dynamic>> defaultCategories = [
      // Income
      {'id': 'inc_maas', 'name': 'Maaş', 'colorValue': 0xFFF59E0B, 'type': 'income'},
      {'id': 'inc_bonus', 'name': 'Bonus', 'colorValue': 0xFF10B981, 'type': 'income'},
      {'id': 'inc_diger_i', 'name': 'Diğer', 'colorValue': 0xFF6B7280, 'type': 'income'},
      // Expense
      {'id': 'exp_kira', 'name': 'Kira', 'colorValue': 0xFFEF4444, 'type': 'expense'},
      {'id': 'exp_market', 'name': 'Market', 'colorValue': 0xFF3B82F6, 'type': 'expense'},
      {'id': 'exp_faturalar', 'name': 'Faturalar', 'colorValue': 0xFF8B5CF6, 'type': 'expense'},
      {'id': 'exp_diger_e', 'name': 'Diğer', 'colorValue': 0xFF94A3B8, 'type': 'expense'},
    ];

    for (var cat in defaultCategories) {
      final catRef = _userRef.child('categories').child(cat['id']);
      final snapshot = await catRef.get();
      if (!snapshot.exists) {
        await catRef.set(cat);
      } else {
        // Optional: Update color/name if they are crucial and might be outdated? 
        // For now, just ensure existence.
      }
    }
  }
}
