import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/disabled_rating_bar_widget.dart';
import 'package:handyman_provider_flutter/components/image_border_component.dart';
import 'package:handyman_provider_flutter/components/review_list_view_component.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/provider_info_model.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/rating_view_all_screen.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/images.dart';
import '../utils/demo_data.dart';
import '../utils/colors.dart';

class HandymanInfoScreen extends StatefulWidget {
  final int? handymanId;
  final ServiceData? service;

  HandymanInfoScreen({this.handymanId, this.service});

  @override
  HandymanInfoScreenState createState() => HandymanInfoScreenState();
}

class HandymanInfoScreenState extends State<HandymanInfoScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setDemoMode(true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget handymanWidget({required HandymanInfoResponse data}) {
    return SizedBox(
      child: Stack(
        children: [
          Container(
            height: 120, // Increased height
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: radiusCircular(24)),
              color: context.primary,
            ),
          ),
          Positioned(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(top: 24, left: 16, right: 16),
              decoration: boxDecorationDefault(
                color: context.cardSecondary,
                boxShadow: defaultBoxShadow(), // Fixed method name
                borderRadius: radius(16),
                border: Border.all(color: context.cardSecondaryBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (data.handymanData!.profileImage.validate().isNotEmpty)
                        ImageBorder(
                          src: data.handymanData!.profileImage.validate(),
                          height: 80,
                        ),
                      16.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          10.height,
                          Text(data.handymanData!.displayName.validate(),
                              style: context.boldTextStyle(size: 16)),
                          if (data.handymanData!.designation
                              .validate()
                              .isNotEmpty)
                            Column(
                              children: [
                                4.height,
                                Text(
                                  data.handymanData!.designation.validate(),
                                  style: context.primaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                4.height,
                              ],
                            ),
                          4.height,
                          if (data.handymanData!.createdAt != null)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(languages.lblMemberSince,
                                    style: context.primaryTextStyle()),
                                Text(
                                    " ${DateTime.parse(data.handymanData!.createdAt.validate()).year}",
                                    style: context.primaryTextStyle()),
                              ],
                            ),
                          4.height,
                          Row(
                            children: [
                              Text("${languages.lblTotalBooking}:",
                                  style: context.primaryTextStyle()),
                              Text(
                                " ${data.handymanData!.totalBooking.validate()}",
                                style: context.primaryTextStyle(),
                              ),
                            ],
                          ),
                          10.height,
                          DisabledRatingBarWidget(
                              rating: data.handymanData!.handymanRating
                                  .validate()
                                  .toDouble()),
                        ],
                      ).expand(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<HandymanInfoResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        log(snap.data!.toJson());
        return Stack(
          children: [
            AnimatedScrollView(
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: context.statusBarHeight, bottom: 8),
                      color: context.primary,
                      child: Row(
                        children: [
                          BackWidget(),
                          16.width,
                          Text(languages.lblAboutHandyman,
                              style: context.boldTextStyle(
                                  color: context.onPrimary, size: 18)),
                        ],
                      ),
                    ),
                    handymanWidget(data: snap.data!),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (snap.data!.handymanData!.knownLanguagesArray
                                .isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(languages.knownLanguages,
                                      style: context.boldTextStyle()),
                                  8.height,
                                  Wrap(
                                    children: snap
                                        .data!.handymanData!.knownLanguagesArray
                                        .map((e) {
                                      return Container(
                                        decoration:
                                            boxDecorationWithRoundedCorners(
                                          borderRadius: radius(8),
                                          backgroundColor:
                                              context.cardSecondary,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        margin: const EdgeInsets.all(4),
                                        child: Text(e,
                                            style: context.boldTextStyle()),
                                      );
                                    }).toList(),
                                  ),
                                  16.height,
                                ],
                              ),
                            if (snap.data!.handymanData!.skillsArray.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(languages.essentialSkills,
                                      style: context.boldTextStyle()),
                                  8.height,
                                  Wrap(
                                    children: snap
                                        .data!.handymanData!.skillsArray
                                        .map((e) {
                                      return Container(
                                        decoration:
                                            boxDecorationWithRoundedCorners(
                                          borderRadius: radius(8),
                                          backgroundColor:
                                              context.cardSecondary,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        margin: const EdgeInsets.all(4),
                                        child: Text(e,
                                            style: context.boldTextStyle()),
                                      );
                                    }).toList(),
                                  ),
                                  16.height,
                                ],
                              ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: boxDecorationDefault(
                                color: context.cardSecondary,
                                borderRadius: radius(12),
                                border: Border.all(
                                    color: context.cardSecondaryBorder),
                                boxShadow: [],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(languages.personalInfo,
                                      style: context.boldTextStyle()),
                                  12.height,
                                  TextIcon(
                                    spacing: 12,
                                    onTap: () {
                                      launchMail(snap.data!.handymanData!.email
                                          .validate());
                                    },
                                    prefix: Image.asset(ic_message,
                                        width: 18,
                                        height: 18,
                                        color: context.primary),
                                    text: snap.data!.handymanData!.email
                                        .validate(),
                                    textStyle: context.primaryTextStyle(
                                      size: 14,
                                    ),
                                    expandedText: true,
                                  ),
                                  8.height,
                                  TextIcon(
                                    spacing: 12,
                                    onTap: () {
                                      launchCall(snap
                                          .data!.handymanData!.contactNumber
                                          .validate());
                                    },
                                    prefix: Image.asset(calling,
                                        width: 18,
                                        height: 18,
                                        color: context.primary),
                                    text: snap.data!.handymanData!.contactNumber
                                        .validate(),
                                    textStyle: context.primaryTextStyle(
                                      size: 14,
                                    ),
                                    expandedText: true,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        16.height,
                        if (snap.data!.service.validate().isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(languages.lblServices,
                                      style: context.boldTextStyle())
                                  .paddingSymmetric(horizontal: 8),
                              8.height,
                              HorizontalList(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                itemCount: snap.data!.service.validate().length,
                                itemBuilder: (context, index) {
                                  ServiceData service =
                                      snap.data!.service.validate()[index];
                                  return Container(
                                    width: 250,
                                    decoration: boxDecorationDefault(
                                      color: context.cardSecondary,
                                      borderRadius: radius(8),
                                      border: Border.all(
                                          color: context.cardSecondaryBorder),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CachedImageWidget(
                                          url: service.imageAttachments
                                                  .validate()
                                                  .isNotEmpty
                                              ? service.imageAttachments!.first
                                              : '',
                                          height: 120,
                                          width: 250,
                                          fit: BoxFit.cover,
                                        ).cornerRadiusWithClipRRectOnly(
                                            topLeft: 8, topRight: 8),
                                        10.height,
                                        Text(service.name.validate(),
                                                style: context.boldTextStyle(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis)
                                            .paddingSymmetric(horizontal: 10),
                                        5.height,
                                        PriceWidget(
                                                price: service.price.validate(),
                                                size: 12,
                                                color: context.primary)
                                            .paddingSymmetric(horizontal: 10),
                                        10.height,
                                      ],
                                    ),
                                  );
                                },
                              ),
                              16.height,
                            ],
                          ),
                        ViewAllLabel(
                          label: languages.review,
                          list: snap.data!.handymanRatingReview!,
                          onTap: () {
                            RatingViewAllScreen(
                                    handymanId: snap.data!.handymanData!.id)
                                .launch(context);
                          },
                        ),
                        snap.data!.handymanRatingReview.validate().isNotEmpty
                            ? ReviewListViewComponent(
                                ratings: snap.data!.handymanRatingReview!,
                                physics: const NeverScrollableScrollPhysics(),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                isCustomer: true,
                              )
                            : Text(languages.lblNoReviewYet,
                                    style: context.primaryTextStyle())
                                .center()
                                .paddingOnly(top: 16),
                      ],
                    ).paddingAll(16),
                  ],
                ),
              ],
            ),
          ],
        );
      }
      return LoaderWidget().center();
    }

    return FutureBuilder<HandymanInfoResponse>(
      future: appStore.isDemoMode
          ? Future.value(DemoHandymanData.handymanInfoResponse)
          : getProviderDetail(widget.handymanId.validate()),
      builder: (context, snap) {
        return Scaffold(
          backgroundColor: context.scaffoldSecondary,
          body: buildBodyWidget(snap),
        );
      },
    );
  }
}
