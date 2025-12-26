import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class SlotWidget extends StatelessWidget {
  final bool isAvailable;
  final bool isSelected;
  final String value;
  final double? width;
  final Color? activeColor;
  final Function() onTap;

  SlotWidget({
    required this.isAvailable,
    required this.isSelected,
    required this.value,
    this.width,
    this.activeColor,
    required this.onTap,
  });

  /// Format time for display
  String _formatTimeDisplay(String timeValue) {
    try {
      // Parse the time value (expected format: "HH:00:00")
      List<String> parts = timeValue.split(':');
      if (parts.isEmpty) return timeValue;

      int hour = int.tryParse(parts[0]) ?? 0;

      if (appStore.is24HourFormat) {
        // 24-hour format: "07:00", "13:00", etc.
        return '${hour.toString().padLeft(2, '0')}:00';
      } else {
        // 12-hour format: "7:00 AM", "1:00 PM", etc.
        String period = hour >= 12 ? 'PM' : 'AM';
        int displayHour = hour % 12;
        if (displayHour == 0) displayHour = 12;
        return '$displayHour:00 $period';
      }
    } catch (e) {
      return timeValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? context.primary;

    Color getBackgroundColor() {
      if (isAvailable && isSelected) {
        return effectiveActiveColor;
      } else if (isSelected) {
        return effectiveActiveColor;
      } else {
        return context.profileInputFillColor;
      }
    }

    Color getTextColor() {
      if (isAvailable && isSelected) {
        return context.onPrimary;
      } else if (isSelected) {
        return context.onPrimary;
      } else {
        return context.onSurface;
      }
    }

    Color getBorderColor() {
      if (isSelected) {
        return effectiveActiveColor;
      } else {
        return context.cardSecondaryBorder;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? (context.width() - 32 - 24) / 3,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: boxDecorationDefault(
          color: getBackgroundColor(),
          borderRadius: radius(8),
          border: Border.all(color: getBorderColor()),
        ),
        alignment: Alignment.center,
        child: Observer(
          builder: (context) => Text(
            _formatTimeDisplay(value),
            style: context.primaryTextStyle(
              size: 13,
              color: getTextColor(),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
