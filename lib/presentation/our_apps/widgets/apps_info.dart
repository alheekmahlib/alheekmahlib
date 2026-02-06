part of '../our_apps.dart';

class AppsInfo extends StatelessWidget {
  final OurAppInfo apps;
  final FloatingMenuAnchoredOverlayController controller;
  const AppsInfo({
    super.key,
    required this.apps,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final appInfo = sl<AppsInfoController>();
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Stack(
            children: [
              customClose(context, onTap: () => controller.close()),
              Padding(
                padding: const EdgeInsets.only(top: 32.0),
                child: ListView(
                  children: [
                    SvgPicture.network(
                      apps.appLogo,
                      width: 80,
                    ),
                    const Gap(8.0),
                    Center(
                      child: Text(
                        '| ${apps.appTitle} |',
                        style: TextStyle(
                          color: context.textDarkColor,
                          fontSize: 18,
                          fontFamily: 'cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(
                      height: 16,
                      thickness: 2,
                      endIndent: 16,
                      indent: 16,
                    ),
                    const Gap(8.0),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .5),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              MultiImageProvider multiImageProvider =
                                  MultiImageProvider(initialIndex: 0, [
                                Image.network(apps.appBanner).image,
                              ]);
                              showImageViewerPager(context, multiImageProvider,
                                  onPageChanged: (page) {
                                log("page changed to $page");
                              }, onViewerDismissed: (page) {
                                log("dismissed while on page $page");
                              });
                            },
                            child: apps.appBanner == ''
                                ? const SizedBox.shrink()
                                : Image.network(
                                    apps.appBanner,
                                    // height: 400,
                                  ),
                          ),
                          const Gap(8.0),
                          Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              _storeButton(
                                context: context,
                                appInfo: appInfo,
                                url: apps.urlAppStore,
                                assetPath: 'assets/images/app_store.png',
                                label: 'App Store',
                              ),
                              _storeButton(
                                context: context,
                                appInfo: appInfo,
                                url: apps.urlPlayStore,
                                assetPath: 'assets/images/play_store.png',
                                label: 'Play Store',
                              ),
                              _storeButton(
                                context: context,
                                appInfo: appInfo,
                                url: apps.urlAppGallery,
                                assetPath: 'assets/images/app_gallery.png',
                                label: 'App Gallery',
                              ),
                              _storeButton(
                                context: context,
                                appInfo: appInfo,
                                url: apps.urlMacAppStore,
                                assetPath: 'assets/images/app_store.png',
                                label: 'Mac App Store',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storeButton({
    required BuildContext context,
    required AppsInfoController appInfo,
    required String url,
    required String assetPath,
    required String label,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onPrimary,
            borderRadius: const BorderRadius.all(Radius.circular(8))),
        child: InkWell(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image(
                opacity: const AlwaysStoppedAnimation(.5),
                image: AssetImage(
                  assetPath,
                ),
                height: 30,
                colorBlendMode: BlendMode.screen,
              ),
              Container(
                width: 2,
                height: 20,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.white,
              ),
              Text(
                label,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'cairo',
                    fontStyle: FontStyle.italic,
                    fontSize: 14),
              ),
            ],
          ),
          onTap: () {
            appInfo.appStoreI(url);
          },
        ),
      ),
    );
  }
}
