import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/components/review_list_view_component.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/attachment_model.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/packages/components/package_component.dart';
import 'package:handyman_provider_flutter/provider/services/add_services.dart';
import 'package:handyman_provider_flutter/provider/services/components/service_faq_widget.dart';
import 'package:handyman_provider_flutter/provider/shop/components/shop_component.dart';
import 'package:handyman_provider_flutter/screens/gallery_List_Screen.dart';
import 'package:handyman_provider_flutter/screens/rating_view_all_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';
import '../../utils/colors.dart';
import 'shimmer/service_detail_shimmer.dart';

/// Demo service detail for UI testing
ServiceDetailResponse getDemoServiceDetail(int serviceId) {
  return ServiceDetailResponse(
    serviceDetail: ServiceData(
      id: serviceId,
      name: 'Custom Cake Creations',
      categoryName: 'Food & Bakery',
      price: 1500,
      discount: 10,
      duration: '02:00',
      type: SERVICE_TYPE_FIXED,
      totalRating: 4.5,
      totalReview: 25,
      description:
          'Delicious custom cakes for all occasions - birthdays, weddings, anniversaries, and more. We use premium ingredients and offer various flavors, designs, and sizes to match your event perfectly.',
      status: 1,
      providerName: 'Demo Provider',
      attchments: [
        Attachments(
            id: 1,
            url:
                'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800',
            name: 'cake1.jpg'),
        Attachments(
            id: 2,
            url:
                'https://images.unsplash.com/photo-1562440499-64c9a111f713?w=800',
            name: 'cake2.jpg'),
        Attachments(
            id: 3,
            url:
                'https://images.unsplash.com/photo-1535254973040-607b474cb50d?w=800',
            name: 'cake3.jpg'),
      ],
    ),
    ratingData: [
      RatingData(
        id: 1,
        rating: 5,
        review:
            'Excellent service! The cake was delicious and beautifully decorated.',
        customerName: 'John Doe',
        createdAt: '2024-01-15',
      ),
      RatingData(
        id: 2,
        rating: 4,
        review: 'Great taste and on-time delivery. Will order again!',
        customerName: 'Jane Smith',
        createdAt: '2024-01-10',
      ),
    ],
    serviceFaq: [
      ServiceFaq(
        id: 1,
        title: 'How far in advance should I place my order?',
        description:
            'We recommend placing your order at least 3-5 days in advance for custom cakes.',
      ),
      ServiceFaq(
        id: 2,
        title: 'Do you offer eggless options?',
        description: 'Yes, we offer eggless cake options at no extra charge.',
      ),
    ],
    zones: [
      Zones(id: 1, name: 'Downtown'),
      Zones(id: 2, name: 'Suburb Area'),
    ],
  );
}

class ServiceDetailScreen extends StatefulWidget {
  final int serviceId;

  ServiceDetailScreen({required this.serviceId});

  @override
  ServiceDetailScreenState createState() => ServiceDetailScreenState();
}

class ServiceDetailScreenState extends State<ServiceDetailScreen> {
  PageController pageController = PageController();
  int currentImageIndex = 0;

