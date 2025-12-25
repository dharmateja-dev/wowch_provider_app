import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/gallery_component.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/package_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/screens/gallery_List_Screen.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';

class PackageDetailScreen extends StatefulWidget {
  final PackageData? packageData;

  PackageDetailScreen({this.packageData});

  @override
  _PackageDetailScreenState createState() => _PackageDetailScreenState();
}

class _PackageDetailScreenState extends State<PackageDetailScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);
  }

  Widget headerWidget() {
    return SizedBox(
      height: 475,
      width: context.width(),
      child: Stack(
        children: [
          if (widget.packageData!.attchments.validate().isNotEmpty)
            SizedBox(
              height: 400,
              width: context.width(),
              child: CachedImageWidget(
                url: widget.packageData!.attchments!.first.url.validate(),
                fit: BoxFit.cover,
                height: 400,
              ),
            ),
          Positioned(
            top: context.statusBarHeight + 8,
            left: 8,
            child: Container(
              child: BackWidget(color: context.icon).paddingLeft(8),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.cardColor.withValues(alpha: 0.7)),
            ),
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
                        widget.packageData!.attchments
                            .validate()
                            .take(2)
                            .length,
                        (i) => Container(
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: context.textGrey, width: 2),
                              borderRadius: radius()),
                          child: GalleryComponent(
                            images: widget.packageData!.attchments
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
                    if (widget.packageData!.attchments.validate().length > 2)
                      Blur(
                        borderRadius: radius(),
                        child: Container(
                          height: 60,
                          width: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: context.textGrey, width: 2),
                              borderRadius: radius()),
                          child: Text(
                              '+'
                              '${widget.packageData!.attchments.validate().length - 2}',
                              style: context.boldTextStyle(
                                  color: context.onPrimary)),
                        ),
                      ).onTap(
                        () {
                          GalleryListScreen(
                            galleryImages: widget.packageData!.attchments
                                .validate()
                                .map((e) => e.url.validate())
                                .toList(),
                            serviceName: widget.packageData!.name.validate(),
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
                      8.height,
                      Marquee(
                        child: Text(widget.packageData!.name.validate(),
                            style: context.boldTextStyle(size: 20)),
                        directionMarguee: DirectionMarguee.oneDirection,
                      ),
                      8.height,
                      if (widget.packageData!.subCategoryName
                          .validate()
                          .isNotEmpty)
                        Marquee(
                          child: Row(
                            children: [
                              Text(widget.packageData!.categoryName.validate(),
                                  style: context.boldTextStyle(
                                    size: 14,
                                  )),
                              Text('  >  ',
                                  style: context.boldTextStyle(
                                    size: 14,
                                  )),
                              Text(
                                  widget.packageData!.subCategoryName
                                      .validate(),
                                  style: context.boldTextStyle(
                                      size: 14, color: context.primary)),
                            ],
                          ),
                        )
                      else if (widget.packageData!.categoryName != null)
                        Text(widget.packageData!.categoryName.validate(),
                            style: context.boldTextStyle(
                                size: 14, color: context.primary))
                      else
                        const Offstage(),
                      8.height,
                      PriceWidget(
                        price: widget.packageData!.price.validate(),
                        size: 18,
                        hourlyTextColor: context.textGrey,
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

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      body: AnimatedScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        listAnimationType: ListAnimationType.FadeIn,
        fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              headerWidget(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(languages.hintDescription,
                          style: context.boldTextStyle(size: LABEL_TEXT_SIZE)),
                      8.height,
                      widget.packageData!.description.validate().isNotEmpty
                          ? ReadMoreText(
                              widget.packageData!.description.validate(),
                              style: context.primaryTextStyle(),
                              colorClickableText: context.primaryColor,
                            )
                          : Text(languages.lblNoDescriptionAvailable,
                              style: context.primaryTextStyle()),
                    ],
                  ),
                  16.height,
                  Text(languages.lblServices, style: boldTextStyle()),
                  16.height,
                  if (widget.packageData!.serviceList != null)
                    AnimatedListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      listAnimationType: ListAnimationType.FadeIn,
                      fadeInConfiguration:
                          FadeInConfiguration(duration: 2.seconds),
                      padding: EdgeInsets.zero,
                      itemCount: widget.packageData!.serviceList!.length,
                      itemBuilder: (_, i) {
                        ServiceData data = widget.packageData!.serviceList![i];

                        return Container(
                          width: context.width(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: radius(),
                            backgroundColor: context.cardSecondary,
                            border:
                                Border.all(color: context.cardSecondaryBorder),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedImageWidget(
                                url: data.imageAttachments!.isNotEmpty
                                    ? data.imageAttachments!.first
                                    : "",
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                                radius: 8,
                              ),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Marquee(
                                      child: Text(data.name.validate(),
                                          style: context.boldTextStyle(
                                              size: LABEL_TEXT_SIZE))),
                                  4.height,
                                  if (data.subCategoryName
                                      .validate()
                                      .isNotEmpty)
                                    Marquee(
                                      child: Row(
                                        children: [
                                          Text('${data.categoryName}',
                                              style: context.boldTextStyle(
                                                size: 14,
                                              )),
                                          Text('  >  ',
                                              style: context.boldTextStyle(
                                                size: 14,
                                              )),
                                          Text('${data.subCategoryName}',
                                              style: context.boldTextStyle(
                                                color: context.primary,
                                                size: 14,
                                              )),
                                        ],
                                      ),
                                    )
                                  else
                                    Text('${data.categoryName}',
                                        style: context.boldTextStyle(
                                          color: context.primary,
                                          size: 14,
                                        )),
                                  4.height,
                                  PriceWidget(
                                    price: data.price.validate(),
                                    hourlyTextColor: context.textGrey,
                                    size: 14,
                                  ),
                                ],
                              ).expand()
                            ],
                          ),
                        );
                      },
                    )
                  else
                    NoDataWidget(
                      title: languages.noServiceFound,
                      imageWidget: const EmptyStateWidget(),
                    ),
                ],
              ).paddingSymmetric(horizontal: 16)
            ],
          ),
        ],
      ),
    );
  }
}
