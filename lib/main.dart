import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/locale/applocalizations.dart';
import 'package:handyman_provider_flutter/locale/base_language.dart';
import 'package:handyman_provider_flutter/locale/language_en.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/notification_list_response.dart';
import 'package:handyman_provider_flutter/models/revenue_chart_data.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/models/shop_model.dart';
import 'package:handyman_provider_flutter/models/total_earning_response.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/models/wallet_history_list_response.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/auth_services.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/chat_messages_service.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/notification_service.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/user_services.dart';
import 'package:handyman_provider_flutter/provider/jobRequest/models/post_job_detail_response.dart';
import 'package:handyman_provider_flutter/screens/splash_screen.dart';
import 'package:handyman_provider_flutter/services/in_app_purchase.dart';
import 'package:handyman_provider_flutter/store/AppStore.dart';
import 'package:handyman_provider_flutter/store/filter_store.dart';
import 'package:handyman_provider_flutter/store/roles_and_permission_store.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:nb_utils/nb_utils.dart';
import 'app_theme.dart';
import 'helpDesk/model/help_desk_response.dart';
import 'models/bank_list_response.dart';
import 'models/booking_list_response.dart';
import 'models/booking_status_response.dart';
import 'models/dashboard_response.dart';
import 'models/document_list_response.dart';
import 'models/extra_charges_model.dart';
import 'models/handyman_dashboard_response.dart';
import 'models/payment_list_reasponse.dart';
import 'models/service_model.dart';
import 'provider/promotional_banner/model/promotional_banner_response.dart';
import 'provider/timeSlots/timeSlotStore/time_slot_store.dart';
import 'store/app_configuration_store.dart';
import 'utils/firebase_messaging_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//region Handle Background Firebase Message
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Message Data : ${message.data}');
  Firebase.initializeApp();
}
//endregion

//region Mobx Stores
AppStore appStore = AppStore();
TimeSlotStore timeSlotStore = TimeSlotStore();
AppConfigurationStore appConfigurationStore = AppConfigurationStore();
FilterStore filterStore = FilterStore();
RolesAndPermissionStore rolesAndPermissionStore = RolesAndPermissionStore();
//endregion

//region Firebase Services
UserService userService = UserService();
AuthService authService = AuthService();

ChatServices chatServices = ChatServices();
NotificationService notificationService = NotificationService();
//endregion

//region In App Purchase Service
InAppPurchaseService inAppPurchaseService = InAppPurchaseService();
//region

//region Global Variables
Languages languages = LanguageEn();
List<RevenueChartData> chartData = [];
List<ExtraChargesModel> chargesList = [];
//endregion

//region Cached Response Variables for Dashboard Tabs
DashboardResponse? cachedProviderDashboardResponse;
HandymanDashBoardResponse? cachedHandymanDashboardResponse;
List<BookingData>? cachedBookingList;
List<PaymentData>? cachedPaymentList;
List<NotificationData>? cachedNotifications;
List<BookingStatusResponse>? cachedBookingStatusDropdown;
List<(int serviceId, ServiceDetailResponse)?> listOfCachedData = [];
List<BookingDetailResponse> cachedBookingDetailList = [];
List<(int postJobId, PostJobDetailResponse)?> cachedPostJobList = [];
List<UserData>? cachedHandymanList;
List<TotalData>? cachedTotalDataList;
List<WalletHistory>? cachedWalletList;
List<BankHistory>? cachedBankList;
List<HelpDeskListData>? cachedHelpDeskListData;
List<PromotionalBannerListData>? cachedPromotionalBannerListData;
List<ServiceData>? cachedServiceData;
List<UserData>? cachedUserData;
DocumentListResponse? cachedDocumentListResponse;
List<ShopModel> cachedShopList = [];

