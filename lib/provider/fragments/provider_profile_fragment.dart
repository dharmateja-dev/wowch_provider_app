import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/change_password_screen.dart';
import 'package:handyman_provider_flutter/auth/edit_profile_screen.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/theme_selection_dailog.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/bank_details/bank_details.dart';
import 'package:handyman_provider_flutter/provider/blog/view/blog_list_screen.dart';
import 'package:handyman_provider_flutter/provider/components/commission_component.dart';
import 'package:handyman_provider_flutter/provider/handyman_commission_list_screen.dart';
import 'package:handyman_provider_flutter/provider/handyman_list_screen.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/bid_list_screen.dart';
import 'package:handyman_provider_flutter/provider/packages/package_list_screen.dart';
import 'package:handyman_provider_flutter/provider/services/service_list_screen.dart';
import 'package:handyman_provider_flutter/provider/shop/shop_documents/shop_documents_screen.dart';
import 'package:handyman_provider_flutter/provider/shop/shop_list_screen.dart';
import 'package:handyman_provider_flutter/provider/subscription/subscription_history_screen.dart';
import 'package:handyman_provider_flutter/provider/taxes/taxes_screen.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/my_time_slots_screen.dart';
import 'package:handyman_provider_flutter/provider/wallet/wallet_history_screen.dart';
import 'package:handyman_provider_flutter/screens/about_us_screen.dart';
import 'package:handyman_provider_flutter/screens/languages_screen.dart';
import 'package:handyman_provider_flutter/screens/verify_provider_screen.dart';
import 'package:handyman_provider_flutter/utils/app_configuration.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/switch_push_notification_subscription_component.dart';
import '../../helpDesk/help_desk_list_screen.dart';
import '../../models/selectZoneModel.dart';
import '../earning/handyman_earning_list_screen.dart';
import '../promotional_banner/promotional_banner_list_screen.dart';
import '../services/addons/addon_service_list_screen.dart';

class ProviderProfileFragment extends StatefulWidget {
  final List<UserData>? list;
  final SelectZoneModelResponse? serviceDetail;

  ProviderProfileFragment({this.list, this.serviceDetail});

  @override
  ProviderProfileFragmentState createState() => ProviderProfileFragmentState();
}

