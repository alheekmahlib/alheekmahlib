import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../core/utils/helpers/json_file_helper.dart';
import '../controllers/developers_controller.dart';
import '../models/developer_models.dart';

class DevelopersDashboardScreen extends StatefulWidget {
  const DevelopersDashboardScreen({super.key});

  @override
  State<DevelopersDashboardScreen> createState() =>
      _DevelopersDashboardScreenState();
}

class _DevelopersDashboardScreenState extends State<DevelopersDashboardScreen> {
  final List<DeveloperSection> _sections = [];
  int _selectedIndex = 0;
  String? _statusMessage;
  bool _statusIsError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFromUrl();
  }

  Future<void> _loadFromUrl() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(DevelopersController.dataUrl),
        headers: const {'Accept': 'application/json'},
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _applyJson(response.body);
        _setStatus('developers_json_loaded'.tr, isError: false);
      } else {
        _setStatus('developers_json_invalid'.tr, isError: true);
      }
    } catch (_) {
      if (!mounted) return;
      _setStatus('developers_json_invalid'.tr, isError: true);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importJson() async {
    final content = await JsonFileHelper.pickJsonFile();
    if (!mounted) return;
    if (content == null || content.trim().isEmpty) {
      _setStatus('developers_json_empty'.tr, isError: true);
      return;
    }
    _applyJson(content);
    _setStatus('developers_json_loaded'.tr, isError: false);
  }

  void _applyJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        _setStatus('developers_json_invalid'.tr, isError: true);
        return;
      }
      final parsed = DeveloperContent.fromJson(decoded);
      _sections
        ..clear()
        ..addAll(parsed.sections);
      _selectedIndex = _sections.isEmpty ? 0 : 0;
      setState(() {});
    } catch (_) {
      _setStatus('developers_json_invalid'.tr, isError: true);
    }
  }

  void _exportJson() {
    if (_sections.isEmpty) {
      _setStatus('developers_json_empty'.tr, isError: true);
      return;
    }
    final content = DeveloperContent(
      updatedAt: _formatDate(DateTime.now()),
      sections: _sections,
    );
    final formatted = const JsonEncoder.withIndent('  ').convert(content);
    JsonFileHelper.downloadJson(
        filename: 'developers.json', content: formatted);
    _setStatus('developers_export_done'.tr, isError: false);
  }

  void _setStatus(String message, {required bool isError}) {
    setState(() {
      _statusMessage = message;
      _statusIsError = isError;
    });
  }

  DeveloperSection? get _currentSection {
    if (_sections.isEmpty || _selectedIndex >= _sections.length) {
      return null;
    }
    return _sections[_selectedIndex];
  }

  void _addSection() async {
    final created = await _showSectionDialog();
    if (created == null) return;
    setState(() {
      _sections.add(created);
      _selectedIndex = _sections.length - 1;
    });
  }

  void _editSection(DeveloperSection section, int index) async {
    final updated = await _showSectionDialog(section: section);
    if (updated == null) return;
    setState(() {
      _sections[index] = updated;
    });
  }

  void _deleteSection(int index) {
    setState(() {
      _sections.removeAt(index);
      if (_selectedIndex >= _sections.length) {
        _selectedIndex = _sections.isEmpty ? 0 : _sections.length - 1;
      }
    });
  }

  void _reorderSections(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _sections.removeAt(oldIndex);
      _sections.insert(newIndex, item);
      _selectedIndex = newIndex;
    });
  }

  void _addItem() async {
    final section = _currentSection;
    if (section == null) return;
    final created = await _showItemDialog(section.type);
    if (created == null) return;
    setState(() {
      section.items.add(created);
    });
  }

  void _editItem(
      DeveloperSection section, DeveloperItem item, int index) async {
    final updated = await _showItemDialog(section.type, item: item);
    if (updated == null) return;
    setState(() {
      section.items[index] = updated;
    });
  }

  void _deleteItem(DeveloperSection section, int index) {
    setState(() {
      section.items.removeAt(index);
    });
  }

  void _reorderItems(DeveloperSection section, int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = section.items.removeAt(oldIndex);
      section.items.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _DashboardTopBar(
          isLoading: _isLoading,
          onReload: _loadFromUrl,
          onImport: _importJson,
          onExport: _exportJson,
        ),
        if (_statusMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _statusMessage!,
                style: TextStyle(
                  fontFamily: 'cairo',
                  color: _statusIsError ? scheme.error : scheme.primary,
                ),
              ),
            ),
          ),
        Expanded(
          child: Row(
            children: [
              _SectionsSidebar(
                sections: _sections,
                selectedIndex: _selectedIndex,
                onSelect: (index) => setState(() => _selectedIndex = index),
                onAdd: _addSection,
                onEdit: _editSection,
                onDelete: _deleteSection,
                onReorder: _reorderSections,
              ),
              Expanded(
                child: _SectionEditor(
                  section: _currentSection,
                  onAddItem: _addItem,
                  onEditItem: _editItem,
                  onDeleteItem: _deleteItem,
                  onReorderItems: _reorderItems,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<DeveloperSection?> _showSectionDialog({DeveloperSection? section}) {
    final slugCtrl = TextEditingController(text: section?.slug ?? '');
    final titleEnCtrl = TextEditingController(text: section?.title.en ?? '');
    final titleArCtrl = TextEditingController(text: section?.title.ar ?? '');
    final descEnCtrl =
        TextEditingController(text: section?.description.en ?? '');
    final descArCtrl =
        TextEditingController(text: section?.description.ar ?? '');
    bool enabled = section?.enabled ?? true;
    String type = section?.type ?? 'libraries';

    return showDialog<DeveloperSection>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            section == null
                ? 'developers_add_section'.tr
                : 'developers_edit_section'.tr,
            style: const TextStyle(fontFamily: 'cairo'),
          ),
          content: StatefulBuilder(builder: (context, setLocal) {
            return SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledField(
                      label: 'developers_section_slug'.tr,
                      child: TextField(controller: slugCtrl),
                    ),
                    const Gap(10),
                    _LabeledField(
                      label: 'developers_section_type'.tr,
                      child: DropdownButtonFormField<String>(
                        initialValue: type,
                        items: const [
                          DropdownMenuItem(
                              value: 'libraries', child: Text('libraries')),
                          DropdownMenuItem(value: 'api', child: Text('api')),
                          DropdownMenuItem(
                              value: 'downloads', child: Text('downloads')),
                          DropdownMenuItem(
                              value: 'generic', child: Text('generic')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setLocal(() => type = value);
                        },
                      ),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Text('developers_enabled'.tr,
                            style: const TextStyle(fontFamily: 'cairo')),
                        const Spacer(),
                        Switch(
                          value: enabled,
                          onChanged: (value) => setLocal(() => enabled = value),
                        ),
                      ],
                    ),
                    const Gap(10),
                    _DualTextFields(
                      label: 'developers_title_label'.tr,
                      enController: titleEnCtrl,
                      arController: titleArCtrl,
                    ),
                    const Gap(10),
                    _DualTextFields(
                      label: 'developers_description_label'.tr,
                      enController: descEnCtrl,
                      arController: descArCtrl,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('developers_cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  DeveloperSection(
                    slug: slugCtrl.text.trim(),
                    enabled: enabled,
                    type: type,
                    title: LocalizedText(
                      en: titleEnCtrl.text.trim(),
                      ar: titleArCtrl.text.trim(),
                    ),
                    description: LocalizedText(
                      en: descEnCtrl.text.trim(),
                      ar: descArCtrl.text.trim(),
                    ),
                    items: section?.items ?? <DeveloperItem>[],
                  ),
                );
              },
              child: Text('developers_save'.tr),
            ),
          ],
        );
      },
    );
  }

  Future<DeveloperItem?> _showItemDialog(String type, {DeveloperItem? item}) {
    final idCtrl = TextEditingController(text: item?.id ?? '');
    final titleEnCtrl = TextEditingController(text: item?.title.en ?? '');
    final titleArCtrl = TextEditingController(text: item?.title.ar ?? '');
    final descEnCtrl = TextEditingController(text: item?.description.en ?? '');
    final descArCtrl = TextEditingController(text: item?.description.ar ?? '');
    final bannerCtrl = TextEditingController(text: item?.bannerUrl ?? '');
    final docsCtrl = TextEditingController(text: item?.docsUrl ?? '');
    final githubCtrl = TextEditingController(text: item?.githubUrl ?? '');
    final downloadCtrl = TextEditingController(text: item?.downloadUrl ?? '');
    final readmeCtrl = TextEditingController(text: item?.readmeUrl ?? '');
    final urlCtrl = TextEditingController(text: item?.url ?? '');
    final baseUrlCtrl = TextEditingController(text: item?.baseUrl ?? '');
    final versionCtrl = TextEditingController(text: item?.version ?? '');
    bool enabled = item?.enabled ?? true;
    final screenshots = List<String>.from(item?.screenshots ?? []);
    final endpoints = List<DeveloperEndpoint>.from(item?.endpoints ?? []);

    return showDialog<DeveloperItem>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            item == null ? 'developers_add_item'.tr : 'developers_edit_item'.tr,
            style: const TextStyle(fontFamily: 'cairo'),
          ),
          content: StatefulBuilder(builder: (context, setLocal) {
            return SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LabeledField(
                      label: 'developers_item_id'.tr,
                      child: TextField(controller: idCtrl),
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Text('developers_enabled'.tr,
                            style: const TextStyle(fontFamily: 'cairo')),
                        const Spacer(),
                        Switch(
                          value: enabled,
                          onChanged: (value) => setLocal(() => enabled = value),
                        ),
                      ],
                    ),
                    const Gap(10),
                    _DualTextFields(
                      label: 'developers_title_label'.tr,
                      enController: titleEnCtrl,
                      arController: titleArCtrl,
                    ),
                    const Gap(10),
                    _DualTextFields(
                      label: 'developers_description_label'.tr,
                      enController: descEnCtrl,
                      arController: descArCtrl,
                      maxLines: 3,
                    ),
                    const Gap(10),
                    if (type == 'libraries') ...[
                      _LabeledField(
                        label: 'developers_banner_url'.tr,
                        child: TextField(controller: bannerCtrl),
                      ),
                      const Gap(10),
                      _LabeledField(
                        label: 'developers_docs_url'.tr,
                        child: TextField(controller: docsCtrl),
                      ),
                      const Gap(10),
                      _LabeledField(
                        label: 'developers_github_url'.tr,
                        child: TextField(controller: githubCtrl),
                      ),
                      const Gap(10),
                      _LabeledField(
                        label: 'developers_download_url'.tr,
                        child: TextField(controller: downloadCtrl),
                      ),
                      const Gap(10),
                      _LabeledField(
                        label: 'developers_readme_url'.tr,
                        child: TextField(controller: readmeCtrl),
                      ),
                      const Gap(10),
                      _ScreenshotsEditor(
                        screenshots: screenshots,
                        onChanged: () => setLocal(() {}),
                      ),
                    ],
                    if (type == 'api') ...[
                      _LabeledField(
                        label: 'developers_base_url_label'.tr,
                        child: TextField(controller: baseUrlCtrl),
                      ),
                      const Gap(10),
                      _LabeledField(
                        label: 'developers_version_label'.tr,
                        child: TextField(controller: versionCtrl),
                      ),
                      const Gap(10),
                      _LabeledField(
                        label: 'developers_docs_url'.tr,
                        child: TextField(controller: docsCtrl),
                      ),
                      const Gap(10),
                      _EndpointsEditor(
                        endpoints: endpoints,
                        onChanged: () => setLocal(() {}),
                      ),
                    ],
                    if (type == 'generic') ...[
                      _LabeledField(
                        label: 'developers_open_url'.tr,
                        child: TextField(controller: urlCtrl),
                      ),
                    ],
                    if (type == 'downloads') ...[
                      _LabeledField(
                        label: 'developers_download_url'.tr,
                        child: TextField(controller: downloadCtrl),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('developers_cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  DeveloperItem(
                    id: idCtrl.text.trim(),
                    enabled: enabled,
                    title: LocalizedText(
                      en: titleEnCtrl.text.trim(),
                      ar: titleArCtrl.text.trim(),
                    ),
                    description: LocalizedText(
                      en: descEnCtrl.text.trim(),
                      ar: descArCtrl.text.trim(),
                    ),
                    bannerUrl: bannerCtrl.text.trim(),
                    docsUrl: docsCtrl.text.trim(),
                    githubUrl: githubCtrl.text.trim(),
                    downloadUrl: downloadCtrl.text.trim(),
                    readmeUrl: readmeCtrl.text.trim(),
                    url: urlCtrl.text.trim(),
                    baseUrl: baseUrlCtrl.text.trim(),
                    version: versionCtrl.text.trim(),
                    screenshots: List<String>.from(screenshots),
                    endpoints: List<DeveloperEndpoint>.from(endpoints),
                  ),
                );
              },
              child: Text('developers_save'.tr),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardTopBar extends StatelessWidget {
  const _DashboardTopBar({
    required this.isLoading,
    required this.onReload,
    required this.onImport,
    required this.onExport,
  });

  final bool isLoading;
  final VoidCallback onReload;
  final VoidCallback onImport;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(
          bottom: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Text(
            'developers_dashboard'.tr,
            style: const TextStyle(
              fontFamily: 'cairo',
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          if (isLoading) ...[
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
            const Gap(10),
          ],
          _TopActionButton(
            icon: Icons.refresh,
            label: 'developers_reload'.tr,
            onTap: onReload,
          ),
          const Gap(8),
          _TopActionButton(
            icon: Icons.upload_file,
            label: 'developers_import_json'.tr,
            onTap: onImport,
          ),
          const Gap(8),
          _TopActionButton(
            icon: Icons.download_outlined,
            label: 'developers_export_json'.tr,
            onTap: onExport,
          ),
        ],
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontFamily: 'cairo')),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _SectionsSidebar extends StatelessWidget {
  const _SectionsSidebar({
    required this.sections,
    required this.selectedIndex,
    required this.onSelect,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  final List<DeveloperSection> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  final void Function(DeveloperSection, int) onEdit;
  final void Function(int) onDelete;
  final void Function(int, int) onReorder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'developers_sections'.tr,
                style: const TextStyle(
                  fontFamily: 'cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'developers_add_section'.tr,
              ),
            ],
          ),
          const Gap(12),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: sections.length,
              onReorder: onReorder,
              itemBuilder: (context, index) {
                final section = sections[index];
                final isSelected = index == selectedIndex;
                return Container(
                  key: ValueKey(section.slug),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? scheme.primary.withValues(alpha: 0.16)
                        : scheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? scheme.primary
                          : scheme.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  child: ListTile(
                    onTap: () => onSelect(index),
                    title: Text(
                      section.title.en.isNotEmpty
                          ? section.title.en
                          : section.slug,
                      style: const TextStyle(fontFamily: 'cairo'),
                    ),
                    subtitle: Text(
                      section.slug,
                      style: TextStyle(
                        fontFamily: 'cairo',
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 18),
                          onPressed: () => onEdit(section, index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          onPressed: () => onDelete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionEditor extends StatelessWidget {
  const _SectionEditor({
    required this.section,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
    required this.onReorderItems,
  });

  final DeveloperSection? section;
  final VoidCallback onAddItem;
  final void Function(DeveloperSection, DeveloperItem, int) onEditItem;
  final void Function(DeveloperSection, int) onDeleteItem;
  final void Function(DeveloperSection, int, int) onReorderItems;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (section == null) {
      return Center(
        child: Text(
          'developers_select_section'.tr,
          style: TextStyle(
            fontFamily: 'cairo',
            color: scheme.onSurfaceVariant,
          ),
        ),
      );
    }

    final current = section!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${current.title.en} (${current.slug})',
                style: const TextStyle(
                  fontFamily: 'cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  current.type,
                  style: TextStyle(
                    fontFamily: 'cairo',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const Gap(16),
          Row(
            children: [
              Text(
                'developers_items'.tr,
                style: const TextStyle(
                  fontFamily: 'cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onAddItem,
                icon: const Icon(Icons.add, size: 18),
                label: Text('developers_add_item'.tr,
                    style: const TextStyle(fontFamily: 'cairo')),
                style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
              ),
            ],
          ),
          const Gap(12),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: current.items.length,
            onReorder: (oldIndex, newIndex) =>
                onReorderItems(current, oldIndex, newIndex),
            itemBuilder: (context, index) {
              final item = current.items[index];
              return Container(
                key: ValueKey('${current.slug}_${item.id}_$index'),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: ListTile(
                  title: Text(
                    item.title.en.isNotEmpty ? item.title.en : item.id,
                    style: const TextStyle(fontFamily: 'cairo'),
                  ),
                  subtitle: Text(
                    item.enabled
                        ? 'developers_enabled'.tr
                        : 'developers_disabled'.tr,
                    style: TextStyle(
                      fontFamily: 'cairo',
                      fontSize: 11,
                      color: item.enabled
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        onPressed: () => onEditItem(current, item, index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () => onDeleteItem(current, index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'cairo')),
        const Gap(6),
        child,
      ],
    );
  }
}

class _DualTextFields extends StatelessWidget {
  const _DualTextFields({
    required this.label,
    required this.enController,
    required this.arController,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController enController;
  final TextEditingController arController;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'cairo')),
        const Gap(6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: enController,
                maxLines: maxLines,
                decoration: InputDecoration(
                  labelText: 'developers_lang_en'.tr,
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: TextField(
                controller: arController,
                maxLines: maxLines,
                decoration: InputDecoration(
                  labelText: 'developers_lang_ar'.tr,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScreenshotsEditor extends StatelessWidget {
  const _ScreenshotsEditor({
    required this.screenshots,
    required this.onChanged,
  });

  final List<String> screenshots;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('developers_screenshots'.tr,
            style: const TextStyle(fontFamily: 'cairo')),
        const Gap(6),
        ...screenshots.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = TextEditingController(text: entry.value);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: (value) => screenshots[index] = value,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    screenshots.removeAt(index);
                    onChanged();
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            screenshots.add('');
            onChanged();
          },
          icon: const Icon(Icons.add),
          label: Text('developers_add_url'.tr),
        ),
      ],
    );
  }
}

class _EndpointsEditor extends StatelessWidget {
  const _EndpointsEditor({
    required this.endpoints,
    required this.onChanged,
  });

  final List<DeveloperEndpoint> endpoints;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('developers_endpoints'.tr,
            style: const TextStyle(fontFamily: 'cairo')),
        const Gap(6),
        ...endpoints.asMap().entries.map((entry) {
          final index = entry.key;
          final endpoint = entry.value;
          final methodCtrl = TextEditingController(text: endpoint.method);
          final pathCtrl = TextEditingController(text: endpoint.path);
          final summaryEnCtrl =
              TextEditingController(text: endpoint.summary.en);
          final summaryArCtrl =
              TextEditingController(text: endpoint.summary.ar);
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: methodCtrl,
                          decoration: InputDecoration(
                              labelText: 'developers_endpoint_method'.tr),
                          onChanged: (value) {
                            endpoints[index] = DeveloperEndpoint(
                              method: value,
                              path: endpoints[index].path,
                              summary: endpoints[index].summary,
                            );
                          },
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: TextField(
                          controller: pathCtrl,
                          decoration: InputDecoration(
                              labelText: 'developers_endpoint_path'.tr),
                          onChanged: (value) {
                            endpoints[index] = DeveloperEndpoint(
                              method: endpoints[index].method,
                              path: value,
                              summary: endpoints[index].summary,
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          endpoints.removeAt(index);
                          onChanged();
                        },
                      ),
                    ],
                  ),
                  const Gap(6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: summaryEnCtrl,
                          decoration: InputDecoration(
                              labelText: 'developers_endpoint_summary_en'.tr),
                          onChanged: (value) {
                            endpoints[index] = DeveloperEndpoint(
                              method: endpoints[index].method,
                              path: endpoints[index].path,
                              summary: LocalizedText(
                                en: value,
                                ar: endpoints[index].summary.ar,
                              ),
                            );
                          },
                        ),
                      ),
                      const Gap(8),
                      Expanded(
                        child: TextField(
                          controller: summaryArCtrl,
                          decoration: InputDecoration(
                              labelText: 'developers_endpoint_summary_ar'.tr),
                          onChanged: (value) {
                            endpoints[index] = DeveloperEndpoint(
                              method: endpoints[index].method,
                              path: endpoints[index].path,
                              summary: LocalizedText(
                                en: endpoints[index].summary.en,
                                ar: value,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        TextButton.icon(
          onPressed: () {
            endpoints.add(
              DeveloperEndpoint(
                method: 'GET',
                path: '',
                summary: const LocalizedText(),
              ),
            );
            onChanged();
          },
          icon: const Icon(Icons.add),
          label: Text('developers_add_endpoint'.tr),
        ),
      ],
    );
  }
}
