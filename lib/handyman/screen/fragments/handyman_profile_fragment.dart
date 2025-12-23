import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/change_password_screen.dart';
import 'package:handyman_provider_flutter/auth/edit_profile_screen.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/theme_selection_dailog.dart';
import 'package:handyman_provider_flutter/handyman/component/handyman_comission_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/handyman_dashboard_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/about_us_screen.dart';
import 'package:handyman_provider_flutter/screens/languages_screen.dart';
import 'package:handyman_provider_flutter/utils/app_configuration.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/firebase_messaging_utils.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/base_scaffold_widget.dart';
import '../../../helpDesk/help_desk_list_screen.dart';
import '../../../provider/wallet/wallet_history_screen.dart';

class HandymanProfileFragment extends StatefulWidget {
  @override
  _HandymanProfileFragmentState createState() =>
      _HandymanProfileFragmentState();
}

class _HandymanProfileFragmentState extends State<HandymanProfileFragment> {
  UniqueKey keyForExperienceWidget = UniqueKey();
  bool isAvailable = false;
  String yearsOfExp = '';
  int yearsOfExpInDays = 0;
  bool isForceUpdateEnabled = false;
  bool isAutoUpdateEnabled = true;

  @override
  void initState() {
    super.initState();
    init();
    calculateYearsOfExp();
  }

  void init() async {
    setStatusBarColor(context.primary);
    isAvailable = appStore.handymanAvailability == 1 ? true : false;

    /// get wallet balance api call
    appStore.setUserWalletAmount();

    isForceUpdateEnabled = getBoolAsync(
      FORCE_UPDATE_PROVIDER_APP,
    );

    isAutoUpdateEnabled = getBoolAsync(AUTO_UPDATE, defaultValue: true);

    if (isForceUpdateEnabled) {
      setValue(AUTO_UPDATE, false); // Ensure switch is off when forced
      isAutoUpdateEnabled = false;
    }
  }

