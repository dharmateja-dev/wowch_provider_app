import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/price_widget.dart';
import '../../../utils/constant.dart';
import '../model/earning_list_model.dart';

class EarningDetailBottomSheet extends StatelessWidget {
  final EarningListModel earningModel;

  const EarningDetailBottomSheet(this.earningModel);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: boxDecorationDefault(
          borderRadius: radiusOnly(topLeft: 16, topRight: 16),
          color: context.bottomSheetBackgroundColor,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              height: 5,
              width: 40,
              decoration: boxDecorationDefault(
                borderRadius: radius(60),
                color: context.iconMuted,
              ),
            ),
            16.height,

            // Content Card
            Container(
              width: context.width(),
              decoration: boxDecorationDefault(
                color: context.cardSecondary,
                borderRadius: radius(12),
                border: Border.all(color: context.cardSecondaryBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    languages.earningDetails,
                    style: context.boldTextStyle(size: 16),
                  ).paddingAll(16),

                  Divider(
                    color: context.cardSecondaryBorder,
                    height: 1,
                    thickness: 1,
                  ),

                  // Admin Earning
                  if (earningModel.adminEarning != null)
                    _buildDetailRow(
                      context: context,
                      label: languages.adminEarning,
                      priceValue: earningModel.adminEarning.validate(),
                      isPrice: true,
                    ),

                  // Handyman Name
                  if (earningModel.handymanName != null)
                    _buildDetailRow(
                      context: context,
                      label: languages.handymanName,
                      value: earningModel.handymanName.validate(),
                      isPrice: false,
                    ),

                  // Commission
                  if (earningModel.commission != null)
                    _buildDetailRow(
                      context: context,
                      label: languages.commission,
                      value: _getCommissionText(),
                      isPrice: false,
                    ),

                  // Total Bookings
                  if (earningModel.totalBookings != null)
                    _buildDetailRow(
                      context: context,
                      label: languages.lblTotalBooking,
                      value: earningModel.totalBookings.validate().toString(),
                      isPrice: false,
                    ),

                  // Total Earning
                  if (earningModel.totalEarning != null)
                    _buildDetailRow(
                      context: context,
                      label: languages.totalEarning,
                      priceValue: earningModel.totalEarning.validate(),
                      isPrice: true,
                    ),

                  // Taxes
                  if (earningModel.taxes != null)
                    _buildDetailRow(
                      context: context,
                      label: languages.lblTaxes,
                      priceValue: earningModel.taxes.validate(),
                      isPrice: true,
                    ),

                  16.height,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCommissionText() {
    if (earningModel.commissionType.validate().toLowerCase() ==
            COMMISSION_TYPE_PERCENTAGE.toLowerCase() ||
        earningModel.commissionType.validate().toLowerCase() ==
            TAX_TYPE_PERCENT.toLowerCase()) {
      return '${earningModel.commission}%';
    } else if (earningModel.commissionType.validate().toLowerCase() ==
        COMMISSION_TYPE_FIXED.toLowerCase()) {
      return earningModel.commission.validate().toPriceFormat();
    }
    return '${earningModel.commission}';
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required String label,
    String? value,
    num? priceValue,
    required bool isPrice,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: context.cardSecondaryBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: context.primaryTextStyle(size: 13),
          ).expand(),
          8.width,
          if (isPrice)
            PriceWidget(
              price: priceValue ?? 0,
              color: context.primary,
              isBoldText: true,
              size: 14,
            )
          else
            Text(
              value ?? '',
              style: context.boldTextStyle(size: 13),
              textAlign: TextAlign.right,
            ),
        ],
      ),
    );
  }
}
