import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class DisclaimerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: context.cardSecondary,
        borderRadius: radius(12),
        border: Border.all(color: context.cardSecondaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            languages.notes,
            style: context.boldTextStyle(size: 14),
          ),
          12.height,
          UL(
            spacing: 12,
            symbolColor: context.iconMuted,
            symbolType: SymbolType.Numbered,
            children: [
              Text(
                languages.timeSlotsNotes1,
                style: context.secondaryTextStyle(size: 13),
              ),
              Text(
                languages.timeSlotsNotes2,
                style: context.secondaryTextStyle(size: 13),
              ),
              Text(
                languages.timeSlotsNotes3,
                style: context.secondaryTextStyle(size: 13),
              ),
            ],
          )
        ],
      ),
    );
  }
}
