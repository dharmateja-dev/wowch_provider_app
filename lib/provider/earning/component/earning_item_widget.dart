import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/price_widget.dart';
import '../../../main.dart';
import '../../../utils/images.dart';
import '../add_handyman_payout_screen.dart';
import '../model/earning_list_model.dart';
import 'earning_detail_bottomsheet.dart';

class EarningItemWidget extends StatelessWidget {
  final EarningListModel earningModel;
  final VoidCallback? onUpdate;

  const EarningItemWidget(this.earningModel, {this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: context.width(),
      decoration: boxDecorationDefault(
        color: context.cardSecondary,
        borderRadius: radius(12),
        border: Border.all(color: context.cardSecondaryBorder),
      ),
      child: Column(
        children: [
          // Header - Profile Info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.primary.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: CachedImageWidget(
                      url: earningModel.handymanImage.validate(),
                      height: 50,
                      width: 50,
                      circle: true,
                      fit: BoxFit.cover,
                    ),
                  ),
                  16.width,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        earningModel.handymanName.validate(),
                        style: context.boldTextStyle(size: 14),
                        textAlign: TextAlign.left,
                      ),
                      4.height,
                      Text(
                        earningModel.email.validate(),
                        style: context.primaryTextStyle(size: 12),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ).expand(),
                ],
              ).expand(),
              IconButton(
                icon: Icon(
                  Icons.info_outline_rounded,
                  size: 22,
                  color: context.iconMuted,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (_) {
                      return EarningDetailBottomSheet(earningModel);
                    },
                  );
                },
              ),
            ],
          ),

          Divider(color: context.divider, thickness: 0.45, height: 24),

          // Total Bookings & Total Earning Row
          Row(
            children: [
              _buildStatItem(
                context: context,
                icon: total_booking,
                label: languages.lblTotalBooking,
                value: earningModel.totalBookings.validate().toString(),
                isPrice: false,
              ).expand(),
              16.width,
              _buildStatItem(
                context: context,
                icon: ic_un_fill_wallet,
                label: languages.totalEarning,
                priceValue: earningModel.totalEarning.validate(),
                isPrice: true,
              ).expand(),
            ],
          ),

          Divider(
              color: context.cardSecondaryBorder, thickness: 1.0, height: 24),

          // My Earning Row
          _buildStatItem(
            context: context,
            icon: ic_un_fill_wallet,
            label: languages.myEarning,
            priceValue: earningModel.providerTotalAmount.validate(),
            isPrice: true,
          ),

          Divider(
              color: context.cardSecondaryBorder, thickness: 1.0, height: 24),

          // Due Amount Row
          _buildStatItem(
            context: context,
            icon: ic_un_fill_wallet,
            label: languages.handymanPayDue,
            priceValue: earningModel.handymanDueAmount.validate(),
            isPrice: true,
            valueColor: earningModel.handymanDueAmount.validate() > 0
                ? context.error
                : context.primary,
          ),

          Divider(
              color: context.cardSecondaryBorder, thickness: 1.0, height: 24),

          // Paid Amount Row
          _buildStatItem(
            context: context,
            icon: ic_un_fill_wallet,
            label: languages.handymanPaidAmount,
            priceValue: earningModel.handymanPaidEarning.validate(),
            isPrice: true,
            valueColor: context.primary,
          ),

          // Payout Button
          if (earningModel.handymanDueAmount.validate() > 0)
            AppButton(
              text: languages.payout,
              color: context.primary,
              textColor: context.onPrimary,
              textStyle: context.boldTextStyle(color: context.onPrimary),
              shapeBorder: RoundedRectangleBorder(borderRadius: radius(8)),
              width: context.width(),
              margin: const EdgeInsets.only(top: 16),
              padding: EdgeInsets.zero,
              onTap: () async {
                bool? res =
                    await AddHandymanPayoutScreen(earningModel: earningModel)
                        .launch(context);

                if (res ?? false) {
                  onUpdate?.call();
                }
              },
            ),
        ],
      ),
    ).onTap(
      () {
        showModalBottomSheet(
          backgroundColor: context.bottomSheetBackgroundColor,
          context: context,
          builder: (_) {
            return EarningDetailBottomSheet(earningModel);
          },
        );
      },
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required String icon,
    required String label,
    String? value,
    num? priceValue,
    required bool isPrice,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Image.asset(
          icon,
          height: 18,
          color: context.primary,
        ),
        12.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: context.primaryTextStyle(size: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            4.height,
            if (isPrice)
              PriceWidget(
                price: priceValue ?? 0,
                color: valueColor ?? context.primary,
                isBoldText: true,
                size: 14,
              )
            else
              Text(
                value ?? '',
                style: context.boldTextStyle(
                  size: 14,
                  color: valueColor ?? context.primary,
                ),
              ),
          ],
        ).expand(),
      ],
    );
  }
}
