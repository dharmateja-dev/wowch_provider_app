import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/payment_list_reasponse.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/fragments/shimmer/provider_payment_shimmer.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/demo_data.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';

class ProviderPaymentFragment extends StatefulWidget {
  const ProviderPaymentFragment({Key? key}) : super(key: key);

  @override
  State<ProviderPaymentFragment> createState() =>
      _ProviderPaymentFragmentState();
}

class _ProviderPaymentFragmentState extends State<ProviderPaymentFragment> {
  List<PaymentData> list = [];
  Future<List<PaymentData>>? future;

  UniqueKey keyForStatus = UniqueKey();

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // Demo Mode: Use demo data instead of backend API
    if (DEMO_MODE_ENABLED) {
      list = demoPayments;
      cachedPaymentList = list;
      isLastPage = true;
      future = Future.value(list);
      setState(() {});
      return;
    }

    future = getPaymentAPI(page, list, (p0) {
      isLastPage = p0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SnapHelperWidget<List<PaymentData>>(
          initialData: cachedPaymentList,
          future: future,
          loadingWidget: ProviderPaymentShimmer(),
          onSuccess: (list) {
            return AnimatedListView(
              itemCount: list.length,
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              physics: const AlwaysScrollableScrollPhysics(),
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              onSwipeRefresh: () async {
                page = 1;

                init();
                setState(() {});

                return await 2.seconds.delay;
              },
              onNextPage: () {
                if (!isLastPage) {
                  page++;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                }
              },
              itemBuilder: (p0, index) {
                PaymentData data = list[index];

                return GestureDetector(
                  onTap: () {
                    BookingDetailScreen(bookingId: data.bookingId.validate())
                        .launch(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: context.width(),
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(),
                      backgroundColor: context.scaffoldBackgroundColor,
                      border:
                          Border.all(color: context.dividerColor, width: 1.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: boxDecorationWithRoundedCorners(
                            backgroundColor: primary.withValues(alpha: 0.2),
                            borderRadius: radiusOnly(
                                topLeft: defaultRadius,
                                topRight: defaultRadius),
                          ),
                          width: context.width(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(data.customerName.validate(),
                                      style: context.boldTextStyle(size: 12))
                                  .flexible(),
                              Text('#' + data.bookingId.validate().toString(),
                                  style: context.boldTextStyle(
                                      color: primary, size: 12)),
                            ],
                          ),
                        ),
                        4.height,
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(languages.lblPaymentID,
                                    style:
                                        context.secondaryTextStyle(size: 12)),
                                Text("#" + data.id.validate().toString(),
                                    style: context.boldTextStyle(size: 12)),
                              ],
                            ).paddingSymmetric(vertical: 4),
                            Divider(
                                thickness: 0.9, color: context.dividerColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(languages.paymentStatus,
                                    style:
                                        context.secondaryTextStyle(size: 12)),
                                Text(
                                  getPaymentStatusText(
                                      data.paymentStatus
                                          .validate(value: languages.pending),
                                      data.paymentMethod),
                                  style: context.boldTextStyle(size: 12),
                                ),
                              ],
                            ).paddingSymmetric(vertical: 4),
                            Divider(
                                thickness: 0.9, color: context.dividerColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(languages.paymentMethod,
                                    style:
                                        context.secondaryTextStyle(size: 12)),
                                Text(
                                  (data.paymentMethod.validate().isNotEmpty
                                          ? data.paymentMethod.validate()
                                          : languages.notAvailable)
                                      .capitalizeFirstLetter(),
                                  style: context.boldTextStyle(size: 12),
                                ),
                              ],
                            ).paddingSymmetric(vertical: 4),
                            Divider(
                                thickness: 0.9, color: context.dividerColor),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(languages.lblAmount,
                                    style:
                                        context.secondaryTextStyle(size: 12)),
                                if (data.isPackageBooking)
                                  PriceWidget(
                                    price: data.packageData!.price.validate(),
                                    color: primary,
                                    size: 12,
                                    isBoldText: true,
                                  )
                                else
                                  PriceWidget(
                                    price: data.totalAmount.validate(),
                                    color: primary,
                                    size: 14,
                                    isBoldText: true,
                                  ),
                              ],
                            ).paddingSymmetric(vertical: 4),
                          ],
                        ).paddingSymmetric(horizontal: 16, vertical: 10),
                        // 8.height,
                      ],
                    ),
                  ),
                );
              },
              emptyWidget: NoDataWidget(
                title: languages.lblNoPayments,
                imageWidget: const EmptyStateWidget(),
              ),
            );
          },
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              imageWidget: const ErrorStateWidget(),
              retryText: languages.reload,
              onRetry: () {
                keyForStatus = UniqueKey();
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
    );
  }
}
