import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/handyman_dashboard_response.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanCommissionComponent extends StatelessWidget {
  final Commission commission;

  HandymanCommissionComponent({required this.commission});

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
                        text: '${languages.lblHandymanType}: ',
                        style: context.primaryTextStyle()),
                    TextSpan(
                      text: commission.name.validate().capitalizeFirstLetter(),
                      style: context.boldTextStyle(),
                    ),
                  ],
                ),
                12.height,
                RichTextWidget(
                  textAlign: TextAlign.start,
                  list: [
                    TextSpan(
                        text: '${languages.lblMyCommission}: ',
                        style: context.primaryTextStyle()),
                    TextSpan(
                      text: isCommissionTypePercent(commission.type)
                          ? '${commission.commission.validate()}%'
                          : commission.commission.validate().toPriceFormat(),
                      style: context.boldTextStyle(),
                    ),
                    if (!isCommissionTypePercent(commission.type))
                      TextSpan(
                        text: ' (${languages.lblFixed})',
                        style: context.primaryTextStyle(),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: context.primary),
            child: Image.asset(percent_line,
                height: 24, width: 24, color: context.onPrimary),
          ),
        ],
      ),
    );
  }
}
