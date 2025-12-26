import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/handyman/handyman_dashboard_screen.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/screens/maintenance_mode_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/app_widgets.dart';
import '../networks/rest_apis.dart';
import '../utils/constant.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  bool appNotSynced = false;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      _setThemeAwareStatusBar(context);
      init();
    });
  }

  /// Sets status bar color based on current theme mode
  /// Light mode: light background, dark icons/text
  /// Dark mode: dark background, light/white icons/text
  void _setThemeAwareStatusBar(BuildContext context) {
    setStatusBarColor(
      context.scaffold,
      statusBarBrightness:
          appStore.isDarkMode ? Brightness.dark : Brightness.light,
      statusBarIconBrightness:
          appStore.isDarkMode ? Brightness.light : Brightness.dark,
    );
  }

  Future<void> init() async {
    // Check if Demo Mode is enabled
    if (DEMO_MODE_ENABLED) {
      await _initDemoMode();
      return;
    }

    // Sync new configurations when app is open
    await setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);

    ///Set app configurations
    await getAppConfigurations().then((value) {}).catchError((e) async {
      if (!await isNetworkAvailable()) {
        toast(errorInternetNotAvailable);
      }
      log(e);
    });

    appStore.setLoading(false);
    if (!getBoolAsync(IS_APP_CONFIGURATION_SYNCED_AT_LEAST_ONCE)) {
      appNotSynced = true;
      setState(() {});
    } else {
      appStore.setLanguage(
          getStringAsync(SELECTED_LANGUAGE_CODE,
              defaultValue: DEFAULT_LANGUAGE),
          context: context);
      int themeModeIndex =
          getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
      if (themeModeIndex == THEME_MODE_SYSTEM) {
        appStore.setDarkMode(
            MediaQuery.of(context).platformBrightness == Brightness.dark);
      }

      if (appConfigurationStore.maintenanceModeStatus) {
        MaintenanceModeScreen()
            .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
      } else {
        // Check if the user is unauthorized and logged in, then clear preferences and cached data.
        // This condition occurs when the user is marked as inactive from the admin panel,
        if (!appConfigurationStore.isUserAuthorized && appStore.isLoggedIn) {
          await clearPreferences();
        }
        if (!appStore.isLoggedIn) {
          SignInScreen().launch(context,
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          await updateProfilePhoto();
          if (isUserTypeProvider) {
            _setThemeAwareStatusBar(context);
            ProviderDashboardScreen(index: 0).launch(context,
                isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
          } else if (isUserTypeHandyman) {
            _setThemeAwareStatusBar(context);
            HandymanDashboardScreen(index: 0).launch(context,
                isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
          } else {
            SignInScreen().launch(context, isNewTask: true);
          }
        }
      }
    }
  }

  /// Demo Mode Initialization
  /// Sets up required configuration values and navigates based on login status
  Future<void> _initDemoMode() async {
    // Set demo mode configurations
    await setValue(IS_APP_CONFIGURATION_SYNCED_AT_LEAST_ONCE, true);
    await appConfigurationStore.setISUserAuthorized(true);
    await appConfigurationStore.setMaintenanceModeStatus(false);

    // Set demo currency and other settings
    await appConfigurationStore.setCurrencySymbol('\$');
    await appConfigurationStore.setCurrencyCode('USD');
    await appConfigurationStore.setCurrencyPosition(CURRENCY_POSITION_LEFT);
    await appConfigurationStore.setPriceDecimalPoint(2);

    // Enable ALL features for demo mode
    await appConfigurationStore.setEnableUserWallet(true);
    await appConfigurationStore.setSlotServiceStatus(true);
    await appConfigurationStore.setJobRequestStatus(true);
    await appConfigurationStore.setEnableChat(true);
    await appConfigurationStore.setOnlinePaymentStatus(true);
    await appConfigurationStore.setServicePackageStatus(true);
    await appConfigurationStore.setServiceAddonStatus(true);
    await appConfigurationStore.setBlogStatus(true);
    await appConfigurationStore.setAdvancePaymentAllowed(true);
    await appConfigurationStore.setDigitalServiceStatus(true);
    await appConfigurationStore.setPromotionalBannerStatus(true);
    await appConfigurationStore.setAutoAssignStatus(true);

    // Enable ALL permissions for demo mode - Provider permissions
    await rolesAndPermissionStore.setService(true);
    await rolesAndPermissionStore.setServiceList(true);
    await rolesAndPermissionStore.setServiceAdd(true);
    await rolesAndPermissionStore.setServiceEdit(true);
    await rolesAndPermissionStore.setServiceDelete(true);

    await rolesAndPermissionStore.setHandyman(true);
    await rolesAndPermissionStore.setHandymanList(true);
    await rolesAndPermissionStore.setHandymanAdd(true);
    await rolesAndPermissionStore.setHandymanEdit(true);
    await rolesAndPermissionStore.setHandymanDelete(true);

    await rolesAndPermissionStore.setBooking(true);
    await rolesAndPermissionStore.setBookingList(true);
    await rolesAndPermissionStore.setBookingEdit(true);
    await rolesAndPermissionStore.setBookingView(true);

    await rolesAndPermissionStore.setPayment(true);
    await rolesAndPermissionStore.setPaymentList(true);

    await rolesAndPermissionStore.setBank(true);
    await rolesAndPermissionStore.setBankList(true);
    await rolesAndPermissionStore.setBankAdd(true);
    await rolesAndPermissionStore.setBankEdit(true);

    await rolesAndPermissionStore.setTax(true);
    await rolesAndPermissionStore.setTaxList(true);
    await rolesAndPermissionStore.setTaxAdd(true);
    await rolesAndPermissionStore.setTaxEdit(true);

    await rolesAndPermissionStore.setWallet(true);
    await rolesAndPermissionStore.setWalletList(true);

    await rolesAndPermissionStore.setEarning(true);
    await rolesAndPermissionStore.setEarningList(true);

    await rolesAndPermissionStore.setHandymanPayout(true);
    await rolesAndPermissionStore.setProviderPayout(true);

    await rolesAndPermissionStore.setHandymanType(true);
    await rolesAndPermissionStore.setHandymanTypeList(true);
    await rolesAndPermissionStore.setHandymanTypeAdd(true);

    await rolesAndPermissionStore.setPostJob(true);
    await rolesAndPermissionStore.setPostJobList(true);

    await rolesAndPermissionStore.setServicePackage(true);
    await rolesAndPermissionStore.setServicePackageList(true);
    await rolesAndPermissionStore.setServicePackageAdd(true);
    await rolesAndPermissionStore.setServicePackageEdit(true);

    await rolesAndPermissionStore.setServiceAddOn(true);
    await rolesAndPermissionStore.setServiceAddOnList(true);
    await rolesAndPermissionStore.setServiceAddOnAdd(true);
    await rolesAndPermissionStore.setServiceAddOnEdit(true);

    await rolesAndPermissionStore.setBlog(true);
    await rolesAndPermissionStore.setBlogList(true);
    await rolesAndPermissionStore.setBlogAdd(true);
    await rolesAndPermissionStore.setBlogEdit(true);

    await rolesAndPermissionStore.setDocument(true);
    await rolesAndPermissionStore.setDocumentList(true);
    await rolesAndPermissionStore.setDocumentAdd(true);

    await rolesAndPermissionStore.setProviderDocument(true);
    await rolesAndPermissionStore.setProviderDocumentList(true);
    await rolesAndPermissionStore.setProviderDocumentAdd(true);

    await rolesAndPermissionStore.setHelpDesk(true);
    await rolesAndPermissionStore.setHelpDeskList(true);
    await rolesAndPermissionStore.setHelpDeskAdd(true);

    await rolesAndPermissionStore.setPromotionalBanner(true);
    await rolesAndPermissionStore.setPromotionalBannerList(true);
    await rolesAndPermissionStore.setPromotionalBannerAdd(true);

    // Set subscription plan demo data to show Current Plan container
    await appStore.setEarningType(EARNING_TYPE_SUBSCRIPTION);
    await appStore.setPlanTitle('Free Plan');
    await appStore.setPlanEndDate('2024-02-09');
    await appStore.setPlanSubscribeStatus(true);

    // Set commission demo data to show Provider Type & My Commission container
    // Commission model: name, commission, type
    await setValue(DASHBOARD_COMMISSION,
        '{"name":"company","commission":70,"type":"percent"}');

    appStore.setLoading(false);

    // Set language
    appStore.setLanguage(
        getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE),
        context: context);

    // Handle theme mode
    int themeModeIndex =
        getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);
    if (themeModeIndex == THEME_MODE_SYSTEM) {
      appStore.setDarkMode(
          MediaQuery.of(context).platformBrightness == Brightness.dark);
    }

    // Small delay for splash visual effect
    await Future.delayed(const Duration(milliseconds: 800));

    // Auto-login support for demo mode
    // When DEMO_AUTO_LOGIN is true, automatically log in the user
    if (DEMO_AUTO_LOGIN && !appStore.isLoggedIn) {
      await _performDemoAutoLogin();
      return;
    }

    // Navigate based on login status
    if (!appStore.isLoggedIn) {
      SignInScreen().launch(context,
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    } else {
      if (isUserTypeProvider) {
        _setThemeAwareStatusBar(context);
        ProviderDashboardScreen(index: 0).launch(context,
            isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else if (isUserTypeHandyman) {
        _setThemeAwareStatusBar(context);
        HandymanDashboardScreen(index: 0).launch(context,
            isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      } else {
        SignInScreen().launch(context, isNewTask: true);
      }
    }
  }

  /// Auto-login for demo mode
  /// This bypasses the sign-in screen completely
  Future<void> _performDemoAutoLogin() async {
    // Get the auto-login user based on configured type
    final demoUser = DemoData.autoLoginUser;

    // Save demo user data to app store
    await appStore.setUserId(demoUser.id ?? 1);
    await appStore.setFirstName(demoUser.firstName ?? 'Demo');
    await appStore.setLastName(demoUser.lastName ?? 'User');
    await appStore.setUserEmail(demoUser.email ?? 'demo@provider.com');
    await appStore.setUserName(demoUser.username ?? 'demo_user');
    await appStore.setContactNumber(demoUser.contactNumber ?? '+1234567890');
    await appStore.setUserProfile(demoUser.profileImage ?? '');
    await appStore.setUserType(demoUser.userType ?? USER_TYPE_PROVIDER);
    await appStore.setDesignation(demoUser.designation ?? '');
    await appStore.setAddress(demoUser.address ?? '');
    await appStore.setCountryId(demoUser.countryId ?? 1);
    await appStore.setStateId(demoUser.stateId ?? 1);
    await appStore.setCityId(demoUser.cityId ?? 1);
    await appStore.setUId(demoUser.uid ?? 'demo_uid');
    await appStore.setToken(demoUser.apiToken ?? 'demo_token');
    await appStore.setProviderId(demoUser.providerId ?? 1);
    await appStore.setLoggedIn(true);
    await appStore.setTester(true);
    await appStore
        .setCreatedAt(demoUser.createdAt ?? DateTime.now().toString());

    // Set additional demo data based on user type
    if (demoUser.userType == USER_TYPE_PROVIDER) {
      // Provider-specific demo data is already set above
    } else if (demoUser.userType == USER_TYPE_HANDYMAN) {
      // Handyman-specific demo data
      await appStore.setHandymanAvailability(1);
      await appStore.setCompletedBooking(42);
      // Set handyman commission
      await setValue(DASHBOARD_COMMISSION,
          '{"name":"handyman","commission":15,"type":"percent"}');
    }

    // Navigate to appropriate dashboard
    if (demoUser.userType == USER_TYPE_PROVIDER) {
      _setThemeAwareStatusBar(context);
      ProviderDashboardScreen(index: 0).launch(context,
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    } else {
      _setThemeAwareStatusBar(context);
      HandymanDashboardScreen(index: 0).launch(context,
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }
  }

  updateProfilePhoto() async {
    getUserDetail(appStore.userId).then((value) async {
      await appStore.setUserProfile(value.data!.profileImage.validate());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            appStore.isDarkMode ? splash_background : splash_light_background,
            height: context.height(),
            width: context.width(),
            fit: BoxFit.cover,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(appLogo, height: 120, width: 120),
              32.height,
              Text(APP_NAME,
                  style:
                      context.boldTextStyle(size: 26, color: context.onSurface),
                  textAlign: TextAlign.center),
              16.height,
              if (appNotSynced)
                Observer(
                  builder: (_) => appStore.isLoading
                      ? LoaderWidget().center()
                      : TextButton(
                          child: Text(languages.reload,
                              style: context.boldTextStyle()),
                          onPressed: () {
                            appStore.setLoading(true);
                            init();
                          },
                        ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
