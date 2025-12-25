import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';
import '../../components/selected_item_widget.dart';
import '../../main.dart';
import '../../models/booking_status_response.dart';
import '../../utils/constant.dart';
import '../../utils/demo_mode.dart';

/// Demo booking statuses for testing
List<BookingStatusResponse> get demoBookingStatuses => [
      BookingStatusResponse(
          id: 1, value: BOOKING_STATUS_PENDING, label: 'Pending'),
      BookingStatusResponse(
          id: 2, value: BOOKING_STATUS_ACCEPT, label: 'Accepted'),
      BookingStatusResponse(
          id: 3, value: BOOKING_STATUS_ON_GOING, label: 'On Going'),
      BookingStatusResponse(
          id: 4, value: BOOKING_STATUS_IN_PROGRESS, label: 'In Progress'),
      BookingStatusResponse(id: 5, value: BOOKING_STATUS_HOLD, label: 'Hold'),
      BookingStatusResponse(
          id: 6, value: BOOKING_STATUS_COMPLETED, label: 'Completed'),
      BookingStatusResponse(
          id: 7, value: BOOKING_STATUS_CANCELLED, label: 'Cancelled'),
      BookingStatusResponse(
          id: 8, value: BOOKING_STATUS_REJECTED, label: 'Rejected'),
      BookingStatusResponse(
          id: 9, value: BOOKING_STATUS_FAILED, label: 'Failed'),
    ];

class FilterBookingStatusComponent extends StatefulWidget {
  final List<BookingStatusResponse> bookingStatusList;

  FilterBookingStatusComponent({required this.bookingStatusList});

  @override
  _FilterBookingStatusComponent createState() =>
      _FilterBookingStatusComponent();
}

class _FilterBookingStatusComponent
    extends State<FilterBookingStatusComponent> {
  late List<BookingStatusResponse> statusList;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // Use demo data when demo mode is enabled
    if (DEMO_MODE_ENABLED) {
      statusList = List<BookingStatusResponse>.from(demoBookingStatuses);
    } else {
      statusList = widget.bookingStatusList;
    }

    // Restore selection state from filterStore
    for (var status in statusList) {
      status.isSelected = filterStore.bookingStatus.contains(status.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (statusList.isEmpty) {
      return NoDataWidget(
        title: languages.noServiceFound,
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
          itemCount: statusList.length,
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          itemBuilder: (context, index) {
            BookingStatusResponse res = statusList[index];

            return Container(
              width: context.width(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: context.secondaryContainer,
                border: Border.all(
                    color:
                        res.isSelected ? context.primary : Colors.transparent,
                    width: 1),
                borderRadius: radius(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      res.value.validate().toBookingStatus(),
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
                    filterStore.addToBookingStatusList(
                      bookingStatusList: res.value.validate(),
                    );
                  } else {
                    filterStore.removeFromBookingStatusList(
                      bookingStatusList: res.value.validate(),
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
