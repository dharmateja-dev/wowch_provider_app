import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';
import '../../components/selected_item_widget.dart';
import '../../main.dart';
import '../../utils/app_configuration.dart';
import '../../utils/constant.dart';
import '../../utils/demo_mode.dart';

/// Demo payment types for testing
List<PaymentSetting> get demoPaymentTypes => [
      PaymentSetting(
        id: 1,
        title: 'Wallet',
        type: PAYMENT_METHOD_FROM_WALLET,
        status: 1,
      ),
      PaymentSetting(
        id: 2,
        title: 'Cash On Delivery',
        type: PAYMENT_METHOD_COD,
        status: 1,
      ),
      PaymentSetting(
        id: 3,
        title: 'Stripe Payment',
        type: 'stripe',
        status: 1,
      ),
      PaymentSetting(
        id: 4,
        title: 'Razor Pay',
        type: 'razorPay',
        status: 1,
      ),
      PaymentSetting(
        id: 5,
        title: 'FlutterWave',
        type: 'flutterwave',
        status: 1,
      ),
    ];

class PaymentTypeFilter extends StatefulWidget {
  final List<PaymentSetting> paymentTypeList;

  PaymentTypeFilter({required this.paymentTypeList});

  @override
  _PaymentTypeFilterState createState() => _PaymentTypeFilterState();
}

class _PaymentTypeFilterState extends State<PaymentTypeFilter> {
  late List<PaymentSetting> paymentList;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // Use demo data when demo mode is enabled
    if (DEMO_MODE_ENABLED) {
      paymentList = List<PaymentSetting>.from(demoPaymentTypes);
    } else {
      paymentList = widget.paymentTypeList;
    }

    // Restore selection state from filterStore
    for (var payment in paymentList) {
      payment.isSelected = filterStore.paymentType.contains(payment.type);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (paymentList.isEmpty) {
      return NoDataWidget(
        title: languages.noPaymentMethodsFound,
        imageWidget: const EmptyStateWidget(),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Container(
        alignment: Alignment.topLeft,
        child: AnimatedWrap(
          spacing: 12,
          runSpacing: 12,
          slideConfiguration: sliderConfigurationGlobal,
          itemCount: paymentList.length,
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          itemBuilder: (context, index) {
            final PaymentSetting res = paymentList[index];

            return Container(
              width: context.width(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.secondaryContainer,
                border: Border.all(
                  color: res.isSelected ? context.primary : Colors.transparent,
                  width: 1,
                ),
                borderRadius: radius(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      res.title.validate(),
                      style: context.boldTextStyle(),
                    ),
                  ),
                  4.width,
                  SelectedItemWidget(isSelected: res.isSelected),
                ],
              ),
            ).onTap(
              () {
                setState(() {
                  res.isSelected = !res.isSelected;

                  if (res.isSelected) {
                    filterStore.addToPaymentTypeList(
                      paymentTypeList: res.type.validate(),
                    );
                  } else {
                    filterStore.removeFromPaymentTypeList(
                      paymentTypeList: res.type.validate(),
                    );
                  }
                });
              },
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            );
          },
        ).paddingAll(16),
      ),
    );
  }
}
