import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/dashed_rect.dart';
import 'package:handyman_provider_flutter/utils/extensions/color_extension.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingHistoryListWidget extends StatelessWidget {
  const BookingHistoryListWidget(
      {Key? key, required this.data, required this.index, required this.length})
      : super(key: key);

  final BookingActivity data;
  final int index;
  final int length;

  String _formatDateManually(String dateStr) {
    try {
      final dateTime = DateTime.tryParse(dateStr);
      if (dateTime != null) {
        const months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
      }
    } catch (e) {
      // Fallback
    }
    return formatDate(dateStr);
  }

  String _formatTimeManually(String dateStr) {
    try {
      final dateTime = DateTime.tryParse(dateStr);
      if (dateTime != null) {
        int hour = dateTime.hour;
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final ampm = hour >= 12 ? 'PM' : 'AM';
        hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$hour:$minute $ampm';
      }
    } catch (e) {
      // Fallback
    }
    return formatDate(dateStr, isTime: true);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = data.datetime.toString().validate();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                color:
                    data.activityType.validate().getBookingActivityStatusColor,
                borderRadius: radius(8),
              ),
            ),
            SizedBox(
              height: 70,
              child: DashedRect(
                gap: 3,
                color:
                    data.activityType.validate().getBookingActivityStatusColor,
                strokeWidth: 1.5,
              ),
            ).visible(index != length - 1),
          ],
        ).paddingOnly(top: 4),
        16.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              data.activityType
                  .validate()
                  .replaceAll('_', ' ')
                  .capitalizeFirstLetter(),
              style: context.boldTextStyle(size: 14),
            ).paddingOnly(left: 4, bottom: 4),
            Text(
              data.activityMessage.validate().replaceAll('_', ' '),
              style: context.primaryTextStyle(size: 12),
            ).paddingOnly(left: 4),
          ],
        ).paddingOnly(bottom: 18).expand(flex: 3),
        if (dateStr.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDateManually(dateStr),
                style: context.primaryTextStyle(size: 10),
              ),
              Text(
                _formatTimeManually(dateStr),
                style: context.primaryTextStyle(size: 10),
              )
            ],
          )
      ],
    );
  }
}