class ProviderProfileFragmentState extends State<ProviderProfileFragment> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<int> serviceZoneList = [];
  bool isForceUpdateEnabled = false;
  bool isAutoUpdateEnabled = true;

  @override
  void initState() {
    super.initState();
    init();
    afterBuildCreated(() {
      appStore.setLoading(false);
      setStatusBarColor(context.primaryColor);
    });
  }

  Future<void> init() async {
    /// get wallet balance api call
    appStore.setUserWalletAmount();
    isForceUpdateEnabled =
        getBoolAsync(FORCE_UPDATE_PROVIDER_APP, defaultValue: false);

    isAutoUpdateEnabled = getBoolAsync(AUTO_UPDATE, defaultValue: false);

    if (isForceUpdateEnabled) {
      setValue(AUTO_UPDATE, false); // Ensure switch is off when forced
      isAutoUpdateEnabled = false;
    }
  }

  /// Manually format plan end date to "February 9, 2024" format
  String _formatPlanEndDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];

      DateTime? date;

      // Try parsing different formats
      if (dateString.contains('-')) {
        date = DateTime.tryParse(dateString);
      }

      if (date == null) {
        // Try other common formats
        date = DateTime.tryParse(dateString.replaceAll('/', '-'));
      }

      if (date != null) {
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      }

      // Fallback to original string if parsing fails
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        return Container(
          color: context.scaffoldSecondary,
          child: AnimatedScrollView(
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            physics: const AlwaysScrollableScrollPhysics(),
            onSwipeRefresh: () async {
              init();
              setState(() {});
              return 1.seconds.delay;
            },
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(),
                  backgroundColor: context.secondaryContainer,
                ),
                child: Row(
                  children: [
                    if (appStore.userProfileImage.isNotEmpty)
                      Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          CachedImageWidget(
                            url: appStore.userProfileImage.validate(),
                            height: 65,
                            fit: BoxFit.cover,
                            circle: true,
                          ).paddingBottom(3),
                          /*         Positioned(
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: boxDecorationDefault(
                                color: primary,
                                border: Border.all(color: lightprimary, width: 2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(languages.lblEdit.toUpperCase(), style: context.secondaryTextStyle(context.onPrimary)),
                            ).onTap(() {
                              EditProfileScreen(
                                // selectedList: widget.serviceDetail?.zoneListResponse?.map((zone) => zone.id.validate()).toList() ?? [],
                                onSelectedList: (val) {
                                  serviceZoneList = val;
                                  setState(() {});
                                },
                              ).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
                            }),
                          ),*/
                        ],
                      ),
                    16.width,
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
                  .paddingOnly(left: 16, right: 16, top: 24)
                  .visible(appStore.isLoggedIn)
                  .onTap(() {
                const EditProfileScreen().launch(context,
                    pageRouteAnimation: PageRouteAnimation.Fade);
              }),
              if (appStore.earningTypeSubscription && appStore.isPlanSubscribe)
                Column(
                  children: [
                    16.height,
                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        backgroundColor: context.primary,
                      ),
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(languages.lblCurrentPlan,
                                  style: context.secondaryTextStyle(
                                      color: context.onPrimary)),
                              Text(
                                appStore.planTitle
                                    .validate()
                                    .capitalizeFirstLetter(),
                                style:
                                    context.boldTextStyle(color: Colors.yellow),
                              ),
                            ],
                          ),
                          4.height,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                languages.lblValidTill,
                                style: context.boldTextStyle(
                                    color: context.onPrimary,
                                    fontStyle: FontStyle.italic,
                                    size: 12),
                              ),
                              4.width,
                              Text(
                                _formatPlanEndDate(
                                    appStore.planEndDate.validate()),
                                style: context.boldTextStyle(
                                    color: context.onPrimary,
                                    fontStyle: FontStyle.italic,
                                    size: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                    ).onTap(() {
                      SubscriptionHistoryScreen().launch(context).then((value) {
                        setState(() {});
                      });
                    },
                        overlayColor:
                            const WidgetStatePropertyAll(transparentColor)),
                  ],
                ),
              16.height,
              if (getStringAsync(DASHBOARD_COMMISSION)
                  .validate()
                  .isNotEmpty) ...[
                CommissionComponent(
                  commission: Commission.fromJson(
                      jsonDecode(getStringAsync(DASHBOARD_COMMISSION))),
                ),
                16.height,
              ],
              //General Settings
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
                  //Wallet Balance
                  SettingItemWidget(
                    decoration: BoxDecoration(color: context.scaffoldSecondary),
                    leading:
                        ic_un_fill_wallet.iconImage(context: context, size: 18),
                    title: languages.walletBalance,
                    titleTextStyle: context.boldTextStyle(),
                    padding:
                        const EdgeInsets.only(top: 16, left: 16, right: 16),
                    onTap: () {
                      if (appConfigurationStore.onlinePaymentStatus) {
                        WalletHistoryScreen().launch(context);
                      }
                    },
                    trailing: Text(
                      appStore.userWalletAmount.toPriceFormat(),
                      style: context.boldTextStyle(color: context.primary),
                    ),
                  ),
                  //Shop
                  SettingItemWidget(
                    decoration: BoxDecoration(color: context.scaffoldSecondary),
                    leading: Image.asset(ic_shop,
                        height: 18, width: 18, color: context.icon),
                    title: languages.shop,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                    padding: EdgeInsets.only(top: 20, left: 16, right: 16),
                    onTap: () {
                      ShopListScreen().launch(context);
                    },
                  ),
                  16.height,
                  //Shop Document
                  SettingItemWidget(
                    decoration: BoxDecoration(color: context.scaffoldSecondary),
                    leading: ic_document.iconImage(context: context, size: 18),
                    title: languages.lblShopDocument,
                    titleTextStyle: context.boldTextStyle(),
                    padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                    onTap: () {
                      ShopDocumentsScreen().launch(context);
                    },
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                  ),
                  //Subscription History
                  if (appStore.earningTypeSubscription)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(services,
                          height: 18, width: 18, color: context.icon),
                      title: languages.lblSubscriptionHistory,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () async {
                        SubscriptionHistoryScreen()
                            .launch(context)
                            .then((value) {
                          setState(() {});
                        });
                      },
                    ),
                  //Services
                  if (rolesAndPermissionStore.serviceList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(services,
                          height: 18, width: 18, color: context.icon),
                      title: languages.lblServices,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        ServiceListScreen().launch(context);
                      },
                    ),
                  //Provider Document
                  if (appStore.userType != USER_TYPE_HANDYMAN &&
                      rolesAndPermissionStore.providerDocumentList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_document,
                          height: 18, width: 18, color: context.icon),
                      title: languages.btnVerifyId,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        VerifyProviderScreen().launch(context);
                      },
                    ),
                  //Blogs
                  if (appStore.userType != USER_TYPE_HANDYMAN &&
                      appConfigurationStore.blogStatus)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_blog,
                          height: 18, width: 18, color: context.icon),
                      title: languages.blogs,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        const BlogListScreen().launch(context);
                      },
                    ),
                  //Handyman
                  if (rolesAndPermissionStore.handymanList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(handyman,
                          height: 18, width: 18, color: context.icon),
                      title: languages.lblAllHandyman,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        HandymanListScreen().launch(context);
                      },
                    ),
                  //Help Desk
                  if (appStore.isLoggedIn &&
                      rolesAndPermissionStore.helpDeskList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading:
                          ic_help_desk.iconImage(context: context, size: 18),
                      title: languages.helpDesk,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        HelpDeskListScreen().launch(context);
                      },
                    ),
                  //Handyman Payout
                  if (appStore.userType != USER_TYPE_HANDYMAN &&
                      rolesAndPermissionStore.handymanPayout)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_earning,
                          height: 18, width: 18, color: context.icon),
                      title: languages.handymanEarningList,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        const HandymanEarningListScreen().launch(context);
                      },
                    ),
                  //Handyman Type
                  if (rolesAndPermissionStore.handymanTypeList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(percent_line,
                          height: 18, width: 18, color: context.icon),
                      title: languages.handymanCommission,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        const HandymanCommissionTypeListScreen()
                            .launch(context);
                      },
                    ),
                  //Service Package
                  if (appConfigurationStore.servicePackageStatus &&
                      rolesAndPermissionStore.servicePackageList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_packages,
                          height: 18, width: 18, color: context.icon),
                      title: languages.packages,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        PackageListScreen().launch(context);
                      },
                    ),
                  //Service Addon
                  if (appConfigurationStore.serviceAddonStatus &&
                      rolesAndPermissionStore.serviceAddOnList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_addon_service,
                          height: 18, width: 18, color: context.icon),
                      title: languages.addonServices,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        AddonServiceListScreen().launch(context);
                      },
                    ),
                  //Time Slots
                  if (appConfigurationStore.slotServiceStatus)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_time_slots,
                          height: 18, width: 18, color: context.icon),
                      title: languages.timeSlots,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        MyTimeSlotsScreen().launch(context);
                      },
                    ),
                  //Post Job
                  if (rolesAndPermissionStore.postJobList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(list,
                          height: 18, width: 18, color: context.icon),
                      title: languages.bidList,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        BidListScreen().launch(context);
                      },
                    ),
                  //Tax
                  if (rolesAndPermissionStore.taxList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_tax,
                          height: 18, width: 18, color: context.icon),
                      title: languages.lblTaxes,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        TaxesScreen().launch(context);
                      },
                    ),
                  //Wallet History
                  if (appStore.earningTypeCommission)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_wallet_history,
                          height: 18, width: 18, color: context.icon),
                      title: languages.lblWalletHistory,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        WalletHistoryScreen().launch(context);
                      },
                    ),
                  //Bank Details
                  if (rolesAndPermissionStore.bankList)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_card,
                          height: 18, width: 18, color: context.icon),
                      title: languages.lblBankDetails,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      padding:
                          const EdgeInsets.only(right: 16, left: 16, top: 20),
                      onTap: () {
                        const BankDetails().launch(context);
                      },
                    ),
                  //Promotional Banner
                  if (appStore.userType == USER_TYPE_PROVIDER &&
                      appConfigurationStore.isPromotionalBanner)
                    SettingItemWidget(
                      decoration:
                          BoxDecoration(color: context.scaffoldSecondary),
                      leading: Image.asset(ic_promotional_banner,
                          height: 18, width: 18, color: context.icon),
                      title: languages.promotionalBanners,
                      titleTextStyle: context.boldTextStyle(),
                      trailing: Icon(Icons.chevron_right,
                          color: context.icon, size: 20),
                      padding:
                          const EdgeInsets.only(top: 20, left: 16, right: 16),
                      onTap: () {
                        PromotionalBannerListScreen().launch(context);
                      },
                    ),

                  SettingItemWidget(
                    decoration: BoxDecoration(
                        color: context.scaffoldSecondary,
                        borderRadius: const BorderRadiusDirectional.vertical(
                            bottom: Radius.circular(16))),
                    title: "",
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    padding: const EdgeInsets.only(right: 16, left: 16, top: 0),
                    onTap: () {},
                  ),
                  8.height,
                ],
              ).paddingSymmetric(horizontal: 16),
              16.height,
              SettingSection(
                title: Text(languages.other,
                    style: context.boldTextStyle(color: context.primary)),
                headingDecoration: BoxDecoration(
                  color: context.secondaryContainer,
                  borderRadius: const BorderRadiusDirectional.vertical(
                      top: Radius.circular(16)),
                ),
                divider: const Offstage(),
                items: [
                  8.height,
                  const SwitchPushNotificationSubscriptionComponent(),
                  SettingItemWidget(
                    decoration: BoxDecoration(color: context.scaffoldSecondary),
                    leading: Image.asset(
                      ic_check_update,
                      height: 18,
                      width: 18,
                      color: context.icon,
                    ),
                    title: languages.lblOptionalUpdateNotify,
                    titleTextStyle: context.boldTextStyle(),
                    padding: const EdgeInsets.only(
                        bottom: 16, right: 16, left: 16, top: 20),
                    trailing: Transform.scale(
                      scale: 0.6,
                      child: Switch.adaptive(
                        value: getBoolAsync(UPDATE_NOTIFY, defaultValue: true),
                        onChanged: (v) {
                          setValue(UPDATE_NOTIFY, v);
                          setState(() {});
                        },
                      ).withHeight(16),
                    ),
                  ),
                  /* 16.height,
                  SettingItemWidget(
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
                      scale: 0.6,
                      child: Switch.adaptive(
                        value: isAutoUpdateEnabled,
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
                ],
              ).paddingSymmetric(horizontal: 16),
              16.height,
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
                  8.height,
                  SettingItemWidget(
                    decoration: BoxDecoration(color: context.scaffoldSecondary),
                    leading: Image.asset(ic_theme,
                        height: 18, width: 18, color: context.icon),
                    title: languages.appTheme,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                    padding:
                        const EdgeInsets.only(top: 20, left: 16, right: 16),
                    onTap: () async {
                      await showInDialog(
                        context,
                        builder: (context) => ThemeSelectionDaiLog(context),
                        contentPadding: EdgeInsets.zero,
                      );
                    },
                  ),
                  SettingItemWidget(
                    decoration: BoxDecoration(color: context.scaffoldSecondary),
                    leading: Image.asset(language,
                        height: 18, width: 18, color: context.icon),
                    title: languages.language,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                    padding:
                        const EdgeInsets.only(top: 20, left: 16, right: 16),
                    onTap: () {
                      LanguagesScreen().launch(context);
                    },
                  ),
                  SettingItemWidget(
                    decoration: BoxDecoration(color: context.scaffoldSecondary),
                    leading: Image.asset(changePassword,
                        height: 18, width: 18, color: context.icon),
                    title: languages.changePassword,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                    padding:
                        const EdgeInsets.only(top: 20, left: 16, right: 16),
                    onTap: () {
                      ChangePasswordScreen().launch(context);
                    },
                  ),
                  SettingItemWidget(
                    decoration: BoxDecoration(
                        color: context.scaffoldSecondary,
                        borderRadius: const BorderRadiusDirectional.vertical(
                            bottom: Radius.circular(16))),
                    leading: Image.asset(about,
                        height: 18, width: 18, color: context.icon),
                    title: languages.lblAbout,
                    titleTextStyle: context.boldTextStyle(),
                    trailing: Icon(Icons.chevron_right,
                        color: context.icon, size: 20),
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    padding: const EdgeInsets.only(
                        bottom: 16, right: 16, left: 16, top: 20),
                    onTap: () {
                      AboutUsScreen().launch(context);
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 16),
              16.height,
              SettingSection(
                title: Text(languages.lblDangerZone.toUpperCase(),
                    style: context.boldTextStyle(color: context.primary)),
                headingDecoration: BoxDecoration(
                    color: context.secondaryContainer,
                    borderRadius: const BorderRadiusDirectional.vertical(
                        top: Radius.circular(16))),
                divider: const Offstage(),
                items: [
                  SettingItemWidget(
                    decoration: BoxDecoration(
                      color: context.scaffoldSecondary,
                    ),
                    leading: ic_delete.iconImage(
                        context: context, size: 18, color: context.icon),
                    paddingBeforeTrailing: 4,
                    title: languages.lblDeleteAccount,
                    titleTextStyle: context.boldTextStyle(),
                    padding: const EdgeInsets.only(
                        bottom: 16, right: 16, left: 16, top: 20),
                    onTap: () {
                      showConfirmDialogCustom(
                        height: 80,
                        width: 290,
                        context,
                        shape: appDialogShape(8),
                        title: languages.lblDeleteAccountConformation,
                        titleColor: context.dialogTitleColor,
                        backgroundColor: context.dialogBackgroundColor,
                        primaryColor: context.primary,
                        customCenterWidget: Image.asset(
                          ic_warning,
                          color: context.onSecondaryContainer,
                          height: 70,
                          width: 70,
                          fit: BoxFit.cover,
                        ),
                        positiveText: languages.lblDelete,
                        positiveTextColor: context.onPrimary,
                        negativeText: languages.lblCancel,
                        negativeTextColor: context.dialogCancelColor,
                        dialogType: DialogType.DELETE,
                        onAccept: (_) {
                          ifNotTester(context, () {
                            appStore.setLoading(true);

                            deleteAccountCompletely().then((value) async {
                              if (appStore.uid != "") {
                                await userService.removeDocument(appStore.uid);
                                await userService.deleteUser();
                              }
                              appStore.setLoading(false);

                              await clearPreferences();
                              toast(value.message);

                              push(SignInScreen(), isNewTask: true);
                            }).catchError((e) {
                              appStore.setLoading(false);
                              toast(e.toString());
                            });
                          });
                        },
                      );
                    },
                  ),
                  SettingItemWidget(
                    decoration: boxDecorationDefault(
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
              16.height,
              // VersionInfoWidget(
              //         prefixText: 'v', textStyle: context.secondaryTextStyle())
              //     .center(),
              16.height,
            ],
          ),
        );
      },
    );
  }
}
