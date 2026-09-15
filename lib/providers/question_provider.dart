import 'dart:async';
import '../models/question_model.dart';
import 'package:flutter/material.dart';
import '../services/question_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'dart:typed_data';


class QuestionProvider extends ChangeNotifier {
  final QuestionService _service = QuestionService();

  List<QuestionModel> _questions = [];
  bool _isLoading = false;

  StreamSubscription<List<QuestionModel>>? _subscription;

  List<QuestionModel> get questions => _questions;
  bool get isLoading => _isLoading;

  void loadQuestions(
      String subjectId,
      String chapterId,
      ) {
    _isLoading = true;
    notifyListeners();

    _subscription?.cancel();

    _subscription = _service
        .getQuestions(subjectId, chapterId)
        .listen(
          (data) {
        _questions = data;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint("Question Error: $e");
        _questions = [];
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addQuestion(
      QuestionModel question,
      ) async {
    await _service.addQuestion(question);
  }

  Future<void> updateQuestion(
      QuestionModel question,
      ) async {
    await _service.updateQuestion(question);
  }

  Future<void> deleteQuestion(
      String subjectId,
      String chapterId,
      String questionId,
      ) async {
    await _service.deleteQuestion(
      subjectId,
      chapterId,
      questionId,
    );
  }
  Future<void> importExcel({
    required String subjectId,
    required String chapterId,
    required BuildContext context,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result == null) return;

    Uint8List bytes = result.files.first.bytes!;

    final decoder = SpreadsheetDecoder.decodeBytes(
      bytes,
      update: false,
    );

    int imported = 0;

    for (final sheet in decoder.tables.values) {
      bool firstRow = true;

      for (final row in sheet.rows) {
        if (firstRow) {
          firstRow = false;
          continue;
        }

        final question = QuestionModel(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          subjectId: subjectId,
          chapterId: chapterId,

          mockTestId: "",   // नया
          subject: "",         // नया

          question: row[0]?.value.toString() ?? "",
          optionA: row[1]?.value.toString() ?? "",
          optionB: row[2]?.value.toString() ?? "",
          optionC: row[3]?.value.toString() ?? "",
          optionD: row[4]?.value.toString() ?? "",
          correctAnswer: row[5]?.value.toString() ?? "",
          explanation: row[6]?.value.toString() ?? "",
          difficulty: row[7]?.value.toString() ?? "Easy",
          marks: int.tryParse(row[8]?.value.toString() ?? "1") ?? 1,
          negativeMarks:
          double.tryParse(row[9]?.value.toString() ?? "0") ?? 0,
          isActive: true,
        );

        await _service.addQuestion(question);
        imported++;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$imported Questions Imported Successfully"),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}