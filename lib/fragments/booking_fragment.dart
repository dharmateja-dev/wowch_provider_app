import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/booking_item_component.dart';
import 'package:handyman_provider_flutter/fragments/shimmer/booking_shimmer.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_list_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_data.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/empty_error_state_widget.dart';
import '../components/price_widget.dart';
import '../store/filter_store.dart';
import '../utils/colors.dart';
import '../utils/configs.dart';
import 'components/total_earnings_components.dart';

String selectedBookingStatus = BOOKING_PAYMENT_STATUS_ALL;

class BookingFragment extends StatefulWidget {
  @override
  BookingFragmentState createState() => BookingFragmentState();
}

class BookingFragmentState extends State<BookingFragment>
    with SingleTickerProviderStateMixin {
  ScrollController scrollController = ScrollController();

  int page = 1;
  List<BookingData> bookings = [];

  bool isLastPage = false;
  bool hasError = false;
  bool isApiCalled = false;

  Future<List<BookingData>>? future;
  UniqueKey keyForList = UniqueKey();

  FocusNode myFocusNode = FocusNode();

  TextEditingController searchCont = TextEditingController();

  String totalEarnings = '';
  PaymentBreakdown paymentBreakdownData = PaymentBreakdown();

  @override
  void initState() {
    super.initState();
    selectedBookingStatus = BOOKING_PAYMENT_STATUS_ALL;
    init();
    filterStore = FilterStore();

    LiveStream().on(LIVESTREAM_UPDATE_BOOKING_STATUS_WISE, (data) {
      if (data is String && data.isNotEmpty) {
        cachedBookingList = null;
        selectedBookingStatus = data;
        bookings = [];

        page = 1;
        init(status: selectedBookingStatus);

        setState(() {});
      }
    });

    /*LiveStream().on(LIVESTREAM_HANDYMAN_ALL_BOOKING, (index) {
      if (index == 1) {
        selectedBookingStatus = BOOKING_PAYMENT_STATUS_ALL;
        page = 1;
        init(status: selectedBookingStatus);
        setState(() {});
      }
    });*/

    LiveStream().on(LIVESTREAM_UPDATE_BOOKINGS, (p0) {
      appStore.setLoading(true);
      page = 1;
      init();
      setState(() {});
    });

    cachedBookingStatusDropdown.validate().forEach((element) {
      element.isSelected = false;
    });
  }

  void init({String status = ''}) async {
    // Demo Mode: Use demo data instead of backend API
    if (DEMO_MODE_ENABLED) {
      List<BookingData> filteredBookings = demoBookings;

      // Apply booking status filter (from dropdown or filter store)
      if (status.isNotEmpty && status != BOOKING_PAYMENT_STATUS_ALL) {
        filteredBookings =
            filteredBookings.where((b) => b.status == status).toList();
      } else if (filterStore.bookingStatus.isNotEmpty) {
        filteredBookings = filteredBookings
            .where((b) => filterStore.bookingStatus.contains(b.status))
            .toList();
      }

      // Apply payment status filter
      if (filterStore.paymentStatus.isNotEmpty) {
        filteredBookings = filteredBookings
            .where((b) => filterStore.paymentStatus.contains(b.paymentStatus))
            .toList();
      }

      // Apply payment type filter
      if (filterStore.paymentType.isNotEmpty) {
        filteredBookings = filteredBookings
            .where((b) => filterStore.paymentType.contains(b.paymentMethod))
            .toList();
      }

      // Apply service ID filter
      if (filterStore.serviceId.isNotEmpty) {
        filteredBookings = filteredBookings
            .where((b) => filterStore.serviceId.contains(b.serviceId))
            .toList();
      }

      // Apply customer ID filter
      if (filterStore.customerId.isNotEmpty) {
        filteredBookings = filteredBookings
            .where((b) => filterStore.customerId.contains(b.customerId))
            .toList();
      }

      // Apply handyman ID filter
      if (filterStore.handymanId.isNotEmpty) {
        filteredBookings = filteredBookings.where((b) {
          if (b.handyman == null || b.handyman!.isEmpty) return false;
          return b.handyman!
              .any((h) => filterStore.handymanId.contains(h.handymanId));
        }).toList();
      }

      // Apply shop ID filter
      if (filterStore.shopIds.isNotEmpty) {
        filteredBookings = filteredBookings.where((b) {
          if (b.shopInfo == null) return false;
          return filterStore.shopIds.contains(b.shopInfo!.id);
        }).toList();
      }

      // Apply date range filter
      if (filterStore.startDate.isNotEmpty && filterStore.endDate.isNotEmpty) {
        try {
          final startDate = DateTime.parse(filterStore.startDate);
          final endDate = DateTime.parse(filterStore.endDate);
          filteredBookings = filteredBookings.where((b) {
            if (b.date == null) return false;
            try {
              final bookingDate = DateTime.parse(b.date!);
              return bookingDate
                      .isAfter(startDate.subtract(const Duration(days: 1))) &&
                  bookingDate.isBefore(endDate.add(const Duration(days: 1)));
            } catch (e) {
              return true;
            }
          }).toList();
        } catch (e) {
          // Ignore date parsing errors
        }
      }

      // Apply search text filter
      if (searchCont.text.isNotEmpty) {
        final searchText = searchCont.text.toLowerCase();
        filteredBookings = filteredBookings.where((b) {
          return (b.serviceName?.toLowerCase().contains(searchText) ?? false) ||
              (b.customerName?.toLowerCase().contains(searchText) ?? false) ||
              (b.address?.toLowerCase().contains(searchText) ?? false) ||
              (b.id?.toString().contains(searchText) ?? false);
        }).toList();
      }

      // Calculate earnings based on filtered bookings
      double total = 0;
      double providerEarned = 0;
      double handymanEarned = 0;
      double tax = 0;
      double discount = 0;

      for (var b in filteredBookings) {
        if (b.paymentStatus == PAID) {
          total += b.totalAmount ?? 0;
          providerEarned += (b.totalAmount ?? 0) * 0.6;
          handymanEarned += (b.totalAmount ?? 0) * 0.25;
          tax += (b.totalAmount ?? 0) * 0.05;
          discount += b.discount ?? 0;
        }
      }

      bookings = filteredBookings;
      totalEarnings = total.toStringAsFixed(2);
      paymentBreakdownData = PaymentBreakdown(
        adminEarned: (total * 0.15).toStringAsFixed(2),
        handymanEarned: handymanEarned.toStringAsFixed(2),
        providerEarned: providerEarned.toStringAsFixed(2),
        tax: tax.toStringAsFixed(2),
        discount: discount.toStringAsFixed(2),
      );
      isLastPage = true;
      future = Future.value(bookings);
      setState(() {});
      return;
    }

    future = getBookingList(
      page,
      shopId: filterStore.shopIds.join(","),
      serviceId: filterStore.serviceId.join(","),
      dateFrom: filterStore.startDate,
      dateTo: filterStore.endDate,
      customerId: filterStore.customerId.join(","),
      providerId: filterStore.providerId.join(","),
      handymanId: filterStore.handymanId.join(","),
      bookingStatus: filterStore.bookingStatus.join(","),
      paymentStatus: filterStore.paymentStatus.join(","),
      paymentType: filterStore.paymentType.join(","),
      searchText: searchCont.text,
      handymanUserId: appStore.userType == USER_TYPE_HANDYMAN
          ? appStore.userId.toString()
          : '',
      bookings: bookings,
      lastPageCallback: (b) {
        isLastPage = b;
      },
      paymentBreakdownCallBack: (totalEarning, paymentBreakdown) {
        totalEarnings = totalEarning;
        paymentBreakdownData = paymentBreakdown;
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (!mounted) scrollController.dispose();
    filterStore.clearFilters();
    LiveStream().dispose(LIVESTREAM_UPDATE_BOOKINGS);
    // LiveStream().dispose(LIVESTREAM_HANDY_BOARD);
    // LiveStream().dispose(LIVESTREAM_HANDYMAN_ALL_BOOKING);
    // LiveStream().dispose(LIVESTREAM_HANDY_BOARD);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      body: Stack(
        children: [
          SnapHelperWidget<List<BookingData>>(
            initialData: cachedBookingList,
            future: future,
            loadingWidget: const BookingShimmer(),
            onSuccess: (list) {
              return AnimatedScrollView(
                controller: scrollController,
                listAnimationType: ListAnimationType.FadeIn,
                physics: const AlwaysScrollableScrollPhysics(),
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                onSwipeRefresh: () async {
                  page = 1;
                  appStore.setLoading(true);

                  init(status: selectedBookingStatus);
                  setState(() {});

                  return await 1.seconds.delay;
                },
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 24, bottom: 8),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: boxDecorationWithRoundedCorners(
                              borderRadius: radius(),
                              backgroundColor: context.cardSecondary),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(languages.totalAmount,
                                          style: context.boldTextStyle())
                                      .expand(),
                                  GestureDetector(
                                    onTap: () {
                                      TotalAmountsComponent(
                                        totalEarning: totalEarnings,
                                        paymentBreakdown: paymentBreakdownData,
                                      ).launch(context);
                                    },
                                    child: Text(languages.viewBreakdown,
                                        style: context.boldTextStyle(
                                            color: defaultStatus, size: 13)),
                                  ).withHeight(25),
                                ],
                              ),
                              PriceWidget(
                                  price: totalEarnings.toDouble(),
                                  color: context.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedListView(
                    key: keyForList,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    itemCount: list.length,
                    shrinkWrap: true,
                    disposeScrollController: true,
                    physics: const NeverScrollableScrollPhysics(),
                    emptyWidget: SizedBox(
                      width: context.width(),
                      height: context.height() * 0.55,
                      child: NoDataWidget(
                        title: languages.noBookingTitle,
                        subTitle: languages.noBookingSubTitle,
                        imageWidget: const EmptyStateWidget(),
                      ),
                    ),
                    itemBuilder: (_, index) => BookingItemComponent(
                        bookingData: list[index], index: index),
                  ),
                ],
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                retryText: languages.reload,
                imageWidget: const ErrorStateWidget(),
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
