import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/gallery_component.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/services/add_services.dart';
import 'package:handyman_provider_flutter/screens/gallery_List_Screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceDetailHeaderComponent extends StatefulWidget {
  final ServiceDetailResponse serviceDetail;
  final VoidCallback? voidCallback;

  const ServiceDetailHeaderComponent(
      {required this.serviceDetail, this.voidCallback, Key? key})
      : super(key: key);

  @override
  State<ServiceDetailHeaderComponent> createState() =>
      _ServiceDetailHeaderComponentState();
}

class _ServiceDetailHeaderComponentState
    extends State<ServiceDetailHeaderComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
  }

  void removeService() {
    deleteService(widget.serviceDetail.serviceDetail!.id.validate())
        .then((value) {
      appStore.setLoading(true);
      finish(context, true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> confirmationDialog(BuildContext context) async {
    showConfirmDialogCustom(
      context,
      title: languages.confirmationRequestTxt,
      shape: appDialogShape(8),
      titleColor: context.dialogTitleColor,
      backgroundColor: context.dialogBackgroundColor,
      primaryColor: context.primary,
      positiveText: languages.lblYes,
      positiveTextColor: context.onPrimary,
      negativeText: languages.lblNo,
      negativeTextColor: context.dialogCancelColor,
      dialogType: DialogType.CONFIRMATION,
      onAccept: (context) async {
        ifNotTester(context, () {
          appStore.setLoading(true);
          removeService();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 475,
      width: context.width(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.serviceDetail.serviceDetail!.attchments
              .validate()
              .isNotEmpty)
            SizedBox(
              height: 400,
              width: context.width(),
              child: CachedImageWidget(
                url: widget.serviceDetail.serviceDetail!.attchments!.first.url
                    .validate(),
                fit: BoxFit.cover,
                height: 400,
              ),
            ),
          Positioned(
            top: context.statusBarHeight + 8,
            left: 8,
            child: Container(
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.cardColor.withValues(alpha: 0.7)),
              child: BackWidget(color: context.icon).paddingLeft(8),
            ),
          ),
          Positioned(
            top: context.statusBarHeight + 8,
            right: 16,
            child: isUserTypeProvider &&
                    (rolesAndPermissionStore.serviceEdit ||
                        rolesAndPermissionStore.serviceDelete)
                ? Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.cardColor.withValues(alpha: 0.7)),
                    child: PopupMenuButton(
                      icon:
                          Icon(Icons.more_horiz, size: 24, color: context.icon),
                      padding: const EdgeInsets.all(8),
                      onSelected: (selection) {
                        if (selection == 1) {
                          AddServices(data: widget.serviceDetail)
                              .launch(context)
                              .then((value) {
                            if (value ?? false) {
                              init();
                              widget.voidCallback?.call();
                            }
                          });
                        } else if (selection == 2) {
                          confirmationDialog(context);
                        }
                      },
                      color: context.cardColor,
                      itemBuilder: (context) => [
                        if (rolesAndPermissionStore.serviceEdit)
                          PopupMenuItem(
                              value: 1,
                              child: Text(languages.lblEdit,
                                  style: boldTextStyle())),
                        if (rolesAndPermissionStore.serviceDelete)
                          PopupMenuItem(
                              value: 2,
                              child: Text(languages.lblDelete,
                                  style: boldTextStyle())),
                      ],
                    ),
                  )
                : const Offstage(),
          ),
          Positioned(
            bottom: 0,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  children: [
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: List.generate(
                        widget.serviceDetail.serviceDetail!.attchments!
                            .take(2)
                            .length,
                        (i) => Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: context.mainBorderColor, width: 2),
                              borderRadius: radius()),
                          child: GalleryComponent(
                            images: widget
                                .serviceDetail.serviceDetail!.attchments
                                .validate()
                                .map((e) => e.url.validate())
                                .toList(),
                            index: i,
                            padding: 32,
                            height: 60,
                            width: 60,
                          ),
                        ),
                      ),
                    ),
                    16.width,
                    if (widget.serviceDetail.serviceDetail!.attchments!.length >
                        2)
                      Blur(
                        borderRadius: radius(),
                        padding: EdgeInsets.zero,
                        child: Container(
                          height: 60,
                          width: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: context.mainBorderColor, width: 2),
                              borderRadius: radius()),
                          child: Text(
                              '+'
                              '${widget.serviceDetail.serviceDetail!.attchments!.length - 2}',
                              style: context.boldTextStyle(
                                  color: context.onPrimary)),
                        ),
                      ).onTap(
                        () {
                          GalleryListScreen(
                            galleryImages: widget
                                .serviceDetail.serviceDetail!.attchments
                                .validate()
                                .map((e) => e.url.validate())
                                .toList(),
                            serviceName: widget
                                .serviceDetail.serviceDetail!.name
                                .validate(),
                          )
                              .launch(context,
                                  pageRouteAnimation: PageRouteAnimation.Fade,
                                  duration: 400.milliseconds)
                              .then((value) {
                            setStatusBarColor(transparentColor,
                                delayInMilliSeconds: 1000);
                          });
                        },
                      ),
                  ],
                ),
                16.height,
                Container(
                  width: context.width(),
                  padding: const EdgeInsets.all(16),
                  decoration: boxDecorationDefault(
                    color: context.cardSecondary,
                    border: Border.all(color: context.cardSecondaryBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.serviceDetail.serviceDetail!.subCategoryName
                          .validate()
                          .isNotEmpty)
                        Marquee(
                          child: Row(
                            children: [
                              Text(
                                  '${widget.serviceDetail.serviceDetail!.categoryName}',
                                  style: context.boldTextStyle(size: 12)),
                              Text('  >  ',
                                  style: context.boldTextStyle(size: 14)),
                              Text(
                                  widget.serviceDetail.serviceDetail!
                                      .subCategoryName
                                      .capitalizeFirstLetter(),
                                  style: context.boldTextStyle(
                                      color: context.primary, size: 12)),
                            ],
                          ),
                        )
                      else
                        Text(
                            '${widget.serviceDetail.serviceDetail!.categoryName}',
                            style:
                                context.boldTextStyle(color: context.primary)),
                      8.height,
                      Marquee(
                        directionMarguee: DirectionMarguee.oneDirection,
                        child: Text(
                            widget.serviceDetail.serviceDetail!.name.validate(),
                            style: context.boldTextStyle(size: 18)),
                      ),
                      8.height,
                      Row(
                        children: [
                          PriceWidget(
                            price: widget.serviceDetail.serviceDetail!.price
                                .validate(),
                            isHourlyService: widget
                                .serviceDetail.serviceDetail!.isHourlyService,
                            size: 16,
                            hourlyTextColor: textSecondaryColorGlobal,
                            isFreeService: widget
                                .serviceDetail.serviceDetail!.isFreeService,
                          ),
                          4.width,
                          if (widget.serviceDetail.serviceDetail!.discount
                                  .validate() !=
                              0)
                            Text(
                              '(${widget.serviceDetail.serviceDetail!.discount.validate()}% ${languages.lblOff})',
                              style: context.boldTextStyle(color: Colors.green),
                            ),
                        ],
                      ),
                      4.height,
                      TextIcon(
                        edgeInsets: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 8),
                        text: languages.hintDuration,
                        textStyle: context.primaryTextStyle(size: 14),
                        expandedText: true,
                        suffix: Text(
                          convertToHourMinute(widget
                              .serviceDetail.serviceDetail!.duration
                              .validate()),
                          style: context.boldTextStyle(color: context.primary),
                        ),
                      ),
                      TextIcon(
                        text: languages.lblRating,
                        textStyle: context.primaryTextStyle(size: 14),
                        edgeInsets: const EdgeInsets.symmetric(vertical: 4),
                        expandedText: true,
                        suffix: Row(
                          children: [
                            Image.asset(
                              ic_star_fill,
                              height: 18,
                              color: getRatingBarColor(widget
                                  .serviceDetail.serviceDetail!.totalRating
                                  .validate()
                                  .toInt()),
                            ),
                            4.width,
                            Text(
                                widget.serviceDetail.serviceDetail!.totalRating
                                    .validate()
                                    .toStringAsFixed(1),
                                style: context.boldTextStyle()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
