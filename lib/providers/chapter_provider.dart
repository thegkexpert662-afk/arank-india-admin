import 'dart:async';

import 'package:flutter/material.dart';
import '../models/chapter_model.dart';
import '../services/chapter_service.dart';

class ChapterProvider extends ChangeNotifier {
  final ChapterService _service = ChapterService();

  List<ChapterModel> _chapters = [];
  bool _isLoading = false;

  StreamSubscription<List<ChapterModel>>? _subscription;

  List<ChapterModel> get chapters => _chapters;
  bool get isLoading => _isLoading;

  void loadChapters(String subjectId) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();

    _subscription = _service.getChapters(subjectId).listen(
          (data) {
        _chapters = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Chapter Error: $e");
        _chapters = [];
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addChapter(ChapterModel chapter) async {
    await _service.addChapter(chapter);
  }

  Future<void> updateChapter(ChapterModel chapter) async {
    await _service.updateChapter(chapter);
  }

  Future<void> deleteChapter(
      String subjectId,
      String chapterId,
      ) async {
    await _service.deleteChapter(subjectId, chapterId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}