  void calculateYearsOfExp() async {
    final Duration duration =
        DateTime.now().difference(DateTime.parse(appStore.createdAt));

    if (duration.inDays < 365) {
      yearsOfExp = languages.lblDay;
      yearsOfExpInDays = duration.inDays;
    } else if (duration.inDays >= 365) {
      yearsOfExp = languages.lblYear;
      yearsOfExpInDays = (duration.inDays / 365).floor();
    }

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldBackgroundColor: context.scaffoldSecondary,
      body: Observer(
        builder: (_) {
          return AnimatedScrollView(
            padding: EdgeInsets.only(top: context.statusBarHeight, bottom: 24),
            crossAxisAlignment: CrossAxisAlignment.start,
            listAnimationType: ListAnimationType.FadeIn,
            physics: const AlwaysScrollableScrollPhysics(),
            fadeInConfiguration:
                FadeInConfiguration(duration: 200.milliseconds),
            onSwipeRefresh: () async {
              init();
              setState(() {});
              return 1.seconds.delay;
            },
            children: [
              if (appStore.isLoggedIn && isUserTypeHandyman)
                Observer(
                  builder: (context) {
                    return AnimatedContainer(
                      margin: const EdgeInsets.all(16),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: (appStore.handymanAvailability == 1
                            ? context.secondaryContainer
                            : context.error.withValues(alpha: 0.1)),
                        borderRadius: BorderRadius.circular(defaultRadius),
                      ),
                      duration: 300.milliseconds,
                      child: SettingItemWidget(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8, left: 16, right: 16),
                        title: languages.lblAvailableStatus,
                        subTitle:
                            '${languages.lblYouAre} ${appStore.handymanAvailability == 1 ? ONLINE : OFFLINE}',
                        subTitleTextColor: appStore.handymanAvailability == 1
                            ? context.primary
                            : context.error,
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: Switch.adaptive(
                            value: appStore.handymanAvailability == 1
                                ? true
                                : false,
                            activeThumbColor: context.primary,
                            onChanged: (v) {
                              ifNotTester(context, () {
                                isAvailable = v;
                                setState(() {});
                                appStore.setHandymanAvailability(
                                    isAvailable ? 1 : 0);
                                final Map request = {
                                  "is_available": isAvailable ? 1 : 0,
                                  "id": appStore.userId,
                                };
                                updateHandymanAvailabilityApi(request: request)
                                    .then((value) {
                                  toast(value.message);
                                }).catchError((e) {
                                  appStore.setHandymanAvailability(
                                      isAvailable ? 0 : 1);
                                  toast(e.toString());
                                });
                              });
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(),
                  backgroundColor: context.secondaryContainer,
                ),
                child: Row(
                  children: [
                    if (appStore.userProfileImage.isNotEmpty)
                      CachedImageWidget(
                        url: appStore.userProfileImage.validate(),
                        height: 66,
                        fit: BoxFit.cover,
                        circle: true,
                      ).paddingBottom(3),
                    24.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          appStore.userFullName,
                          style: context.boldTextStyle(
                              color: context.primary, size: 16),
                        ),
                        4.height,
                        Text(appStore.userEmail,
                            style: context.primaryTextStyle()),
                      ],
                    ),
                  ],
                ),
              )
                  .paddingOnly(left: 16, right: 16, bottom: 16)
                  .visible(appStore.isLoggedIn)
                  .onTap(() {
                const EditProfileScreen().launch(context,
                    pageRouteAnimation: PageRouteAnimation.Fade);
              }),

              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(8),
                  backgroundColor: context.cardSecondary,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.grid_view,
                              size: 18,
                            ),
                            10.width,
                            Text(
                              "${languages.servicesDelivered}:",
                              style: context.boldTextStyle(),
                            )
                          ],
                        ),
                        Text(appStore.completedBooking.validate().toString())
                      ],
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(ic_briefcase,
                                height: 16, width: 16, color: context.icon),
                            10.width,
                            Text(
                              "${languages.lblExperience}:",
                              style: context.boldTextStyle(),
                            )
                          ],
                        ),
                        Text("$yearsOfExpInDays $yearsOfExp")
                      ],
                    ),
                  ],
                ),
              ).paddingOnly(bottom: 16),

              if (getStringAsync(DASHBOARD_COMMISSION)
                  .validate()
                  .isNotEmpty) ...[
                HandymanCommissionComponent(
                    commission: Commission.fromJson(
                        jsonDecode(getStringAsync(DASHBOARD_COMMISSION)))),
                8.height,
              ],

              16.height,
              SettingSection(
                title: Text(languages.general,
                    style: context.boldTextStyle(color: context.primary)),
                headingDecoration: BoxDecoration(
                  color: context.secondaryContainer,
                  borderRadius: const BorderRadiusDirectional.vertical(
                      top: Radius.circular(16)),
                ),
                divider: const Offstage(),
                items: [
                  16.height,
                  SettingItemWidget(
                    decoration: BoxDecoration(
                        color: context.scaffoldSecondary,
                        borderRadius: const BorderRadiusDirectional.vertical(
                            bottom: Radius.circular(0))),
                    leading:
                        ic_un_fill_wallet.iconImage(context: context, size: 18),
                    title: languages.walletBalance,
                    titleTextStyle: context.boldTextStyle(),
                    onTap: () {
                      if (appConfigurationStore.onlinePaymentStatus) {
                        WalletHistoryScreen().launch(context);
                      }
                    },
                    trailing: Text(
                      appStore.userWalletAmount.toPriceFormat(),
                      style: boldTextStyle(color: context.primary),
                    ),
                  ),
                  if (appStore.isLoggedIn &&
                      rolesAndPermissionStore.helpDeskList)
                    SettingItemWidget(
                      decoration: BoxDecoration(
                          color: context.scaffoldSecondary,
                          borderRadius: const BorderRadiusDirectional.vertical(
                              bottom: Radius.circular(16))),
                      leading:
                          ic_help_desk.iconImage(context: context, size: 18),
                      title: languages.helpDesk,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      onTap: () {
                        HelpDeskListScreen().launch(context);
                      },
                    ),
                ],
              ).paddingSymmetric(horizontal: 16),
              16.height,

              /// setting module
              SettingSection(
                title: Text(languages.setting,
                    style: context.boldTextStyle(color: context.primary)),
                headingDecoration: BoxDecoration(
                  color: context.secondaryContainer,
                  borderRadius: const BorderRadiusDirectional.vertical(
                      top: Radius.circular(16)),
                ),
                divider: const Offstage(),
                items: [
                  16.height,
                  SettingItemWidget(
                    decoration: BoxDecoration(
                        color: context.scaffoldSecondary,
                        borderRadius: BorderRadiusDirectional.zero),
                    leading: Image.asset(ic_theme,
                        height: 18, width: 18, color: context.icon),
                    title: languages.appTheme,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                    onTap: () async {
                      await showInDialog(
                        context,
                        builder: (context) => ThemeSelectionDaiLog(context),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                  SettingItemWidget(
                    decoration: BoxDecoration(
                        color: context.scaffoldSecondary,
                        borderRadius: BorderRadiusDirectional.zero),
                    leading: Image.asset(language,
                        height: 18, width: 18, color: context.icon),
                    title: languages.language,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                    onTap: () {
                      LanguagesScreen().launch(context).then((value) {
                        keyForExperienceWidget = UniqueKey();
                      });
                    },
                  ),
                  SettingItemWidget(
                    decoration: BoxDecoration(
                        color: context.scaffoldSecondary,
                        borderRadius: BorderRadiusDirectional.zero),
                    leading: Image.asset(changePassword,
                        height: 18, width: 18, color: context.icon),
                    title: languages.changePassword,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                    onTap: () {
                      ChangePasswordScreen().launch(context);
                    },
                  ),
                  SettingItemWidget(
                    decoration: BoxDecoration(
                        color: context.scaffoldSecondary,
                        borderRadius: const BorderRadiusDirectional.vertical(
                            bottom: Radius.circular(0))),
                    leading: Image.asset(about,
                        height: 18, width: 18, color: context.icon),
                    title: languages.lblAbout,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                    onTap: () {
                      AboutUsScreen().launch(context);
                    },
                  ),
                  Observer(
                    builder: (context) {
                      if (appStore.isLoggedIn)
                        return SettingItemWidget(
                          decoration: BoxDecoration(
                              color: context.scaffoldSecondary,
                              borderRadius:
                                  const BorderRadiusDirectional.vertical(
                                      bottom: Radius.circular(0))),
                          leading: ic_notification.iconImage(
                              context: context, size: 18),
                          title: languages.pushNotification,
                          titleTextStyle: context.boldTextStyle(),
                          padding: const EdgeInsets.all(16),
                          trailing: Transform.scale(
                            scale: 0.7,
                            child: Switch.adaptive(
                              value:
                                  FirebaseAuth.instance.currentUser != null &&
                                      getBoolAsync("IS_SUBSCRIBED_NOTIFICATION",
                                          defaultValue: true),
                              onChanged: (v) async {
                                await setValue("IS_SUBSCRIBED_NOTIFICATION", v);
                                if (appStore.isLoading) return;
                                appStore.setLoading(true);

                                if (v) {
                                  await subscribeToFirebaseTopic();
                                } else {
                                  await unsubscribeFirebaseTopic(
                                      appStore.userId);
                                }
                                appStore.setLoading(false);
                                setState(() {});
                              },
                            ).withHeight(18),
                          ),
                        );
                      else
                        return const Offstage();
                    },
                  ),
                  /*  SettingItemWidget(
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadiusDirectional.vertical(bottom: Radius.circular(16)),
                    ),
                    leading: Image.asset(
                      ic_check_update,
                      height: 14,
                      width: 14,
                      color: appStore.isDarkMode ? white : gray.withValues(alpha: 0.8),
                    ),
                    title: 'Auto Update',
                    titleTextStyle: context.boldTextStyle(size: 12),
                    padding: EdgeInsets.only(bottom: 16, right: 16, left: 16, top: 20),
                    trailing: Transform.scale(
                      scale: 0.7,
                      child: Switch.adaptive(
                        value: getBoolAsync(AUTO_UPDATE, defaultValue: false),
                        onChanged: isForceUpdateEnabled
                            ? null
                            : (v) {
                                setValue(AUTO_UPDATE, v);
                                setState(() {
                                  isAutoUpdateEnabled = v;
                                });
                              },
                      ).withHeight(16),
                    ),
                  ),*/
                  SettingItemWidget(
                    decoration: BoxDecoration(
                      color: context.scaffoldSecondary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    leading: Image.asset(ic_check_update,
                        height: 18, width: 18, color: context.icon),
                    title: languages.lblOptionalUpdateNotify,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Transform.scale(
                      scale: 0.7,
                      child: Switch.adaptive(
                        value: getBoolAsync(UPDATE_NOTIFY, defaultValue: true),
                        onChanged: (v) {
                          setValue(UPDATE_NOTIFY, v);
                          setState(() {});
                        },
                      ).withHeight(24),
                    ),
                  ),
                  16.height,
                ],
              ).paddingSymmetric(horizontal: 16),
              16.height,

              ///Danger zone
              SettingSection(
                title: Text(languages.lblDangerZone.toUpperCase(),
                    style: context.boldTextStyle(color: context.primary)),
                headingDecoration: BoxDecoration(
                  color: context.secondaryContainer,
                  borderRadius: const BorderRadiusDirectional.vertical(
                      top: Radius.circular(16)),
                ),
                divider: const Offstage(),
                items: [
                  16.height,
                  SettingItemWidget(
                    decoration: BoxDecoration(
                        color: context.scaffoldSecondary,
                        borderRadius: const BorderRadiusDirectional.vertical(
                            bottom: Radius.circular(0))),
                    leading: ic_delete.iconImage(context: context, size: 18),
                    paddingBeforeTrailing: 4,
                    title: languages.lblDeleteAccount,
                    titleTextStyle: context.boldTextStyle(),
                    onTap: () {
                      showConfirmDialogCustom(
                        context,
                        negativeText: languages.lblCancel,
                        positiveText: languages.lblDelete,
                        onAccept: (_) {
                          ifNotTester(context, () {
                            appStore.setLoading(true);

                            deleteAccountCompletely().then((value) async {
                              try {
                                await userService.removeDocument(appStore.uid);
                                await userService.deleteUser();
                              } catch (e) {
                                print(e);
                              }

                              appStore.setLoading(false);

                              await clearPreferences();
                              toast(value.message);

                              push(SignInScreen(),
                                  isNewTask: true,
                                  pageRouteAnimation: PageRouteAnimation.Fade);
                            }).catchError((e) {
                              appStore.setLoading(false);
                              toast(e.toString());
                            });
                          });
                        },
                        dialogType: DialogType.DELETE,
                        title: languages.lblDeleteAccountConformation,
                      );
                    },
                  ),
                  SettingItemWidget(
                    decoration: BoxDecoration(
                        color: context.scaffoldSecondary,
                        borderRadius: const BorderRadiusDirectional.vertical(
                            bottom: Radius.circular(16))),
                    leading: ic_logout.iconImage(context: context, size: 18),
                    paddingBeforeTrailing: 4,
                    title: languages.logout,
                    titleTextStyle: context.boldTextStyle(),
                    onTap: () {
                      appStore.setLoading(false);
                      logout(context);
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),

              20.height,

              // VersionInfoWidget(
              //   prefixText: 'v',
              //   textStyle: context.primaryTextStyle(),
              // ).center(),
            ],
          );
        },
      ),
    );
  }
}
