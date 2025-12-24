import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/screens/cash_management/model/payment_history_model.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class PaymentHistoryListWidget extends StatelessWidget {
  const PaymentHistoryListWidget(
      {Key? key, required this.data, required this.index, required this.length})
      : super(key: key);

  final PaymentHistoryData data;
  final int index;
  final int length;

  /// Format date manually: "December 24, 2025"
  String _formatDate(DateTime dateTime) {
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

  /// Format time manually: "5:30 PM"
  String _formatTime(DateTime dateTime) {
    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final ampm = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: boxDecorationDefault(
        color: context.cardSecondary,
        border: Border.all(color: context.cardSecondaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (data.datetime != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDate(data.datetime!),
                    style: context.primaryTextStyle(
                        size: 12, color: context.textGrey)),
                Text(_formatTime(data.datetime!),
                    style: context.primaryTextStyle(
                        size: 12, color: context.textGrey)),
              ],
            ),
            8.height,
          ],
          Text(
            data.action.validate().replaceAll('_', ' ').capitalizeFirstLetter(),
            style: context.boldTextStyle(size: 14),
          ),
          4.height,
          Text(
            data.text.validate().replaceAll('_', ' '),
            style: context.primaryTextStyle(size: 12, color: context.textGrey),
          ),
        ],
      ),
    );
  }
}
