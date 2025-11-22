import 'package:alheekmahlib_website/core/utils/helpers/navigation_keys.dart';
import 'package:alheekmahlib_website/core/utils/helpers/url_updater.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:quran_library/quran.dart';

/// Controller لمزامنة رقم الصفحة الحالي مع رابط المتصفح (?page=...)
/// دون التأثير على أداء الواجهة.
class QuranScreenController extends GetxController {
  static QuranScreenController get instance =>
      GetInstance().putOrFind(() => QuranScreenController());

  Worker? _pageUrlSyncWorker;
  int? _initialPage; // رقم الصفحة من الرابط (1-based)
  int? _initialAyah; // رقم الآية الفريد من الرابط
  bool _applying = false; // أثناء التطبيق الأولي نتجنّب تحديث الرابط
  bool _deepLinkApplied = false; // تم تطبيق الصفحة/الآية
  int _applyAttempts = 0; // عدد المحاولات
  static const int _maxApplyAttempts =
      60; // زيادة المحاولات لإتاحة وقت تحميل المكتبة

  @override
  void onInit() {
    super.onInit();
    _parseDeepLink();
    _pageUrlSyncWorker = debounce<int>(
      QuranCtrl.instance.state.currentPageNumber,
      _onPageChanged,
      time: const Duration(milliseconds: 160),
    );
    _scheduleApply();
  }

  // تحديث الرابط عند تقليب الصفحات (بعد التطبيق الأولي فقط)
  void _onPageChanged(int page) {
    if (page <= 0 || _applying) return;
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    final uri = () {
      final frag = Uri.base.fragment;
      if (frag.isNotEmpty && frag.startsWith('/')) return Uri.parse(frag);
      return Uri(
          path: Uri.base.path, queryParameters: Uri.base.queryParameters);
    }();
    if (!uri.path.startsWith('/quran')) return;
    final currentPageParam = uri.queryParameters['page'];
    if (currentPageParam == '$page') return;
    final newUri = Uri(path: uri.path, queryParameters: {
      ...uri.queryParameters,
      'page': '$page',
    });
    updateBrowserUrl(newUri.toString(), replace: true);
  }

  // استخراج قيم page / ayah من الرابط
  void _parseDeepLink() {
    final frag = Uri.base.fragment;
    final full = frag.isNotEmpty ? Uri.parse(frag) : Uri.base;
    final pageRaw = full.queryParameters['page'];
    final p = int.tryParse(pageRaw ?? '');
    if (p != null && p > 0) _initialPage = p.clamp(1, 700);
    final ayahRaw = full.queryParameters['ayah'];
    final a = int.tryParse(ayahRaw ?? '');
    if (a != null && a > 0) _initialAyah = a;
  }

  // تطبيق الصفحة والآية بمحاولات خفيفة متتالية حتى النجاح أو انتهاء العدد
  void _scheduleApply() {
    if (_initialPage == null && _initialAyah == null) return;
    _applying = true;
    void attempt() {
      if (_deepLinkApplied) return;
      _applyAttempts++;
      final current = QuranCtrl.instance.state.currentPageNumber.value;
      // جرّب القفز للصفحة إن لم تصل بعد
      if (_initialPage != null && current != _initialPage) {
        try {
          QuranLibrary().jumpToPage(_initialPage!);
        } catch (_) {}
      }
      final after = QuranCtrl.instance.state.currentPageNumber.value;
      final pageOk = _initialPage == null || after == _initialPage;

      // طبّق الآية إذا نجحت الصفحة أو إذا وصلنا الحد الأقصى (أفضل جهد)
      if (_initialAyah != null &&
          (pageOk || _applyAttempts >= _maxApplyAttempts)) {
        try {
          QuranLibrary.quranCtrl.toggleAyahSelection(_initialAyah!);
        } catch (_) {}
        _initialAyah = null; // محاولة واحدة فقط
      }

      // إنهاء إذا نجحت الصفحة أو انتهت المحاولات
      if (pageOk || _applyAttempts >= _maxApplyAttempts) {
        _deepLinkApplied = true;
        _applying = false;
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => attempt());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => attempt());
  }

  @override
  void onClose() {
    _pageUrlSyncWorker?.dispose();
    super.onClose();
  }
}
