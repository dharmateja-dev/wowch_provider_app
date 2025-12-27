import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceFaqWidget extends StatelessWidget {
  final ServiceFaq? serviceFaq;

  const ServiceFaqWidget({Key? key, required this.serviceFaq})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: context.cardSecondary,
          borderRadius: radius(8),
          border: Border.all(color: context.cardSecondaryBorder),
        ),
        child: Theme(
            data: Theme.of(context)
                .copyWith(dividerColor: context.cardSecondaryBorder),
            child: ExpansionTile(
              title: Text(serviceFaq!.title.validate(),
                  style: context.boldTextStyle()),
              tilePadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              iconColor: context.icon,
              collapsedIconColor: context.icon,
              textColor: context.onSurface,
              collapsedTextColor: context.onSurface,
              backgroundColor: context.cardSecondary,
              collapsedBackgroundColor: context.cardSecondary,
              childrenPadding: const EdgeInsets.only(bottom: 8),
              children: [
                ListTile(
                  title: Text(serviceFaq!.description.validate(),
                      style: context.primaryTextStyle()),
                  contentPadding: const EdgeInsets.only(left: 32, right: 16),
                ),
              ],
            ))).paddingOnly(left: 16, right: 16);
  }
}
