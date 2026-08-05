import 'package:flutter/material.dart';
import 'package:flutter_json_view/flutter_json_view.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../controllers/api_details_controller.dart';
import '../../models/developer_models.dart';
import '../../utils/localization_helper.dart';

/// A panel displaying detailed information about an API with interactive testing.
///
/// Shows the API title, description, base URL, version, documentation link,
/// and a list of available endpoints with try-it functionality.
class ApiDetailsPanel extends StatelessWidget {
  /// Creates an [ApiDetailsPanel].
  const ApiDetailsPanel({
    super.key,
    required this.api,
    required this.onClose,
  });

  /// The API item to display details for.
  final DeveloperItem api;

  /// Callback to close the panel.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ApiDetailsController>(tag: api.id)) {
      Get.put(ApiDetailsController(api: api), tag: api.id);
    }
    final scheme = Theme.of(context).colorScheme;

    return GetBuilder<ApiDetailsController>(
      tag: api.id,
      builder: (state) {
        return Material(
          type: MaterialType.transparency,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Column(
              children: [
                // Header with close button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizedText(api.title),
                          style: const TextStyle(
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          onClose();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.close, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizedText(api.description),
                          style: TextStyle(
                            fontFamily: 'cairo',
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.link, size: 16, color: scheme.primary),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  api.baseUrl,
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    state.copyUrl(context, api.baseUrl),
                                icon: const Icon(Icons.copy, size: 16),
                              ),
                            ],
                          ),
                        ),
                        if (api.version.isNotEmpty) ...[
                          const Gap(6),
                          Text(
                            '${'developers_version'.tr} ${api.version}',
                            style: TextStyle(
                              fontFamily: 'cairo',
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const Gap(12),
                        Text(
                          'CreateAnAPIKey'.tr,
                          style: TextStyle(
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                          ),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email'.tr,
                                style: TextStyle(
                                  fontFamily: 'cairo',
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const Gap(8),
                              TextField(
                                controller: state.emailController,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'email@example.com',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: scheme.outlineVariant,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Text(
                                'OTP',
                                style: TextStyle(
                                  fontFamily: 'cairo',
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const Gap(8),
                              TextField(
                                controller: state.otpController,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: '123456',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: scheme.outlineVariant,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: state.requestingOtp
                                          ? null
                                          : () => state.requestOtp(context),
                                      icon: state.requestingOtp
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.mail, size: 18),
                                      label: Text(
                                        state.requestingOtp
                                            ? 'Sending...'.tr
                                            : 'send OTP'.tr,
                                        style: const TextStyle(
                                            fontFamily: 'cairo'),
                                      ),
                                    ),
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: state.issuingToken
                                          ? null
                                          : state.otpController.text
                                                  .trim()
                                                  .isEmpty
                                              ? null
                                              : () => state.issueToken(context),
                                      icon: state.issuingToken
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.key, size: 18),
                                      label: Text(
                                        state.issuingToken
                                            ? 'Creating...'.tr
                                            : 'create token'.tr,
                                        style: const TextStyle(
                                            fontFamily: 'cairo'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'API Key',
                                style: TextStyle(
                                  fontFamily: 'cairo',
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const Gap(8),
                              TextField(
                                controller: state.apiKeyController,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Bearer token',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: scheme.outlineVariant,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(12),
                        // if (api.docsUrl.isNotEmpty)
                        //   ActionButton(
                        //     icon: Icons.article_outlined,
                        //     label: 'developers_docs'.tr,
                        //     onTap: () => ctrl.openUrl(api.docsUrl),
                        //   ),
                        // const Gap(16),
                        Text(
                          'developers_endpoints'.tr,
                          style: const TextStyle(
                            fontFamily: 'cairo',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const Gap(8),
                        ...api.endpoints.map((endpoint) {
                          final key = '${endpoint.method}_${endpoint.path}';
                          final pathParams = state.extractParams(endpoint.path);
                          final fullUrl = '${api.baseUrl}${endpoint.path}';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: scheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: scheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Endpoint header
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: scheme.surfaceContainerLowest,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _getMethodColor(endpoint.method)
                                                  .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          endpoint.method,
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: _getMethodColor(
                                                endpoint.method),
                                          ),
                                        ),
                                      ),
                                      const Gap(12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              endpoint.path,
                                              style: const TextStyle(
                                                fontFamily: 'monospace',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                            if (localizedText(endpoint.summary)
                                                .isNotEmpty) ...[
                                              const Gap(4),
                                              Text(
                                                localizedText(endpoint.summary),
                                                style: TextStyle(
                                                  fontFamily: 'cairo',
                                                  fontSize: 12,
                                                  color:
                                                      scheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // URL display with copy button
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            fullUrl,
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              state.copyUrl(context, fullUrl),
                                          icon: const Icon(
                                            Icons.copy,
                                            size: 16,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Path parameters input
                                if (pathParams.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: pathParams.map((param) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 8),
                                          child: TextField(
                                            controller:
                                                state.getParamController(param),
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 13,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: param,
                                              labelStyle: TextStyle(
                                                fontFamily: 'cairo',
                                                fontSize: 12,
                                                color: scheme.onSurfaceVariant,
                                              ),
                                              hintText: 'Enter $param',
                                              hintStyle: TextStyle(
                                                fontFamily: 'monospace',
                                                fontSize: 12,
                                                color: scheme.onSurfaceVariant
                                                    .withValues(alpha: 0.5),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                borderSide: BorderSide(
                                                  color: scheme.outlineVariant,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                // Try it button
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: state.loading[key] == true
                                          ? null
                                          : () => state.testEndpoint(endpoint),
                                      icon: state.loading[key] == true
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.play_arrow,
                                              size: 18),
                                      label: Text(
                                        state.loading[key] == true
                                            ? 'Testing...'
                                            : 'Try it',
                                        style: const TextStyle(
                                            fontFamily: 'cairo'),
                                      ),
                                    ),
                                  ),
                                ),
                                // Error display
                                if (state.errors[key]?.isNotEmpty == true)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: scheme.errorContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          size: 16,
                                          color: scheme.error,
                                        ),
                                        const Gap(8),
                                        Expanded(
                                          child: Text(
                                            state.errors[key]!,
                                            style: TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 11,
                                              color: scheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                // Response display
                                if (state.responses[key] != null) ...[
                                  const Gap(8),
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1E1E),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Response header
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_circle,
                                                size: 16,
                                                color: Colors.green,
                                              ),
                                              const Gap(8),
                                              const Text(
                                                'Response',
                                                style: TextStyle(
                                                  fontFamily: 'cairo',
                                                  fontSize: 12,
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () => state
                                                    .copyResponse(context, key),
                                                icon: const Icon(
                                                  Icons.copy,
                                                  size: 16,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Response body
                                        Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: _buildJsonView(
                                                state.responses[key],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const Gap(12),
                              ],
                            ),
                          );
                        }),
                        const Gap(32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildJsonView(dynamic data) {
    const theme = JsonViewTheme(
      keyStyle: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      stringStyle: TextStyle(color: Colors.lightBlue),
      intStyle: TextStyle(color: Colors.orange),
      boolStyle: TextStyle(color: Colors.red),
    );

    if (data is Map<String, dynamic>) {
      return JsonView.map(data, theme: theme);
    }
    if (data is List<dynamic>) {
      return JsonView.map({'data': data}, theme: theme);
    }
    return Text(
      data?.toString() ?? '',
      style: const TextStyle(color: Colors.white),
    );
  }
}
