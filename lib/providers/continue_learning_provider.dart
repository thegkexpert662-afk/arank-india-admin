import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/continue_learning_model.dart';

class ContinueLearningProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  List<ContinueLearningModel> _items = [];
  bool _loading = false;

  List<ContinueLearningModel> get items => _items;
  bool get loading => _loading;

  void load() {
    _loading = true;
    notifyListeners();
    _sub?.cancel();
    _sub = _db.collection('continue_learning').snapshots().listen((snap) {
      _items = snap.docs.map(ContinueLearningModel.fromDoc).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _loading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Continue Learning error: $e');
      _items = [];
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> save(ContinueLearningModel item) async {
    final data = item.toMap();
    if (item.id.isEmpty) {
      await _db.collection('continue_learning').add(data);
    } else {
      await _db.collection('continue_learning').doc(item.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> delete(String id) => _db.collection('continue_learning').doc(id).delete();

  Future<void> toggle(String id, bool value) =>
      _db.collection('continue_learning').doc(id).update({'isActive': value, 'updatedAt': FieldValue.serverTimestamp()});

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
