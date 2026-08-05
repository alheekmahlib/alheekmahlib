import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

typedef _JsonResult = Future<String?>;

_JsonResult pickJsonFile() async {
  final input = html.FileUploadInputElement()..accept = 'application/json';
  input.click();
  await input.onChange.first;
  if (input.files == null || input.files!.isEmpty) {
    return null;
  }
  final file = input.files!.first;
  final reader = html.FileReader();
  final completer = Completer<String?>();
  reader.onLoad.listen((_) {
    completer.complete(reader.result?.toString());
  });
  reader.onError.listen((_) {
    completer.complete(null);
  });
  reader.readAsText(file);
  return completer.future;
}

void downloadJson({required String filename, required String content}) {
  final blob = html.Blob([content], 'application/json');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
