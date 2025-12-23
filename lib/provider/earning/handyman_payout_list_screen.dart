import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_widgets.dart';
import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import '../../components/price_widget.dart';
import '../../main.dart';
import '../../models/user_data.dart';
import 'handyman_earning_repository.dart';
import 'model/payout_history_response.dart';

// Dummy data for testing UI
final List<PayoutData> dummyPayoutList = [
  PayoutData(
    id: 1,
    amount: 2500.00,
    paymentMethod: 'bank_transfer',
    description:
        'Monthly payout for December 2024 - Completed service payments',
    createdAt: 'Dec 20, 2024',
  ),
  PayoutData(
    id: 2,
    amount: 1850.50,
    paymentMethod: 'paypal',
    description: 'Weekly bonus payout',
    createdAt: 'Dec 15, 2024',
  ),
  PayoutData(
    id: 3,
    amount: 3200.00,
    paymentMethod: 'cash',
    description: '',
    createdAt: 'Dec 10, 2024',
  ),
  PayoutData(
    id: 4,
    amount: 750.25,
    paymentMethod: 'stripe',
    description: 'Emergency service bonus',
    createdAt: 'Dec 05, 2024',
  ),
  PayoutData(
    id: 5,
    amount: 4500.00,
    paymentMethod: 'bank_transfer',
    description: 'November 2024 earnings settlement',
    createdAt: 'Nov 28, 2024',
  ),
];

class HandymanPayoutListScreen extends StatefulWidget {
  final UserData user;

  const HandymanPayoutListScreen({required this.user});

  @override
  _HandymanPayoutListScreenState createState() =>
      _HandymanPayoutListScreenState();
}

class _HandymanPayoutListScreenState extends State<HandymanPayoutListScreen> {
  Future<List<PayoutData>>? future;
  List<PayoutData> payoutList = [];

  int currentPage = 1;
  bool isLastPage = false;

  bool useDummyData = true; // Toggle for dummy data

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (useDummyData) {
      // Use dummy data for UI testing
      future = Future.value(dummyPayoutList);
      payoutList = dummyPayoutList;
      setState(() {});
    } else {
      future = getHandymanPayoutHistoryList(
        currentPage,
        id: widget.user.id!,
        payoutList: payoutList,
        callback: (res) {
          appStore.setLoading(false);
          isLastPage = res;
          setState(() {});
        },
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  // Get payment method icon
  IconData _getPaymentIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'bank_transfer':
        return Icons.account_balance;
      case 'paypal':
        return Icons.payments_outlined;
      case 'stripe':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      default:
        return Icons.payment;
    }
  }

  // Get formatted payment method name
  String _getPaymentMethodName(String? method) {
    switch (method?.toLowerCase()) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'cash':
        return 'Cash';
      default:
        return method?.capitalizeFirstLetter() ?? 'Unknown';
    }
  }

  // Manual date formatter for display
  String _formatDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';

    // If already formatted (e.g., "Dec 20, 2024"), return as is
    if (!dateStr.contains('-') && !dateStr.contains('/')) {
      return dateStr;
    }

    try {
      // Try to parse API date format (yyyy-MM-dd HH:mm:ss)
      final parts = dateStr.split(' ')[0].split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final month = int.parse(parts[1]);
        final day = parts[2];

        const months = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];

        return '${months[month]} $day, $year';
      }
    } catch (e) {
      // Return original if parsing fails
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldBackgroundColor: context.scaffoldSecondary,
      appBarTitle: languages.handymanPayoutList,
      body: SnapHelperWidget<List<PayoutData>>(
        future: future,
        loadingWidget: LoaderWidget(),
        onSuccess: (payoutList) {
          return AnimatedListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
            itemCount: payoutList.length,
            slideConfiguration:
                SlideConfiguration(delay: 50.milliseconds, verticalOffset: 400),
            itemBuilder: (_, index) {
              PayoutData data = payoutList[index];

              return Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: context.width(),
                decoration: boxDecorationDefault(
                  borderRadius: radius(8),
                  color: context.cardSecondary,
                  border: Border.all(
                      color: context.cardSecondaryBorder, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with Payment Method
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.secondaryContainer,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: context.primaryLiteColor
                                  .withValues(alpha: 0.3),
                              borderRadius: radius(8),
                            ),
                            child: Icon(
                              _getPaymentIcon(data.paymentMethod),
                              color: context.primary,
                              size: 22,
                            ),
                          ),
                          12.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languages.paymentMethod,
                                style: context.primaryTextStyle(size: 12),
                              ),
                              4.height,
                              Text(
                                _getPaymentMethodName(data.paymentMethod),
                                style: context.boldTextStyle(
                                    color: context.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Description (if exists)
                    if (data.description.validate().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.description_outlined,
                              color: context.iconMuted,
                              size: 18,
                            ),
                            8.width,
                            Text(
                              data.description.validate(),
                              style: context.primaryTextStyle(size: 13),
                            ).expand(),
                          ],
                        ),
                      ),

                    // Amount and Date Section
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: boxDecorationDefault(
                        color: context.scaffoldSecondary,
                        borderRadius: radius(10),
                      ),
                      child: Column(
                        children: [
                          // Amount Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.attach_money,
                                    color: context.iconMuted,
                                    size: 18,
                                  ),
                                  6.width,
                                  Text(
                                    languages.lblAmount,
                                    style: context.primaryTextStyle(size: 14),
                                  ),
                                ],
                              ),
                              PriceWidget(
                                price: data.amount.validate(),
                                color: context.primaryLiteColor,
                                isBoldText: true,
                                size: 16,
                              ),
                            ],
                          ),

                          const Divider(height: 24),

                          // Date Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: context.iconMuted,
                                    size: 18,
                                  ),
                                  6.width,
                                  Text(
                                    languages.lblDate,
                                    style: context.primaryTextStyle(size: 14),
                                  ),
                                ],
                              ),
                              Text(
                                useDummyData
                                    ? data.createdAt.validate()
                                    : _formatDisplayDate(data.createdAt),
                                style: context.boldTextStyle(size: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            onNextPage: () {
              if (!isLastPage && !useDummyData) {
                currentPage++;

                appStore.setLoading(true);

                init();
                setState(() {});
              }
            },
            onSwipeRefresh: () async {
              currentPage = 1;

              init();
              setState(() {});
              return await 2.seconds.delay;
            },
            emptyWidget: NoDataWidget(
              title: languages.noPayoutFound,
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
              currentPage = 1;
              appStore.setLoading(true);

              init();
              setState(() {});
            },
          );
        },
      ),
    );
  }
}
