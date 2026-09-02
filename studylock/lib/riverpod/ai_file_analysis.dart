import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studylock/api/ai_functions.dart';

class SelectedFileNotifier extends Notifier<PlatformFile?> {
  void setFile(PlatformFile file) {
    state = file;
  }

  void clearFile() {
    state = null;
  }

  @override
  PlatformFile? build() {
    return null;
  }
}

final selectedFileProvider =
    NotifierProvider<SelectedFileNotifier, PlatformFile?>(
      SelectedFileNotifier.new,
    );

class AiFileAnalysis extends Notifier<String> {
  Future<void> uploadFileCall() async {
    final file = ref.read(selectedFileProvider);

    if (file == null) {
      state = 'Please select a file first';
      return;
    }

    state = 'Uploading...';

    // Call api
    final aiService = AiFunctions();
    final result = await aiService.uploadfile(file);

    state = result;
  }

  @override
  String build() {
    return '';
  }
}

final aiFileAnalysisProvider = NotifierProvider<AiFileAnalysis, String>(
  AiFileAnalysis.new,
);
