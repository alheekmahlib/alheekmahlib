import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/developer_models.dart';

class ApiDetailsController extends GetxController {
  ApiDetailsController({required this.api});

  static const String _proxyPathPrefix = '/proxy';

  final DeveloperItem api;
  final Map<String, dynamic> responses = {};
  final Map<String, bool> loading = {};
  final Map<String, String> errors = {};
  final Map<String, TextEditingController> _paramControllers = {};
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool issuingToken = false;
  bool requestingOtp = false;
  String _otpChallenge = '';

  String get _apiKeyStorageKey => 'apiKey_${api.id}';
  String get _emailStorageKey => 'apiEmail_${api.id}';

  @override
  void onInit() {
    super.onInit();
    apiKeyController.text = _readStorage(_apiKeyStorageKey);
    emailController.text = _readStorage(_emailStorageKey);

    apiKeyController.addListener(() {
      _writeStorage(_apiKeyStorageKey, apiKeyController.text.trim());
    });
    emailController.addListener(() {
      _writeStorage(_emailStorageKey, emailController.text.trim());
    });
    otpController.addListener(update);
  }

  @override
  void onClose() {
    for (final controller in _paramControllers.values) {
      controller.dispose();
    }
    apiKeyController.dispose();
    emailController.dispose();
    otpController.dispose();
    super.onClose();
  }

  TextEditingController getParamController(String key) {
    return _paramControllers.putIfAbsent(key, TextEditingController.new);
  }

  List<String> extractParams(String path) {
    final regex = RegExp(r'\{(\w+)\}');
    final params = regex.allMatches(path).map((m) => m.group(1)!).toList();
    return params.toSet().toList();
  }

  Future<void> testEndpoint(DeveloperEndpoint endpoint) async {
    final key = '${endpoint.method}_${endpoint.path}';
    final params = extractParams(endpoint.path);
    final paramValues = <String, String>{};

    final missingParams = <String>[];
    for (final param in params) {
      final value = _paramControllers[param]?.text.trim() ?? '';
      if (value.isEmpty) {
        missingParams.add(param);
      } else {
        paramValues[param] = value;
      }
    }

    if (missingParams.isNotEmpty) {
      loading[key] = false;
      errors[key] = 'يرجى إدخال قيمة لـ: ${missingParams.join(', ')}';
      update();
      return;
    }

    loading[key] = true;
    errors[key] = '';
    update();

    try {
      final url = _buildRequestUrl(endpoint, paramValues);

      final request = await html.HttpRequest.request(
        url,
        method: 'GET',
        requestHeaders: {
          'Accept': 'application/json',
          if (apiKeyController.text.trim().isNotEmpty)
            'Authorization': 'Bearer ${apiKeyController.text.trim()}',
        },
      );

      if (request.status == 200) {
        final responseText = request.responseText ?? '';
        final contentType =
            (request.getResponseHeader('content-type') ?? '').toLowerCase();

        if (contentType.contains('application/json') ||
            responseText.trimLeft().startsWith('{') ||
            responseText.trimLeft().startsWith('[')) {
          try {
            final decoded = jsonDecode(responseText);
            responses[key] = decoded;
            loading[key] = false;
          } catch (_) {
            errors[key] =
                'Response is not valid JSON. Check the /proxy rewrite.';
            loading[key] = false;
          }
        } else {
          final snippet = responseText.trimLeft();
          final preview = snippet.length > 120
              ? '${snippet.substring(0, 120)}...'
              : snippet;
          errors[key] = 'Proxy returned non-JSON response. $preview';
          loading[key] = false;
        }
      } else {
        errors[key] = 'Error ${request.status}: ${request.statusText}';
        loading[key] = false;
      }
    } catch (e) {
      var errorMessage = 'Error: $e';
      if (e is html.ProgressEvent) {
        final target = e.target as html.HttpRequest;
        if (target.status == 0) {
          errorMessage =
              'Network error: CORS policy may be blocking the request';
        } else {
          errorMessage = 'HTTP ${target.status}: ${target.statusText}';
        }
      }
      errors[key] = errorMessage;
      loading[key] = false;
    }

    update();
  }

