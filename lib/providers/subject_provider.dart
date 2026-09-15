import 'dart:async';

import 'package:flutter/material.dart';
import '../models/subject_model.dart';
import '../services/subject_service.dart';

class SubjectProvider extends ChangeNotifier {
  final SubjectService _service = SubjectService();

  List<SubjectModel> _subjects = [];
  bool _isLoading = false;

  StreamSubscription<List<SubjectModel>>? _subscription;

  List<SubjectModel> get subjects => _subjects;
  bool get isLoading => _isLoading;

  void loadSubjects() {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();

    _subscription = _service.getSubjects().listen(
          (data) {
        _subjects = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Firestore Error: $e");
        _subjects = [];
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addSubject(SubjectModel subject) async {
    await _service.addSubject(subject);
  }

  Future<void> updateSubject(SubjectModel subject) async {
    await _service.updateSubject(subject);
  }

  Future<void> deleteSubject(String id) async {
    await _service.deleteSubject(id);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}