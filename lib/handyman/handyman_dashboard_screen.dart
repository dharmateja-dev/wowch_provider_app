import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/my_provider_widget.dart';
import 'package:handyman_provider_flutter/fragments/booking_fragment.dart';
import 'package:handyman_provider_flutter/fragments/notification_fragment.dart';
import 'package:handyman_provider_flutter/handyman/screen/fragments/handyman_fragment.dart';
import 'package:handyman_provider_flutter/handyman/screen/fragments/handyman_profile_fragment.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_list_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:playx_version_update/playx_version_update.dart';

import '../booking_filter/booking_filter_screen.dart';
import '../components/image_border_component.dart';
import '../utils/app_configuration.dart';

class HandymanDashboardScreen extends StatefulWidget {
  final int? index;

  HandymanDashboardScreen({this.index});

  @override
  _HandymanDashboardScreenState createState() =>
      _HandymanDashboardScreenState();
}

class _HandymanDashboardScreenState extends State<HandymanDashboardScreen> {
  int currentIndex = 0;

  bool get isCurrentFragmentIsBooking =>
      fragmentList[currentIndex].runtimeType == BookingFragment().runtimeType;

  List<Widget> fragmentList = [
    const HandymanHomeFragment(),
    BookingFragment(),
    if (appConfigurationStore.isEnableChat) ChatListScreen(),
    HandymanProfileFragment(),
  ];

  Future<void> checkAndShowCustomForceUpdateDialog(BuildContext context) async {
    final result = await PlayxVersionUpdate.checkVersion(
      options: const PlayxUpdateOptions(
        androidPackageName: 'com.iqonic.provider',
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

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    afterBuildCreated(() async {
      setStatusBarColor(context.primary);
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
    });

    LiveStream().on(LIVESTREAM_CHANGE_HANDYMAN_TAB, (data) {
      currentIndex = (data as Map)["index"];

      setState(() {});

      100.milliseconds.delay.then((value) {
        if (data.containsKey('booking_type')) {
          LiveStream().emit(
              LIVESTREAM_UPDATE_BOOKING_STATUS_WISE, data['booking_type']);
        } else if (currentIndex == 1) {
          LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_STATUS_WISE, '');
        }
      });
    });

    /*LiveStream().on(LIVESTREAM_HANDY_BOARD, (data) {
      currentIndex = (data as Map)["index"];
      LiveStream().emit(LIVESTREAM_UPDATE_BOOKING_STATUS_WISE, data['type']);
      setState(() {});
    });*/

    /*LiveStream().on(LIVESTREAM_HANDYMAN_ALL_BOOKING, (index) {
      currentIndex = index as int;
      setState(() {});
    });*/

    await 3.seconds.delay;
    if (getBoolAsync(FORCE_UPDATE_PROVIDER_APP)) {
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
    LiveStream().dispose(LIVESTREAM_CHANGE_HANDYMAN_TAB);
    // LiveStream().dispose(LIVESTREAM_HANDY_BOARD);
    // LiveStream().dispose(LIVESTREAM_HANDYMAN_ALL_BOOKING);
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      message: languages.lblCloseAppMsg,
      child: Scaffold(
        backgroundColor: context.scaffoldSecondary,
        body: fragmentList[currentIndex],
        appBar: appBarWidget(
          [
            languages.handymanHome,
            languages.lblBooking,
            if (appConfigurationStore.isEnableChat) languages.lblChat,
            languages.lblProfile,
          ][currentIndex],
          color: context.primary,
          elevation: 0.0,
          textColor: context.onPrimary,
          showBack: false,
          actions: [
            IconButton(
              icon:
                  ic_info.iconImage(context: context, color: context.onPrimary),
              onPressed: () async {
                showModalBottomSheet(
                  backgroundColor: context.bottomSheetBackgroundColor,
                  context: context,
                  shape: RoundedRectangleBorder(borderRadius: radius()),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  builder: (context) {
                    return MyProviderWidget();
                  },
                );
              },
            ),
            IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  ic_notification.iconImage(
                      context: context, size: 20, color: context.onPrimary),
                  Positioned(
                    top: -10,
                    right: -4,
                    child: Observer(
                      builder: (context) {
                        if (appStore.notificationCount.validate() > 0) {
                          return Container(
                            padding: const EdgeInsets.all(4),
                            decoration: boxDecorationDefault(
                                color: context.error, shape: BoxShape.circle),
                            child: FittedBox(
                              child: Text(appStore.notificationCount.toString(),
                                  style: context.primaryTextStyle(
                                      size: 12, color: context.onPrimary)),
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
              IconButton(
                icon: ic_filter.iconImage(
                    context: context, color: context.onPrimary, size: 22),
                onPressed: () async {
                  BookingFilterScreen().launch(context).then((value) {
                    if (value != null) {
                      LiveStream().emit(LIVESTREAM_UPDATE_BOOKINGS);
                      setState(() {});
                    }
                  });
                },
              ),
          ],
        ),
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
                      context: context, color: context.bottomNavIconInactive),
                  selectedIcon: ic_home.iconImage(
                      context: context, color: context.bottomNavIconActive),
                  label: languages.home,
                ),
                NavigationDestination(
                  icon: total_booking.iconImage(
                      context: context, color: context.bottomNavIconInactive),
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
                        context: context, color: context.bottomNavIconActive),
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
  }
}
