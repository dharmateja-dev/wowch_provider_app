import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/total_earning_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalEarningWidget extends StatelessWidget {
  const TotalEarningWidget({Key? key, required this.totalEarning})
      : super(key: key);

  final TotalData totalEarning;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      width: context.width(),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(),
        backgroundColor: context.cardSecondary,
        border: Border.all(color: context.cardSecondaryBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(languages.paymentMethod, style: context.boldTextStyle()),
              Text(
                totalEarning.paymentMethod.validate().capitalizeFirstLetter(),
                style: context.boldTextStyle(color: context.primary),
              ),
            ],
          ),
          if (totalEarning.description.validate().isNotEmpty)
            Column(
              children: [
                16.height,
                Text(totalEarning.description.validate(),
                    style: context.primaryTextStyle()),
              ],
            ),
          16.height,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.selectServiceContainerColor,
              borderRadius: radius(),
              border: Border.all(color: context.cardSecondaryBorder),
            ),
            width: context.width(),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(languages.lblAmount,
                        style: context.primaryTextStyle(size: 14)),
                    16.width,
                    PriceWidget(
                            price: totalEarning.amount.validate(),
                            color: context.primary,
                            size: 14)
                        .flexible(),
                  ],
                ),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(languages.lblDate,
                        style: context.primaryTextStyle(size: 14)),
                    Builder(
                      builder: (context) {
                        final dateStr =
                            totalEarning.createdAt.validate().toString();
                        try {
                          final dateTime = DateTime.tryParse(dateStr);
                          if (dateTime != null) {
                            const months = [
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
                            return Text(
                              '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}',
                              style: context.boldTextStyle(size: 14),
                            );
                          }
                        } catch (e) {
                          // Fallback to original format
                        }
                        return Text(
                          formatDate(dateStr, format: DATE_FORMAT_9),
                          style: context.boldTextStyle(size: 14),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
