import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/screens/cash_management/model/cash_filter_model.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class StatusWidget extends StatelessWidget {
  final CashFilterModel data;
  final bool isSelected;

  StatusWidget({Key? key, required this.data, required this.isSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4, left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(
          border: Border.all(color: context.dividerColor),
          color: isSelected ? context.primary : context.cardColor),
      child: Text(data.name.validate(),
          style: context.primaryTextStyle(
              color: isSelected ? context.onPrimary : context.primary)),
    );
  }
}
