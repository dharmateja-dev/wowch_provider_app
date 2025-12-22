import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalWidget extends StatelessWidget {
  final String title;
  final String total;
  final String icon;
  final Color? color;

  const TotalWidget(
      {required this.title,
      required this.total,
      required this.icon,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: boxDecorationDefault(color: context.primary),
      width: context.width() / 2 - 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: context.width() / 2 - 94,
                child: Marquee(
                  child: Marquee(
                      child: Text(total.validate(),
                          style: context.boldTextStyle(
                              color: context.onPrimary, size: 16),
                          maxLines: 1)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: context.onPrimary),
                child: Image.asset(icon,
                    width: 18, height: 18, color: context.primary),
              ),
            ],
          ),
          8.height,
          Marquee(
              child: Text(title,
                  style: context.primaryTextStyle(
                      size: 14, color: context.onPrimary))),
        ],
      ),
    );
  }
}
