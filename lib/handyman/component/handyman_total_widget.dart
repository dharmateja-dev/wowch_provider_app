import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanTotalWidget extends StatelessWidget {
  final String title;
  final String total;
  final String icon;
  final Color? color;

  HandymanTotalWidget(
      {required this.title,
      required this.total,
      required this.icon,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: boxDecorationDefault(color: context.primary),
      //decoration: cardDecoration(context, showBorder: true,color: context.primaryColor),
      width: context.width() / 2 - 24,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(total.validate(),
                      style: context.boldTextStyle(
                          color: context.onPrimary, size: 16)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: context.onPrimary),
                    child: Image.asset(icon,
                        width: 20, height: 20, color: context.primary),
                  ),
                ],
              ),
              8.height,
              Marquee(
                child: Text(title.validate(),
                    style: context.primaryTextStyle(color: context.onPrimary)),
              ),
            ],
          ).expand(),
        ],
      ),
    );
  }
}
