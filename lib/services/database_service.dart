import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/transaction.dart' as model;

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  // --- Transactions ---

  Future<void> addTransaction(model.Transaction txn) async {
    await _db.child('transactions').child(txn.id).set(txn.toMap());
  }

  Future<void> updateTransaction(model.Transaction txn) async {
    await _db.child('transactions').child(txn.id).update(txn.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await _db.child('transactions').child(id).remove();
  }

  Stream<List<model.Transaction>> get transactionsStream {
    return _db.child('transactions').onValue.map((event) {
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
    await _db.child('groups').child(id).set(groupData);
  }

  Future<void> deleteGroup(String id) async {
    await _db.child('groups').child(id).remove();
  }

  Stream<List<Map<String, dynamic>>> get groupsStream {
    return _db.child('groups').onValue.map((event) {
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
    await _db.child('categories').child(id).set(categoryData);
  }

  Stream<List<Map<String, dynamic>>> get categoriesStream {
    return _db.child('categories').onValue.map((event) {
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
    // Optional: Seed default categories if needed
  }
}
