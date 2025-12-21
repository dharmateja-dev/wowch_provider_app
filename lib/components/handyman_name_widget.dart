import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/images.dart';

class HandymanNameWidget extends StatelessWidget {
  final String name;
  final bool? isHandymanAvailable;
  final bool showVerifiedBadge;

  final int size;
  final MainAxisAlignment mainAxisAlignment;

  HandymanNameWidget({
    required this.name,
    this.isHandymanAvailable,
    this.size = 16,
    this.showVerifiedBadge = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isHandymanAvailable != null)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isHandymanAvailable!
                      ? context.primaryLiteColor
                      : context.error,
                  shape: BoxShape.circle,
                ),
              ),
              8.width,
            ],
          ),
        Marquee(
                child: Text(name,
                    style: context.boldTextStyle(size: size), maxLines: 1))
            .flexible(),
        if (showVerifiedBadge) ...[
          4.width,
          ImageIcon(
            AssetImage(ic_verified),
            size: 14,
            color: context.primary,
          )
        ],
      ],
    );
  }
}
