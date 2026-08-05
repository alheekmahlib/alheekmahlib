import 'package:get/get.dart';

import '../models/developer_models.dart';

/// Returns the localized text based on the current locale.
///
/// If the current locale is Arabic ('ar'), returns the Arabic text if available,
/// otherwise falls back to English. For other locales, returns English text if
/// available, otherwise falls back to Arabic.
String localizedText(LocalizedText text) {
  final locale = Get.locale?.languageCode ?? 'en';
  if (locale == 'ar') {
    return text.ar.isNotEmpty ? text.ar : text.en;
  }
  return text.en.isNotEmpty ? text.en : text.ar;
}
