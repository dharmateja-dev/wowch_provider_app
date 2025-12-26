import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/app_configuration.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class PriceWidget extends StatelessWidget {
  final num price;
  final double? size;
  final Color? color;
  final Color? hourlyTextColor;
  final String? currency;
  final bool isBoldText;
  final bool isLineThroughEnabled;
  final bool isDiscountedPrice;
  final bool isHourlyService;
  final bool isFreeService;
  final int? decimalPoint;

  /// Indian Rupee symbol
  static const String indianRupee = '₹';

  PriceWidget({
    required this.price,
    this.size = 16.0,
    this.color,
    this.hourlyTextColor,
    this.currency,
    this.isLineThroughEnabled = false,
    this.isBoldText = true,
    this.isDiscountedPrice = false,
    this.isHourlyService = false,
    this.isFreeService = false,
    this.decimalPoint,
  });

  /// Get currency symbol based on language
  /// Returns Indian Rupee (₹) for English and Hindi languages
  String _getCurrencySymbol() {
    // If custom currency is provided, use it
    if (currency != null && currency!.isNotEmpty) {
      return currency!;
    }

    // Get current language code
    final String languageCode = appStore.selectedLanguageCode;

    // Return Indian Rupee for English and Hindi
    if (languageCode == 'en' || languageCode == 'hi') {
      return indianRupee;
    }

    // Fallback to app configuration currency for other languages
    return appConfigurationStore.currencySymbol;
  }

  /// Format price with currency symbol
  String _formatPrice() {
    final String currencySymbol = _getCurrencySymbol();
    final int decimals =
        decimalPoint ?? appConfigurationStore.priceDecimalPoint;
    final String formattedPrice =
        price.validate().toStringAsFixed(decimals).formatNumberWithComma();

    // Currency position based on app config
    if (isCurrencyPositionLeft) {
      return '$currencySymbol$formattedPrice';
    } else {
      return '$formattedPrice$currencySymbol';
    }
  }

  @override
  Widget build(BuildContext context) {
    TextDecoration? textDecoration() =>
        isLineThroughEnabled ? TextDecoration.lineThrough : null;

    TextStyle _textStyle({int? aSize}) {
      return isBoldText
          ? context.boldTextStyle(
              size: aSize ?? size!.toInt(),
              color: color ?? context.primary,
              decoration: textDecoration(),
            )
          : context.secondaryTextStyle(
              size: aSize ?? size!.toInt(),
              color: color ?? context.primary,
              decoration: textDecoration(),
            );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isDiscountedPrice ? ' -' : '',
          style: _textStyle(),
        ),
        Row(
          children: [
            if (isFreeService)
              Text(languages.lblFree, style: _textStyle())
            else
              Text(
                _formatPrice(),
                style: _textStyle(),
              ),
            if (isHourlyService)
              Text('/${languages.lblHr}',
                  style: context.secondaryTextStyle(color: hourlyTextColor, size: 14)),
          ],
        ),
      ],
    );
  }
}
