import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:gap/gap.dart';

import '../../core/services/services_locator.dart';
import '../contact_us/screens/about_us_section.dart';
import '../controllers/general_controller.dart';
import '../our_apps/our_apps.dart';
import 'widgets/faq_section.dart';
import 'widgets/hero_header.dart';
import 'widgets/services_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return Container(
      height: height,
      width: width,
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 32.0, bottom: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const FadeIn(
                config: BaseAnimationConfig(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: HeroHeader(),
                  ),
                ),
              ),
              const Gap(32),
              const FadeInUp(
                config: BaseAnimationConfig(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: ServicesSection(),
                  ),
                ),
              ),
              const Gap(32),
              FadeInUp(
                config: BaseAnimationConfig(
                  child: KeyedSubtree(
                    key: sl<GeneralController>().ourAppsKey,
                    child: const OurApps(),
                  ),
                ),
              ),
              const Gap(32),
              const FadeInUp(
                config: BaseAnimationConfig(
                  child: AboutUsSection(),
                ),
              ),
              const Gap(32),
              const FadeInUp(
                config: BaseAnimationConfig(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: FaqSection(),
                  ),
                ),
              ),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}