//endregion

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');

  await initialize();

  if (!isDesktop) {
    Firebase.initializeApp().then((value) {
      if (kReleaseMode) {
        FlutterError.onError =
            FirebaseCrashlytics.instance.recordFlutterFatalError;
      }

      /// Subscribe Firebase Topic
      subscribeToFirebaseTopic();
    }).catchError((e) {
      log(e.toString());
    });
  }
  HttpOverrides.global = MyHttpOverrides();

  defaultSettings();

  localeLanguageList = languageList();

  appStore.setLanguage(
      getStringAsync(SELECTED_LANGUAGE_CODE, defaultValue: DEFAULT_LANGUAGE));

  // Initialize theme mode BEFORE runApp to ensure correct theme on first frame
  await _initializeThemeMode();

  runApp(MyApp());
}

/// Initialize theme mode before app starts
/// This ensures the correct theme is applied from the first frame in release mode
Future<void> _initializeThemeMode() async {
  // Read the stored theme mode preference
  int storedThemeModeIndex =
      getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);

  // IMPORTANT: Sync the appStore.themeModeIndex with the stored value
  // This is needed because appStore is created before initialize() is called,
  // so the initial getIntAsync in AppStore returns the default value
  appStore.themeModeIndex = storedThemeModeIndex;

  // Also ensure it's persisted (in case it wasn't set before)
  await setValue(THEME_MODE_INDEX, storedThemeModeIndex);

  log('_initializeThemeMode: storedThemeModeIndex = $storedThemeModeIndex');

  if (storedThemeModeIndex == THEME_MODE_LIGHT) {
    await appStore.setDarkMode(false);
  } else if (storedThemeModeIndex == THEME_MODE_DARK) {
    await appStore.setDarkMode(true);
  } else if (storedThemeModeIndex == THEME_MODE_SYSTEM) {
    // Set theme based on system preference
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    await appStore.setDarkMode(brightness == Brightness.dark);
    log('System mode: brightness = $brightness');
  }
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
  }

  void init() async {
    afterBuildCreated(() {
      _updateThemeFromPreference();
    });
  }

  void _updateThemeFromPreference() {
    // Use the MobX observable directly - it's already initialized from SharedPreferences
    int val = appStore.themeModeIndex;

    if (val == THEME_MODE_LIGHT) {
      appStore.setDarkMode(false);
    } else if (val == THEME_MODE_DARK) {
      appStore.setDarkMode(true);
    } else if (val == THEME_MODE_SYSTEM) {
      // Set theme based on system preference
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      appStore.setDarkMode(brightness == Brightness.dark);
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    // Called when system theme changes (e.g., user switches dark/light mode in phone settings)
    // Check BOTH the MobX observable AND SharedPreferences to handle initialization edge cases
    int val = appStore.themeModeIndex;

    // Also read directly from SharedPreferences as fallback in case observable wasn't synced
    int storedVal =
        getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);

    // If there's a mismatch, sync them
    if (val != storedVal) {
      log('didChangePlatformBrightness: Observable ($val) != SharedPrefs ($storedVal), syncing...');
      appStore.themeModeIndex = storedVal;
      val = storedVal;
    }

    log('didChangePlatformBrightness called - themeModeIndex: $val');

    if (val == THEME_MODE_SYSTEM) {
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final isDark = brightness == Brightness.dark;

      log('System brightness changed - isDark: $isDark, current appStore.isDarkMode: ${appStore.isDarkMode}');

      // Only update if the theme actually changed
      if (appStore.isDarkMode != isDark) {
        appStore.setDarkMode(isDark);
        log('Theme updated to ${isDark ? "dark" : "light"} mode');

        // Force UI rebuild
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RestartAppWidget(
      child: SafeArea(
        top: false,
        child: Observer(
          builder: (_) => MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            home: SplashScreen(),
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            supportedLocales: LanguageDataModel.languageLocales(),
            localizationsDelegates: const [
              AppLocalizations(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
            localeResolutionCallback: (locale, supportedLocales) => locale,
            locale: Locale(appStore.selectedLanguageCode),
          ),
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