  void copyUrl(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('URL copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void copyResponse(BuildContext context, String key) {
    final response = responses[key];
    if (response != null) {
      final jsonString = const JsonEncoder.withIndent('  ').convert(response);
      Clipboard.setData(ClipboardData(text: jsonString));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Response copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> requestOtp(BuildContext context) async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال البريد الإلكتروني'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    requestingOtp = true;
    update();

    try {
      final url = _buildAuthRequestUrl();
      final request = await html.HttpRequest.request(
        url,
        method: 'POST',
        requestHeaders: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        sendData: jsonEncode({'email': email}),
      );

      if (request.status == 200) {
        final decoded = jsonDecode(request.responseText ?? '{}');
        final challenge =
            decoded is Map<String, dynamic> ? decoded['challenge'] : null;
        if (challenge is String && challenge.isNotEmpty) {
          _otpChallenge = challenge;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إرسال كود OTP للبريد'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر قراءة التحدي من الاستجابة'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final details = _formatErrorDetails(request);
        debugPrint('OTP request failed: $details');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(details),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('OTP request error: ${_formatException(e)}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${_formatException(e)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    requestingOtp = false;
    update();
  }

  Future<void> issueToken(BuildContext context) async {
    final email = emailController.text.trim();
    final code = otpController.text.trim();
    if (email.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إدخال البريد وكود OTP'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    if (_otpChallenge.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى طلب كود OTP أولا'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    issuingToken = true;
    update();

    try {
      final url = _buildAuthIssueUrl();
      final request = await html.HttpRequest.request(
        url,
        method: 'POST',
        requestHeaders: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        sendData: jsonEncode({
          'email': email,
          'code': code,
          'challenge': _otpChallenge,
        }),
      );

      if (request.status == 200) {
        final decoded = jsonDecode(request.responseText ?? '{}');
        final token = decoded is Map<String, dynamic> ? decoded['token'] : null;
        if (token is String && token.isNotEmpty) {
          apiKeyController.text = token;
          otpController.clear();
          _otpChallenge = '';
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء التوكن وحفظه محليا'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تعذر قراءة التوكن من الاستجابة'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        final details = _formatErrorDetails(request);
        debugPrint('Issue token failed: $details');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(details),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Issue token error: ${_formatException(e)}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${_formatException(e)}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    issuingToken = false;
    update();
  }

  String _buildRequestUrl(
    DeveloperEndpoint endpoint,
    Map<String, String> paramValues,
  ) {
    final baseUri = Uri.tryParse(api.baseUrl);
    if (baseUri == null) {
      return '${api.baseUrl}${_applyTemplate(endpoint.path, paramValues)}';
    }

    final templatedPath = _applyTemplate(endpoint.path, paramValues);
    final templatedUri = Uri.parse(templatedPath);
    final resolvedPath = _joinPaths(baseUri.path, templatedUri.path);

    final origin = html.window.location.origin;
    final isSameOrigin = origin == baseUri.origin;
    final isLocalDev = origin.contains('localhost') ||
        origin.contains('127.0.0.1') ||
        origin.contains('0.0.0.0');

    if (origin.isNotEmpty && !isSameOrigin && !isLocalDev) {
      final proxyBase = Uri.parse(origin);
      return proxyBase
          .replace(
            path: '$_proxyPathPrefix$resolvedPath',
            query: templatedUri.hasQuery ? templatedUri.query : null,
          )
          .toString();
    }

    return baseUri
        .replace(
          path: resolvedPath,
          query: templatedUri.hasQuery ? templatedUri.query : null,
        )
        .toString();
  }

  String _buildAuthRequestUrl() {
    final baseUri = Uri.tryParse(api.baseUrl);
    if (baseUri == null) {
      return '${api.baseUrl}/auth/request';
    }
    return baseUri
        .replace(path: _joinPaths(baseUri.path, '/auth/request'))
        .toString();
  }

  String _buildAuthIssueUrl() {
    final baseUri = Uri.tryParse(api.baseUrl);
    if (baseUri == null) {
      return '${api.baseUrl}/auth/issue';
    }
    return baseUri
        .replace(path: _joinPaths(baseUri.path, '/auth/issue'))
        .toString();
  }

  String _applyTemplate(String template, Map<String, String> values) {
    var result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', Uri.encodeComponent(value));
    });
    return result;
  }

  String _joinPaths(String basePath, String endpointPath) {
    final trimmedBase = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final trimmedEndpoint =
        endpointPath.startsWith('/') ? endpointPath.substring(1) : endpointPath;

    if (trimmedBase.isEmpty) {
      return '/$trimmedEndpoint';
    }
    return '$trimmedBase/$trimmedEndpoint';
  }

  String _readStorage(String key) {
    return html.window.localStorage[key] ?? '';
  }

  void _writeStorage(String key, String value) {
    if (value.isEmpty) {
      html.window.localStorage.remove(key);
    } else {
      html.window.localStorage[key] = value;
    }
  }

  String _formatErrorDetails(html.HttpRequest request) {
    final status = request.status;
    final statusText = request.statusText ?? '';
    final body = (request.responseText ?? '').trim();
    if (body.isEmpty) {
      return 'Error $status: $statusText';
    }
    if (body.startsWith('{') || body.startsWith('[')) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
          return 'Error $status: $statusText - ${decoded['detail']}';
        }
      } catch (_) {}
    }
    final preview = body.length > 180 ? '${body.substring(0, 180)}...' : body;
    return 'Error $status: $statusText - $preview';
  }

  String _formatException(Object e) {
    if (e is html.ProgressEvent) {
      final target = e.target;
      if (target is html.HttpRequest) {
        final status = target.status;
        final statusText = target.statusText ?? '';
        final body = (target.responseText ?? '').trim();
        final preview =
            body.length > 180 ? '${body.substring(0, 180)}...' : body;
        if (body.isNotEmpty) {
          return 'HTTP $status: $statusText - $preview';
        }
        return 'HTTP $status: $statusText';
      }
      return 'Network error: ProgressEvent';
    }
    return e.toString();
  }
}
