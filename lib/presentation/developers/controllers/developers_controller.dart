import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../models/developer_models.dart';

class DevelopersController extends GetxController {
  static DevelopersController get instance =>
      GetInstance().putOrFind(() => DevelopersController());

  static const String dataUrl =
      'https://raw.githubusercontent.com/alheekmahlib/data/main/websites/alheekmah_web/developers.json';

  bool isLoading = true;
  String? errorMessage;
  DeveloperContent? content;

  @override
  void onInit() {
    super.onInit();
    fetchContent();
  }

  Future<void> fetchContent() async {
    isLoading = true;
    errorMessage = null;
    update();

    try {
      final response = await http.get(
        Uri.parse(dataUrl),
        headers: const {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        content = DeveloperContent.fromJson(jsonData);
      } else {
        errorMessage = 'errorLoadingData';
        debugPrint(
            'Developers data status: ${response.statusCode} body: ${response.body}');
      }
    } catch (e) {
      errorMessage = 'errorLoadingData';
      debugPrint('Developers data error: $e');
    }

    isLoading = false;
    update();
  }

  Future<void> openUrl(String url) async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
