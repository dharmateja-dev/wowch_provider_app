import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/screens/extra_charges/components/add_extra_charge_dialog.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';
import '../../models/extra_charges_model.dart';

import '../../utils/images.dart';
import '../../utils/text_styles.dart';

class AddExtraChargesScreen extends StatefulWidget {
  final bool isFromEditExtraCharge;

  AddExtraChargesScreen({this.isFromEditExtraCharge = false});

  @override
  _AddExtraChargesScreenState createState() => _AddExtraChargesScreenState();
}

class _AddExtraChargesScreenState extends State<AddExtraChargesScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (!widget.isFromEditExtraCharge) {
      afterBuildCreated(() async {
        openDialog();
      });
    }
  }

  void openDialog({ExtraChargesModel? data, int? indexOfextraCharge}) async {
    bool? res = await showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      barrierDismissible: false,
      builder: (_) {
        return AddExtraChargesDialog(
            data: data, indexOfextraCharge: indexOfextraCharge);
      },
    );

    if (res ?? false) {
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        languages.lblAddExtraCharges,
        backWidget: BackWidget(),
        showBack: true,
        textColor: context.onPrimary,
        color: context.primary,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: context.onPrimary),
            onPressed: () async {
              openDialog();
            },
          )
        ],
      ),
      body: Stack(
        children: [
          if (chargesList.isEmpty)
            NoDataWidget(
              title: languages.noExtraChargesHere,
              imageWidget: EmptyStateWidget(),
            ),
          AnimatedListView(
            itemCount: chargesList.length,
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            shrinkWrap: true,
            padding: EdgeInsets.all(8),
            itemBuilder: (_, i) {
              ExtraChargesModel data = chargesList[i];

              return Container(
                decoration: boxDecorationRoundedWithShadow(16,
                    backgroundColor: context.cardSecondary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    4.height,
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            style: ButtonStyle(
                                padding:
                                    WidgetStatePropertyAll(EdgeInsets.zero)),
                            icon: ic_edit_square.iconImage(
                                context: context, size: 18),
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              openDialog(data: data, indexOfextraCharge: i);
                            },
                          ),
                          IconButton(
                            style: ButtonStyle(
                                padding:
                                    WidgetStatePropertyAll(EdgeInsets.zero)),
                            icon: ic_delete.iconImage(
                                context: context,
                                size: 18,
                                color: Colors.redAccent),
                            visualDensity: VisualDensity.compact,
                            onPressed: () async {
                              showConfirmDialogCustom(
                                context,
                                height: 80,
                                width: 290,
                                shape: appDialogShape(8),
                                title: languages.confirmationRequestTxt,
                                titleColor: context.dialogTitleColor,
                                backgroundColor: context.dialogBackgroundColor,
                                primaryColor: context.error,
                                customCenterWidget: Image.asset(
                                  ic_warning,
                                  color: context.dialogIconColor,
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                                positiveText: languages.lblYes,
                                positiveTextColor: context.onPrimary,
                                negativeText: languages.lblNo,
                                negativeTextColor: context.dialogCancelColor,
                                dialogType: DialogType.DELETE,
                                onAccept: (BuildContext context) {
                                  chargesList.removeAt(i);
                                  setState(() {});
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(languages.lblChargeName,
                                style: context.primaryTextStyle(
                                    size: 14, color: context.textGrey)),
                            Text(data.title.validate(),
                                style: context.boldTextStyle()),
                          ],
                        ),
                        8.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(languages.lblPrice,
                                style: context.primaryTextStyle(
                                    size: 14, color: context.textGrey)),
                            PriceWidget(
                                price: data.price.validate(),
                                size: 14,
                                color: context.onSurface,
                                isBoldText: true),
                          ],
                        ),
                        8.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(languages.quantity,
                                style: context.primaryTextStyle(
                                    size: 14, color: context.textGrey)),
                            Text(data.qty.toString().validate(),
                                style: context.boldTextStyle()),
                          ],
                        ),
                        8.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(languages.lblTotalCharges,
                                style: context.primaryTextStyle(
                                    size: 14, color: context.textGrey)),
                            PriceWidget(
                                price:
                                    '${data.price.validate() * data.qty.validate()}'
                                        .toDouble(),
                                size: 16,
                                color: context.primary,
                                isBoldText: true),
                          ],
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 12),
                    14.height,
                  ],
                ),
              ).paddingBottom(16);
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: AppButton(
          text: languages.btnSave,
          color: context.primary,
          onTap: () {
            showConfirmDialogCustom(
              context,
              height: 80,
              width: 290,
              shape: appDialogShape(8),
              title: languages.thisOrderWillBe,
              titleColor: context.dialogTitleColor,
              backgroundColor: context.dialogBackgroundColor,
              primaryColor: context.primary,
              customCenterWidget: Image.asset(
                ic_warning,
                color: context.dialogIconColor,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
              positiveText: languages.lblYes,
              positiveTextColor: context.onPrimary,
              negativeText: languages.lblNo,
              negativeTextColor: context.dialogCancelColor,
              dialogType: DialogType.CONFIRMATION,
              onAccept: (BuildContext context) {
                // if (chargesList.isNotEmpty) {
                if (chargesList.isEmpty) {
                  chargesList.clear(); // Clear it globally
                }
                toast(languages.lblSuccessFullyAddExtraCharges);
                finish(context, true);
                // }
              },
            );
          },
        ),
      ),
    );
  }
}
