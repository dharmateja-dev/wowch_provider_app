import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/dashboard_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class CommissionComponent extends StatelessWidget {
  final Commission commission;

  CommissionComponent({required this.commission});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(8),
        backgroundColor: context.cardSecondary,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichTextWidget(
                  textAlign: TextAlign.start,
                  list: [
                    TextSpan(
                        text: '${languages.lblProviderType}: ',
                        style: secondaryTextStyle()),
                    TextSpan(
                      text: commission.name.validate().capitalizeFirstLetter(),
                      style: boldTextStyle(),
                    ),
                  ],
                ),
                12.height,
                RichTextWidget(
                  textAlign: TextAlign.start,
                  list: [
                    TextSpan(
                        text: '${languages.lblMyCommission}: ',
                        style: secondaryTextStyle()),
                    TextSpan(
                      text: isCommissionTypePercent(commission.type)
                          ? '${commission.commission.validate()}%'
                          : commission.commission.validate().toPriceFormat(),
                      style: boldTextStyle(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primary,
            ),
            child: Image.asset(
              percent_line,
              height: 20,
              width: 20,
              color: context.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
