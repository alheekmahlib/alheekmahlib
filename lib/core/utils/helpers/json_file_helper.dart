import 'json_file_helper_stub.dart'
    if (dart.library.html) 'json_file_helper_web.dart' as impl;

class JsonFileHelper {
  static Future<String?> pickJsonFile() => impl.pickJsonFile();

  static void downloadJson({
    required String filename,
    required String content,
  }) {
    impl.downloadJson(filename: filename, content: content);
  }
}
