enum DevelopersOpenType { api, libraries }

extension DevelopersOpenTypeX on DevelopersOpenType {
  String get sectionType =>
      this == DevelopersOpenType.api ? 'api' : 'libraries';
}

class DeveloperContent {
  final String? updatedAt;
  final List<DeveloperSection> sections;

  DeveloperContent({
    required this.updatedAt,
    required this.sections,
  });

  factory DeveloperContent.fromJson(Map<String, dynamic> json) {
    final sectionsData = json['sections'];
    final List<DeveloperSection> sections = (sectionsData is List)
        ? sectionsData
            .whereType<Map<String, dynamic>>()
            .map(DeveloperSection.fromJson)
            .toList()
        : [];

    return DeveloperContent(
      updatedAt: json['updatedAt']?.toString(),
      sections: sections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'updatedAt': updatedAt,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }
}

class DeveloperSection {
  final String slug;
  final bool enabled;
  final String type;
  final LocalizedText title;
  final LocalizedText description;
  final List<DeveloperItem> items;

  DeveloperSection({
    required this.slug,
    required this.enabled,
    required this.type,
    required this.title,
    required this.description,
    required this.items,
  });

  factory DeveloperSection.fromJson(Map<String, dynamic> json) {
    final itemsData = json['items'];
    final List<DeveloperItem> items = (itemsData is List)
        ? itemsData
            .whereType<Map<String, dynamic>>()
            .map(DeveloperItem.fromJson)
            .toList()
        : [];

    return DeveloperSection(
      slug: json['slug']?.toString() ?? '',
      enabled: json['enabled'] == null ? true : json['enabled'] == true,
      type: json['type']?.toString() ?? 'generic',
      title: LocalizedText.fromJson(json['title']),
      description: LocalizedText.fromJson(json['description']),
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slug': slug,
      'enabled': enabled,
      'type': type,
      'title': title.toJson(),
      'description': description.toJson(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class DeveloperItem {
  final String id;
  final bool enabled;
  final LocalizedText title;
  final LocalizedText description;
  final String bannerUrl;
  final String docsUrl;
  final String githubUrl;
  final String downloadUrl;
  final String readmeUrl;
  final String url;
  final String baseUrl;
  final String version;
  final List<String>? screenshots;
  final List<DeveloperEndpoint> endpoints;

  DeveloperItem({
    required this.id,
    required this.enabled,
    required this.title,
    required this.description,
    required this.bannerUrl,
    required this.docsUrl,
    required this.githubUrl,
    required this.downloadUrl,
    required this.readmeUrl,
    required this.url,
    required this.baseUrl,
    required this.version,
    this.screenshots,
    required this.endpoints,
  });

  factory DeveloperItem.fromJson(Map<String, dynamic> json) {
    final screenshotsData = json['screenshots'];
    final screenshots = (screenshotsData is List)
        ? screenshotsData.whereType<String>().toList()
        : <String>[];

    final endpointsData = json['endpoints'];
    final endpoints = (endpointsData is List)
        ? endpointsData
            .whereType<Map<String, dynamic>>()
            .map(DeveloperEndpoint.fromJson)
            .toList()
        : <DeveloperEndpoint>[];

    return DeveloperItem(
      id: json['id']?.toString() ?? '',
      enabled: json['enabled'] == null ? true : json['enabled'] == true,
      title: LocalizedText.fromJson(json['title']),
      description: LocalizedText.fromJson(json['description']),
      bannerUrl: json['bannerUrl']?.toString() ?? '',
      docsUrl: json['docsUrl']?.toString() ?? '',
      githubUrl: json['githubUrl']?.toString() ?? '',
      downloadUrl: json['downloadUrl']?.toString() ?? '',
      readmeUrl: json['readmeUrl']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      baseUrl: json['baseUrl']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      screenshots: screenshots,
      endpoints: endpoints,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enabled': enabled,
      'title': title.toJson(),
      'description': description.toJson(),
      'bannerUrl': bannerUrl,
      'docsUrl': docsUrl,
      'githubUrl': githubUrl,
      'downloadUrl': downloadUrl,
      'readmeUrl': readmeUrl,
      'url': url,
      'baseUrl': baseUrl,
      'version': version,
      'screenshots': screenshots,
      'endpoints': endpoints.map((e) => e.toJson()).toList(),
    };
  }
}

class DeveloperEndpoint {
  final String method;
  final String path;
  final LocalizedText summary;

  DeveloperEndpoint({
    required this.method,
    required this.path,
    required this.summary,
  });

  factory DeveloperEndpoint.fromJson(Map<String, dynamic> json) {
    return DeveloperEndpoint(
      method: json['method']?.toString() ?? 'GET',
      path: json['path']?.toString() ?? '',
      summary: LocalizedText.fromJson(json['summary']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'path': path,
      'summary': summary.toJson(),
    };
  }
}

class LocalizedText {
  final String en;
  final String ar;

  const LocalizedText({this.en = '', this.ar = ''});

  factory LocalizedText.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return LocalizedText(
        en: json['en']?.toString() ?? '',
        ar: json['ar']?.toString() ?? '',
      );
    }
    if (json is String) {
      return LocalizedText(en: json, ar: json);
    }
    return const LocalizedText();
  }

  Map<String, dynamic> toJson() => {'en': en, 'ar': ar};
}
