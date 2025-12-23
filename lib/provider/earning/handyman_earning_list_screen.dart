import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/provider/earning/shimmer/handyman_earning_list_shimmer.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import '../../main.dart';
import 'component/earning_item_widget.dart';
import 'handyman_earning_repository.dart';
import 'model/earning_list_model.dart';

// Dummy data for testing UI
final List<EarningListModel> dummyEarnings = [
  EarningListModel(
    handymanId: 1,
    handymanName: 'John Smith',
    email: 'john.smith@example.com',
    handymanImage: 'https://randomuser.me/api/portraits/men/1.jpg',
    commission: 15,
    commissionType: 'percent',
    totalBookings: 45,
    totalEarning: 12500.00,
    providerTotalAmount: 10625.00,
    adminEarning: 1875.00,
    handymanDueAmount: 3500.00,
    handymanPaidEarning: 7125.00,
    handymanTotalAmount: 10625.00,
    taxes: 250.00,
    taxesFormate: '\$250.00',
  ),
  EarningListModel(
    handymanId: 2,
    handymanName: 'Sarah Johnson',
    email: 'sarah.j@example.com',
    handymanImage: 'https://randomuser.me/api/portraits/women/2.jpg',
    commission: 12,
    commissionType: 'percent',
    totalBookings: 32,
    totalEarning: 8750.00,
    providerTotalAmount: 7700.00,
    adminEarning: 1050.00,
    handymanDueAmount: 2200.00,
    handymanPaidEarning: 5500.00,
    handymanTotalAmount: 7700.00,
    taxes: 175.00,
    taxesFormate: '\$175.00',
  ),
  EarningListModel(
    handymanId: 3,
    handymanName: 'Mike Wilson',
    email: 'mike.wilson@example.com',
    handymanImage: 'https://randomuser.me/api/portraits/men/3.jpg',
    commission: 10,
    commissionType: 'percent',
    totalBookings: 28,
    totalEarning: 6200.00,
    providerTotalAmount: 5580.00,
    adminEarning: 620.00,
    handymanDueAmount: 0.00, // No due amount - paid in full
    handymanPaidEarning: 5580.00,
    handymanTotalAmount: 5580.00,
    taxes: 124.00,
    taxesFormate: '\$124.00',
  ),
  EarningListModel(
    handymanId: 4,
    handymanName: 'Emily Brown',
    email: 'emily.b@example.com',
    handymanImage: 'https://randomuser.me/api/portraits/women/4.jpg',
    commission: 15,
    commissionType: 'percent',
    totalBookings: 19,
    totalEarning: 4500.00,
    providerTotalAmount: 3825.00,
    adminEarning: 675.00,
    handymanDueAmount: 1500.00,
    handymanPaidEarning: 2325.00,
    handymanTotalAmount: 3825.00,
    taxes: 90.00,
    taxesFormate: '\$90.00',
  ),
  EarningListModel(
    handymanId: 5,
    handymanName: 'David Lee',
    email: 'david.lee@example.com',
    handymanImage: 'https://randomuser.me/api/portraits/men/5.jpg',
    commission: 18,
    commissionType: 'percent',
    totalBookings: 52,
    totalEarning: 15800.00,
    providerTotalAmount: 12956.00,
    adminEarning: 2844.00,
    handymanDueAmount: 4500.00,
    handymanPaidEarning: 8456.00,
    handymanTotalAmount: 12956.00,
    taxes: 316.00,
    taxesFormate: '\$316.00',
  ),
];

class HandymanEarningListScreen extends StatefulWidget {
  const HandymanEarningListScreen({Key? key}) : super(key: key);

  @override
  State<HandymanEarningListScreen> createState() =>
      _HandymanEarningListScreenState();
}

class _HandymanEarningListScreenState extends State<HandymanEarningListScreen> {
  Future<List<EarningListModel>>? future;
  List<EarningListModel> earningList = [];

  bool isLastPage = false;
  bool useDummyData = true; // Toggle for dummy data

  int page = 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (useDummyData) {
      // Use dummy data for UI testing
      earningList = dummyEarnings;
      future = Future.value(earningList);
      isLastPage = true;
      setState(() {});
    } else {
      future = getHandymanEarningList(
        page: page,
        earnings: earningList,
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldBackgroundColor: context.scaffoldSecondary,
      appBarTitle: languages.handymanEarnings,
      body: SnapHelperWidget<List<EarningListModel>>(
        future: future,
        loadingWidget: HandymanEarningListShimmer(),
        onSuccess: (earnings) {
          return AnimatedListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
            itemCount: earningList.length,
            slideConfiguration:
                SlideConfiguration(delay: 50.milliseconds, verticalOffset: 400),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            itemBuilder: (_, index) {
              return EarningItemWidget(
                earningList[index],
                onUpdate: () {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
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
            emptyWidget: NoDataWidget(
              title: languages.lblNoEarningFound,
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
              page = 1;
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
