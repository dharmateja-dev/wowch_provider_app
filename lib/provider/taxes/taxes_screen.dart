import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/tax_list_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/taxes/shimmer/taxes_shimmer.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_widgets.dart';
import '../../components/empty_error_state_widget.dart';

class TaxesScreen extends StatefulWidget {
  @override
  _TaxesScreenState createState() => _TaxesScreenState();
}

class _TaxesScreenState extends State<TaxesScreen> {
  Future<List<TaxData>>? future;
  List<TaxData> taxList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getTaxList(
      page: page,
      list: taxList,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: UniqueKey(),
      backgroundColor: context.scaffoldSecondary,
      appBar: appBarWidget(
        languages.lblTaxes,
        showBack: true,
        backWidget: BackWidget(),
        textColor: context.onPrimary,
        color: context.primary,
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<TaxData>>(
            future: future,
            onSuccess: (list) {
              return AnimatedListView(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: list.length,
                padding: const EdgeInsets.all(16),
                disposeScrollController: false,
                shrinkWrap: true,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemBuilder: (context, index) {
                  TaxData data = list[index];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: boxDecorationDefault(
                      borderRadius: radius(12),
                      color: context.cardSecondary,
                      border: Border.all(color: context.cardSecondaryBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tax Name Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languages.lblTaxName,
                              style: context.primaryTextStyle(size: 14),
                            ),
                            Text(
                              '${data.title.validate()}',
                              style: context.boldTextStyle(),
                            ),
                          ],
                        ),

                        12.height,

                        // Divider
                        Divider(
                          color: context.cardSecondaryBorder,
                          height: 1,
                        ),

                        12.height,

                        // Tax Value Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languages.lblMyTax,
                              style: context.primaryTextStyle(size: 14),
                            ),
                            Row(
                              children: [
                                Text(
                                  isCommissionTypePercent(data.type)
                                      ? '${data.value.validate()}%'
                                      : data.value.validate().toPriceFormat(),
                                  style: context.boldTextStyle(
                                    color: context.primaryLiteColor,
                                  ),
                                ),
                                4.width,
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: boxDecorationDefault(
                                    color: context.primaryLiteColor
                                        .withValues(alpha: 0.3),
                                    borderRadius: radius(6),
                                  ),
                                  child: Text(
                                    data.type.capitalizeFirstLetter(),
                                    style: context.boldTextStyle(
                                      size: 12,
                                      color: context.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                emptyWidget: NoDataWidget(
                  title: languages.lblNoTaxesFound,
                  imageWidget: const EmptyStateWidget(),
                ),
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
              );
            },
            loadingWidget: const TaxesShimmer(),
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
