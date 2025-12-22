import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/fragments/booking_fragment.dart';
import 'package:handyman_provider_flutter/fragments/notification_fragment.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/fragments/provider_home_fragment.dart';
import 'package:handyman_provider_flutter/provider/fragments/provider_profile_fragment.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_list_screen.dart';
import 'package:handyman_provider_flutter/utils/app_configuration.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:playx_version_update/playx_version_update.dart';

import '../booking_filter/booking_filter_screen.dart';
import '../components/image_border_component.dart';

class ProviderDashboardScreen extends StatefulWidget {
  final int? index;

  ProviderDashboardScreen({this.index});

  @override
  ProviderDashboardScreenState createState() => ProviderDashboardScreenState();
}

class ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  int currentIndex = 0;

  DateTime? currentBackPressTime;

  bool get isCurrentFragmentIsBooking =>
      getFragments()[currentIndex].runtimeType == BookingFragment().runtimeType;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> checkAndShowCustomForceUpdateDialog(BuildContext context) async {
    final result = await PlayxVersionUpdate.checkVersion(
      options: PlayxUpdateOptions(
        androidPackageName: PackageInfoData().packageName,
        iosBundleId: PackageInfoData().packageName,
        minVersion: '11.14.2',
      ),
    );

    result.when(
      success: (info) {
        forceUpdate(context, currentAppVersionCode: 99);
      },
      error: (e) {
        log('Version check failed: ${e.message}');
      },
    );
  }

  Future<void> init() async {
    afterBuildCreated(
      () async {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
        }
        PlatformDispatcher.instance.onPlatformBrightnessChanged = () {
          if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
            appStore.setDarkMode(
              PlatformDispatcher.instance.platformBrightness == Brightness.dark,
            );
          }
        };
      },
    );

    LiveStream().on(LIVESTREAM_PROVIDER_ALL_BOOKING, (index) {
      currentIndex = index as int;
      setState(() {});
    });

    await 3.seconds.delay;
    if (getBoolAsync(FORCE_UPDATE_PROVIDER_APP)) {
      setValue(AUTO_UPDATE, false);
      showForceUpdateDialog(context);
    } else if (getBoolAsync(AUTO_UPDATE)) {
      checkAndShowCustomForceUpdateDialog(context);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_PROVIDER_ALL_BOOKING);
  }

  List<Widget> getFragments() {
    return [
      ProviderHomeFragment(),
      BookingFragment(),
      if (appConfigurationStore.isEnableChat) ChatListScreen(),
      ProviderProfileFragment(),
    ];
  }

  List<String> getTitles() {
    return [
      languages.providerHome,
      languages.lblBooking,
      if (appConfigurationStore.isEnableChat) languages.lblChat,
      languages.lblProfile,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        List<Widget> fragmentList = getFragments();
        List<String> titles = getTitles();

        // Prevent index out of range
        if (currentIndex >= fragmentList.length) {
          currentIndex = 0;
        }

        return DoublePressBackWidget(
          message: languages.lblCloseAppMsg,
          child: Scaffold(
            backgroundColor: context.scaffoldSecondary,
            appBar: appBarWidget(
              titles[currentIndex],
              color: context.primary,
              textColor: context.onPrimary,
              showBack: false,
              actions: [
                IconButton(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ic_notification.iconImage(
                          context: context, color: context.onPrimary, size: 20),
                      Positioned(
                        top: -14,
                        right: -6,
                        child: Observer(
                          builder: (context) {
                            if (appStore.notificationCount.validate() > 0) {
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: boxDecorationDefault(
                                  color: context.error,
                                  shape: BoxShape.circle,
                                ),
                                child: FittedBox(
                                  child: Text(
                                    appStore.notificationCount.toString(),
                                    style: context.primaryTextStyle(
                                      size: 12,
                                      color: context.onPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const Offstage();
                          },
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    NotificationFragment().launch(context);
                  },
                ),
                if (isCurrentFragmentIsBooking)
                  Observer(
                    builder: (_) {
                      int filterCount = filterStore.getActiveFilterCount();
                      return Stack(
                        children: [
                          IconButton(
                            icon: ic_filter.iconImage(
                                context: context,
                                color: context.onPrimary,
                                size: 20),
                            onPressed: () async {
                              BookingFilterScreen()
                                  .launch(context)
                                  .then((value) {
                                if (value != null) {
                                  LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);
                                  setState(() {});
                                }
                              });
                            },
                          ),
                          if (filterCount > 0)
                            Positioned(
                              right: 7,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: boxDecorationDefault(
                                  color: context.error,
                                  shape: BoxShape.circle,
                                ),
                                child: FittedBox(
                                  child: Text(
                                    '$filterCount',
                                    style: context.boldTextStyle(
                                      color: context.onPrimary,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
            body: fragmentList[currentIndex],
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: context.cardSecondaryBorder,
                    width: 1,
                  ),
                ),
              ),
              child: NavigationBarTheme(
                data: NavigationBarThemeData(
                  backgroundColor: context.scaffold,
                  indicatorColor: Colors.transparent,
                  labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return context.boldTextStyle(
                          size: 12, color: context.bottomNavIconActive);
                    }
                    return context.primaryTextStyle(
                        size: 12, color: context.bottomNavIconInactive);
                  }),
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: NavigationBar(
                  height: 60,
                  selectedIndex: currentIndex,
                  destinations: [
                    NavigationDestination(
                      icon: ic_home.iconImage(
                          context: context,
                          color: context.bottomNavIconInactive),
                      selectedIcon: ic_home.iconImage(
                          context: context, color: context.bottomNavIconActive),
                      label: languages.home,
                    ),
                    NavigationDestination(
                      icon: total_booking.iconImage(
                          context: context,
                          color: context.bottomNavIconInactive),
                      selectedIcon: total_booking.iconImage(
                          context: context, color: context.bottomNavIconActive),
                      label: languages.lblBooking,
                    ),
                    if (appConfigurationStore.isEnableChat)
                      NavigationDestination(
                        icon: Image.asset(
                          chat,
                          height: 20,
                          width: 20,
                          color: context.bottomNavIconInactive,
                        ),
                        selectedIcon: chat.iconImage(
                            context: context,
                            color: context.bottomNavIconActive),
                        label: languages.lblChat,
                      ),
                    Observer(
                      builder: (context) {
                        return NavigationDestination(
                          icon: (appStore.isLoggedIn &&
                                  appStore.userProfileImage.isNotEmpty)
                              ? IgnorePointer(
                                  ignoring: true,
                                  child: ImageBorder(
                                    src: appStore.userProfileImage,
                                    height: 24,
                                  ),
                                )
                              : profile.iconImage(
                                  context: context,
                                  color: context.bottomNavIconInactive),
                          selectedIcon: (appStore.isLoggedIn &&
                                  appStore.userProfileImage.isNotEmpty)
                              ? IgnorePointer(
                                  ignoring: true,
                                  child: ImageBorder(
                                    src: appStore.userProfileImage,
                                    height: 24,
                                  ),
                                )
                              : ic_fill_profile.iconImage(
                                  context: context,
                                  color: context.bottomNavIconActive,
                                ),
                          label: languages.lblProfile,
                        );
                      },
                    ),
                  ],
                  onDestinationSelected: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
