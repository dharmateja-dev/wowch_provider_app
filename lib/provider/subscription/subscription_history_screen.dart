import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/provider_subscription_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/subscription/components/subscription_widget.dart';
import 'package:handyman_provider_flutter/provider/subscription/shimmer/subscription_shimmer.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';

/// Demo subscription data for UI testing
List<ProviderSubscriptionModel> get demoSubscriptions => [
      ProviderSubscriptionModel(
        id: 1,
        title: 'Premium Plan',
        identifier: 'premium',
        amount: 99,
        type: 'monthly',
        startAt:
            DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
        endAt: DateTime.now().add(const Duration(days: 15)).toIso8601String(),
        status: SUBSCRIPTION_STATUS_ACTIVE,
        description: 'Full access to all features',
      ),
      ProviderSubscriptionModel(
        id: 2,
        title: 'Basic Plan',
        identifier: 'basic',
        amount: 49,
        type: 'monthly',
        startAt:
            DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
        endAt:
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
        status: SUBSCRIPTION_STATUS_INACTIVE,
        description: 'Basic features access',
      ),
      ProviderSubscriptionModel(
        id: 3,
        title: 'Free Trial',
        identifier: FREE,
        amount: 0,
        type: 'trial',
        startAt:
            DateTime.now().subtract(const Duration(days: 90)).toIso8601String(),
        endAt:
            DateTime.now().subtract(const Duration(days: 83)).toIso8601String(),
        status: SUBSCRIPTION_STATUS_INACTIVE,
        description: '7-day free trial',
      ),
    ];

class SubscriptionHistoryScreen extends StatefulWidget {
  @override
  _SubscriptionHistoryScreenState createState() =>
      _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  Future<List<ProviderSubscriptionModel>>? future;
  List<ProviderSubscriptionModel> subscriptionsList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (DEMO_MODE_ENABLED) {
      // Use demo data in demo mode
      future = Future.value(demoSubscriptions);
    } else {
      future = getSubscriptionHistory(
        page: page,
        providerSubscriptionList: subscriptionsList,
        lastPageCallback: (b) {
          isLastPage = b;
        },
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: appBarWidget(languages.lblSubscriptionHistory,
          backWidget: BackWidget(),
          elevation: 0,
          color: context.primary,
          center: true,
          textColor: context.onPrimary),
      body: Stack(
        children: [
          SnapHelperWidget<List<ProviderSubscriptionModel>>(
            future: future,
            loadingWidget: const SubscriptionShimmer(),
            onSuccess: (snap) {
              if (snap.isEmpty)
                return NoDataWidget(
                  title: languages.noSubscriptionFound,
                  subTitle: languages.noSubscriptionSubTitle,
                  imageWidget: const EmptyStateWidget(),
                );

              return AnimatedListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: snap.length,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                slideConfiguration: SlideConfiguration(verticalOffset: 400),
                disposeScrollController: false,
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                itemBuilder: (BuildContext context, index) {
                  return SubscriptionWidget(snap[index]);
                },
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  if (appConfigurationStore.isInAppPurchaseEnable) {
                    inAppPurchaseService.checkSubscriptionSync();
                  }
                  setState(() {});

                  return await 2.seconds.delay;
                },
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: const ErrorStateWidget(),
                retryText: languages.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
