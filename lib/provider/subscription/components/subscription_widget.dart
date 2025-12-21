import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/provider_subscription_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionWidget extends StatefulWidget {
  final ProviderSubscriptionModel data;

  SubscriptionWidget(this.data);

  @override
  SubscriptionWidgetState createState() => SubscriptionWidgetState();
}

class SubscriptionWidgetState extends State<SubscriptionWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  Future<void> cancelPlan() async {
    showConfirmDialogCustom(
      context,
      height: 80,
      width: 290,
      shape: appDialogShape(8),
      title: languages.lblSubscriptionTitle,
      titleColor: context.dialogTitleColor,
      backgroundColor: context.dialogBackgroundColor,
      primaryColor: context.primary,
      customCenterWidget: Image.asset(
        ic_warning,
        color: context.dialogIconColor,
        height: 70,
        width: 70,
        fit: BoxFit.cover,
      ),
      positiveText: languages.lblYes,
      positiveTextColor: context.onPrimary,
      negativeText: languages.lblNo,
      negativeTextColor: context.dialogCancelColor,
      dialogType: DialogType.CONFIRMATION,
      onAccept: (_) {
        if (appConfigurationStore.isInAppPurchaseEnable) {
          cancelRevenueCatSubscription();
        } else {
          cancelCurrentSubscription();
        }
      },
    );
  }

  Future<void> cancelCurrentSubscription() async {
    Map req = {
      CommonKeys.id: widget.data.id,
    };

    appStore.setLoading(true);

    cancelSubscription(req).then((value) {
      appStore.setLoading(false);
      widget.data.status = SUBSCRIPTION_STATUS_INACTIVE;
      appStore.setPlanSubscribeStatus(false);
      if (appConfigurationStore.isInAppPurchaseEnable) {
        appStore
            .setProviderCurrentSubscriptionPlan(ProviderSubscriptionModel());
        appStore.setActiveRevenueCatIdentifier('');
      }

      push(ProviderDashboardScreen(),
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
      setState(() {});
    }).catchError(
      (e) {
        appStore.setLoading(false);
        toast(e.toString());
      },
    );
  }

  Future<void> cancelRevenueCatSubscription() async {
    await inAppPurchaseService.init();
    inAppPurchaseService.loginToRevenueCate().then(
      (value) async {
        await inAppPurchaseService.getCustomerInfo().then(
          (value) {
            if (value.managementURL.validate().isNotEmpty) {
              commonLaunchUrl(value.managementURL.validate(),
                      launchMode: LaunchMode.externalApplication)
                  .then((value) async {
                await inAppPurchaseService.init();
                await inAppPurchaseService.loginToRevenueCate();
                await inAppPurchaseService.getCustomerInfo().then((data) {
                  if (data.activeSubscriptions.isEmpty) {
                    cancelCurrentSubscription();
                  }
                });
              });
            } else {
              //TODO: Implement if needed
            }
          },
        );
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.cardSecondary,
        borderRadius: radius(),
        border: Border.all(
          width: 1,
          color: widget.data.status.validate() == SUBSCRIPTION_STATUS_ACTIVE
              ? context.primary
              : context.error,
        ),
      ),
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${formatBookingDate(widget.data.startAt.validate().toString(), format: 'MMMM d, yyyy')} - ${formatBookingDate(widget.data.endAt.validate().toString(), format: 'MMMM d, yyyy')}',
            style: boldTextStyle(letterSpacing: 1.3),
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(languages.lblPlan,
                  style: primaryTextStyle(color: context.textGrey)),
              Text(widget.data.title.validate().capitalizeFirstLetter(),
                  style: boldTextStyle()),
            ],
          ),
          16.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(languages.lblType,
                  style: primaryTextStyle(color: context.textGrey)),
              Text(widget.data.type.validate().capitalizeFirstLetter(),
                  style: boldTextStyle()),
            ],
          ),
          if (widget.data.identifier != FREE)
            Column(
              children: [
                16.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(languages.lblAmount,
                        style: primaryTextStyle(color: context.textGrey)),
                    16.width,
                    PriceWidget(
                      price: widget.data.amount.validate(),
                      color: context.primary,
                      isBoldText: true,
                    ).flexible(),
                  ],
                ),
              ],
            ),
          if (widget.data.status.validate() == SUBSCRIPTION_STATUS_ACTIVE &&
              !appConfigurationStore.isInAppPurchaseEnable)
            AppButton(
              text: languages.lblCancelPlan.toUpperCase(),
              margin: const EdgeInsets.only(top: 16),
              width: context.width(),
              elevation: 0,
              color: context.primary,
              onTap: () {
                ifNotTester(context, () {
                  cancelPlan();
                });
              },
            )
        ],
      ),
    );
  }
}