  Future<ServiceDetailResponse>? _serviceFuture;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (DEMO_MODE_ENABLED) {
      _serviceFuture = Future.value(getDemoServiceDetail(widget.serviceId));
    } else {
      _serviceFuture =
          getServiceDetail({'service_id': widget.serviceId.validate()});
    }
  }

  void removeService() {
    deleteService(widget.serviceId.validate()).then((value) {
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
      height: 80,
      width: 290,
      title: languages.confirmationRequestTxt,
      shape: appDialogShape(8),
      titleColor: context.dialogTitleColor,
      backgroundColor: context.dialogBackgroundColor,
      primaryColor: context.primary,
      customCenterWidget: Image.asset(
        ic_warning,
        color: context.onSecondaryContainer,
        height: 70,
        width: 70,
        fit: BoxFit.cover,
      ),
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

  /// Image Gallery Section with PageView
  Widget _buildImageGallery(ServiceDetailResponse data) {
    final attachments = data.serviceDetail!.attchments.validate();
    if (attachments.isEmpty) {
      return Container(
        height: 250,
        color: context.cardColor,
        child: Center(
          child: Icon(Icons.image_not_supported_outlined,
              size: 64, color: context.iconMuted),
        ),
      );
    }

    return Column(
      children: [
        // Main Image Slider
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: pageController,
            itemCount: attachments.length,
            onPageChanged: (index) {
              setState(() {
                currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  GalleryListScreen(
                    galleryImages:
                        attachments.map((e) => e.url.validate()).toList(),
                    serviceName: data.serviceDetail!.name.validate(),
                  ).launch(context,
                      pageRouteAnimation: PageRouteAnimation.Fade,
                      duration: 400.milliseconds);
                },
                child: CachedImageWidget(
                  url: attachments[index].url.validate(),
                  fit: BoxFit.cover,
                  width: context.width(),
                  height: 250,
                ),
              );
            },
          ),
        ),

        // Thumbnail Row and Page Indicator
        if (attachments.length > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Thumbnails
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        attachments.length,
                        (i) => GestureDetector(
                          onTap: () {
                            pageController.animateToPage(
                              i,
                              duration: 300.milliseconds,
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: currentImageIndex == i
                                    ? context.primary
                                    : context.outlineVariant,
                                width: currentImageIndex == i ? 2 : 1,
                              ),
                              borderRadius: radius(8),
                            ),
                            child: ClipRRect(
                              borderRadius: radius(6),
                              child: CachedImageWidget(
                                url: attachments[i].url.validate(),
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page indicator
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: boxDecorationDefault(
                    color: context.secondaryContainer,
                    borderRadius: radius(16),
                  ),
                  child: Text(
                    '${currentImageIndex + 1}/${attachments.length}',
                    style:
                        context.boldTextStyle(size: 12, color: context.primary),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Service Details Card - Original UI
  Widget _buildServiceDetailsCard(ServiceDetailResponse data) {
    final service = data.serviceDetail!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: context.cardSecondary,
        border: Border.all(color: context.cardSecondaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category breadcrumb
          if (service.subCategoryName.validate().isNotEmpty)
            Marquee(
              child: Row(
                children: [
                  Text('${service.categoryName}',
                      style: context.boldTextStyle(
                          size: 12, color: context.primary)),
                  Text('  >  ',
                      style: context.boldTextStyle(
                          size: 14, color: context.primary)),
                  Text(service.subCategoryName.capitalizeFirstLetter(),
                      style: context.boldTextStyle(
                          color: context.primary, size: 12)),
                ],
              ),
            )
          else
            Text('${service.categoryName}',
                style: context.boldTextStyle(color: context.primary)),

          8.height,

          // Service Name
          Marquee(
            directionMarguee: DirectionMarguee.oneDirection,
            child: Text(service.name.validate(),
                style: context.boldTextStyle(size: 18)),
          ),

          8.height,

          // Price and Discount Row
          Row(
            children: [
              PriceWidget(
                price: service.price.validate(),
                isHourlyService: service.isHourlyService,
                size: 16,
                hourlyTextColor: context.textGrey,
                isFreeService: service.isFreeService,
              ),
              4.width,
              if (service.discount.validate() != 0)
                Text(
                  '(${service.discount.validate()}% ${languages.lblOff})',
                  style: context.boldTextStyle(color: context.discountColor),
                ),
            ],
          ),

          4.height,

          // Duration
          TextIcon(
            edgeInsets: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            text: languages.hintDuration,
            textStyle: context.primaryTextStyle(size: 14),
            expandedText: true,
            suffix: Text(
              convertToHourMinute(service.duration.validate()),
              style: context.boldTextStyle(color: context.primary),
            ),
          ),

          // Rating
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
                  color:
                      getRatingBarColor(service.totalRating.validate().toInt()),
                ),
                4.width,
                Text(
                  service.totalRating.validate().toStringAsFixed(1),
                  style: context.boldTextStyle(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget serviceFaqWidget({required List<ServiceFaq> data}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        12.height,
        ViewAllLabel(label: languages.lblFAQs, list: data)
            .paddingSymmetric(horizontal: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: data.length,
          itemBuilder: (_, index) {
            return ServiceFaqWidget(serviceFaq: data[index]);
          },
        ),
      ],
    );
  }

  Widget customerReviewWidget({
    required List<RatingData> data,
    int? serviceId,
    required ServiceDetailResponse serviceDetailResponse,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        ViewAllLabel(
          label:
              '${languages.review} (${serviceDetailResponse.serviceDetail!.totalReview})',
          list: data,
          onTap: () {
            RatingViewAllScreen(serviceId: serviceId)
                .launch(context)
                .then((value) => init());
          },
        ),
        8.height,
        data.isNotEmpty
            ? ReviewListViewComponent(
                ratings: data,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 6),
              )
            : Text(languages.lblNoReviewYet, style: context.primaryTextStyle()),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget availableWidget({
    required ServiceDetailResponse zone,
    required ServiceData serviceData,
  }) {
    // If zone list is available, show zone data
    if (zone.zones.validate().isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languages.availableAt,
                style: context.boldTextStyle(size: LABEL_TEXT_SIZE)),
            16.height,
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(
                zone.zones!.length,
                (index) {
                  Zones value = zone.zones![index];
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: boxDecorationDefault(
                        color: context.secondaryContainer,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(
                      '${value.name.validate()}',
                      style: context.boldTextStyle(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // If no zones, check for service address mapping
    if (serviceData.serviceAddressMapping.validate().isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languages.availableAt,
                style: context.boldTextStyle(size: LABEL_TEXT_SIZE)),
            16.height,
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: List.generate(
                serviceData.serviceAddressMapping!.length,
                (index) {
                  ServiceAddressMapping value =
                      serviceData.serviceAddressMapping![index];
                  if (value.providerAddressMapping == null)
                    return const Offstage();
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration:
                        boxDecorationDefault(color: context.cardSecondary),
                    child: Text(
                      value.providerAddressMapping!.address.validate(),
                      style: context.boldTextStyle(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // If neither zones nor address mapping is available
    return const Offstage();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// Build AppBar with popup menu
  PreferredSizeWidget _buildAppBar(ServiceDetailResponse? data) {
    return appBarWidget(
      data?.serviceDetail?.name ?? languages.lblServices,
      textColor: context.onPrimary,
      color: context.primary,
      backWidget: BackWidget(),
      actions: [
        if (data != null &&
            isUserTypeProvider &&
            (rolesAndPermissionStore.serviceEdit ||
                rolesAndPermissionStore.serviceDelete))
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: context.onPrimary),
            color: context.cardColor,
            onSelected: (selection) {
              if (selection == 1) {
                AddServices(data: data).launch(context).then((value) {
                  if (value ?? false) {
                    init();
                    setState(() {});
                  }
                });
              } else if (selection == 2) {
                confirmationDialog(context);
              }
            },
            itemBuilder: (context) => [
              if (rolesAndPermissionStore.serviceEdit)
                PopupMenuItem(
                  value: 1,
                  child:
                      Text(languages.lblEdit, style: context.boldTextStyle()),
                ),
              if (rolesAndPermissionStore.serviceDelete)
                PopupMenuItem(
                  value: 2,
                  child:
                      Text(languages.lblDelete, style: context.boldTextStyle()),
                ),
            ],
          ),
      ],
    );
  }

  Widget buildBodyWidget(AsyncSnapshot<ServiceDetailResponse> snap) {
    if (snap.hasData) {
      return Scaffold(
        backgroundColor: context.scaffoldSecondary,
        appBar: _buildAppBar(snap.data),
        body: AnimatedScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            _buildImageGallery(snap.data!),

            // Service Details Card
            _buildServiceDetailsCard(snap.data!),

            // Online Service Info
            if (snap.data!.serviceDetail!.isOnlineService)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: boxDecorationDefault(
                  color: context.primaryContainer,
                  borderRadius: radius(),
                ),
                child: Row(
                  children: [
                    Icon(Icons.videocam_rounded, color: context.icon),
                    12.width,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(languages.serviceVisitType,
                              style: context.boldTextStyle()),
                          4.height,
                          Text(languages.thisServiceIsOnlineRemote,
                              style: context.primaryTextStyle()),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Description Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: boxDecorationDefault(
                  color: context.cardSecondary,
                  borderRadius: radius(),
                  border: Border.all(color: context.cardSecondaryBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(languages.hintDescription,
                      style: context.boldTextStyle(size: LABEL_TEXT_SIZE)),
                  12.height,
                  snap.data!.serviceDetail!.description.validate().isNotEmpty
                      ? ReadMoreText(
                          snap.data!.serviceDetail!.description.validate(),
                          style: context.secondaryTextStyle(size: 14),
                          textAlign: TextAlign.justify,
                          colorClickableText: context.primary,
                        )
                      : Text(languages.lblNoDescriptionAvailable,
                          style: context.secondaryTextStyle(size: 14)),
                ],
              ),
            ),

            // Available Zones
            availableWidget(
              serviceData: snap.data!.serviceDetail!,
              zone: snap.data!,
            ),

            // Shop Details Section
            if (snap.data!.shop.validate().isNotEmpty)
              HorizontalShopListComponent(
                listTitle: languages.lblAboutShop,
                shopList: snap.data!.shop.validate(),
                cardWidth: context.width() * 0.9,
                serviceId: snap.data!.serviceDetail!.id.validate(),
                serviceName: snap.data!.serviceDetail!.name.validate(),
                showServices: false,
              ),

            // Package Component
            PackageComponent(
              servicePackage:
                  snap.data!.serviceDetail!.servicePackage.validate(),
            ),

            // FAQs
            if (snap.data!.serviceFaq.validate().isNotEmpty)
              serviceFaqWidget(data: snap.data!.serviceFaq.validate()),

            // Customer Reviews
            customerReviewWidget(
              data: snap.data!.ratingData!,
              serviceId: snap.data!.serviceDetail!.id,
              serviceDetailResponse: snap.data!,
            ),

            24.height,

            /// Service Approval and Rejection UI
            if (snap.data!.serviceDetail!.serviceRequestStatus ==
                SERVICE_PENDING)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: boxDecorationDefault(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: radius(),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    12.width,
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: context.secondaryTextStyle(),
                          children: <TextSpan>[
                            TextSpan(
                              text: '${languages.note} ',
                              style:
                                  context.boldTextStyle(color: Colors.orange),
                            ),
                            TextSpan(
                              text: languages.thisServiceIsCurrently,
                              style: context.secondaryTextStyle(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (snap.data!.serviceDetail!.serviceRequestStatus ==
                SERVICE_REJECT)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: boxDecorationDefault(
                  color: redColor.withValues(alpha: 0.1),
                  borderRadius: radius(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: redColor),
                        8.width,
                        Text('${languages.lblReason}:',
                            style: context.boldTextStyle(color: redColor)),
                      ],
                    ),
                    8.height,
                    Text(snap.data!.serviceDetail!.rejectReason.validate(),
                        style: context.secondaryTextStyle()),
                    16.height,
                    AppButton(
                      text: languages.lblDelete,
                      width: context.width(),
                      color: cancelled.withValues(alpha: 0.1),
                      textStyle: context.boldTextStyle(color: cancelled),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      onTap: () {
                        showConfirmDialogCustom(
                          context,
                          height: 80,
                          width: 290,
                          shape: appDialogShape(8),
                          dialogType: DialogType.DELETE,
                          title: languages.doWantToDelete,
                          titleColor: context.dialogTitleColor,
                          backgroundColor: context.dialogBackgroundColor,
                          primaryColor: context.primary,
                          customCenterWidget: Image.asset(
                            ic_warning,
                            color: context.onSecondaryContainer,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                          positiveText: languages.lblDelete,
                          positiveTextColor: context.onPrimary,
                          negativeText: languages.lblCancel,
                          negativeTextColor: context.dialogCancelColor,
                          onAccept: (context) async {
                            if (snap.data != null) {
                              ifNotTester(context, () {
                                appStore.setLoading(true);
                                deleteService(widget.serviceId.validate())
                                    .then((value) {
                                  getServiceDetail({
                                    'service_id': widget.serviceId.validate()
                                  });
                                  finish(context, true);
                                }).catchError((e) {
                                  appStore.setLoading(false);
                                  toast(e.toString(), print: true);
                                });
                              });
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: _buildAppBar(null),
      body: snapWidgetHelper(
        snap,
        loadingWidget: ServiceDetailShimmer(),
        errorWidget: NoDataWidget(
          title: snap.error.toString(),
          imageWidget: const ErrorStateWidget(),
          retryText: languages.reload,
          onRetry: () {
            init();
            setState(() {});
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ServiceDetailResponse>(
      initialData: DEMO_MODE_ENABLED
          ? null
          : listOfCachedData
              .firstWhere(
                  (element) => element?.$1 == widget.serviceId.validate(),
                  orElse: () => null)
              ?.$2,
      future: _serviceFuture,
      builder: (context, snap) {
        return buildBodyWidget(snap);
      },
    );
  }
}
