import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handyman_provider_flutter/components/review_list_view_component.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/attachment_model.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/models/service_detail_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/packages/components/package_component.dart';
import 'package:handyman_provider_flutter/provider/services/components/service_detail_header_component.dart';
import 'package:handyman_provider_flutter/provider/services/components/service_faq_widget.dart';
import 'package:handyman_provider_flutter/provider/shop/components/shop_component.dart';
import 'package:handyman_provider_flutter/screens/rating_view_all_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/back_widget.dart';
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

  Future<ServiceDetailResponse>? _serviceFuture;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);

    if (DEMO_MODE_ENABLED) {
      _serviceFuture = Future.value(getDemoServiceDetail(widget.serviceId));
    } else {
      _serviceFuture =
          getServiceDetail({'service_id': widget.serviceId.validate()});
    }
  }

  Widget serviceFaqWidget({required List<ServiceFaq> data}) {
    return Container(
      child: Column(
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
      ),
    );
  }

  Widget customerReviewWidget(
      {required List<RatingData> data,
      int? serviceId,
      required ServiceDetailResponse serviceDetailResponse}) {
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
            : Text(languages.lblNoReviewYet, style: secondaryTextStyle()),
      ],
    ).paddingSymmetric(horizontal: 16);
  }

  Widget availableWidget(
      {required ServiceDetailResponse zone, required ServiceData serviceData}) {
    // If zone list is available, show zone data
    if (zone.zones.validate().isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.topLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languages.availableAt,
                style: boldTextStyle(size: LABEL_TEXT_SIZE)),
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
                    decoration: boxDecorationDefault(color: context.cardColor),
                    child: Text(
                      '${value.name.validate()} ', // <-- showing zone ID
                      style: boldTextStyle(color: textPrimaryColorGlobal),
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
                style: boldTextStyle(size: LABEL_TEXT_SIZE)),
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
                    decoration: boxDecorationDefault(color: context.cardColor),
                    child: Text(
                      value.providerAddressMapping!.address.validate(),
                      style: boldTextStyle(color: textPrimaryColorGlobal),
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

  Widget buildBodyWidget(AsyncSnapshot<ServiceDetailResponse> snap) {
    if (snap.hasData) {
      return Scaffold(
        body: AnimatedScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          listAnimationType: ListAnimationType.FadeIn,
          fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceDetailHeaderComponent(
              serviceDetail: snap.data!,
              voidCallback: () {
                setState(() {});
              },
            ),
            if (snap.data!.serviceDetail!.isOnlineService)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  8.height,
                  Text(languages.serviceVisitType, style: boldTextStyle()),
                  8.height,
                  Text(languages.thisServiceIsOnlineRemote,
                      style: secondaryTextStyle()),
                ],
              ).paddingAll(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(languages.hintDescription,
                    style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                8.height,
                snap.data!.serviceDetail!.description.validate().isNotEmpty
                    ? ReadMoreText(
                        snap.data!.serviceDetail!.description.validate(),
                        style: secondaryTextStyle(),
                        textAlign: TextAlign.justify,
                        colorClickableText: context.primaryColor,
                      )
                    : Text(languages.lblNoDescriptionAvailable,
                        style: secondaryTextStyle()),
              ],
            ).paddingAll(16),
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

            PackageComponent(
                servicePackage:
                    snap.data!.serviceDetail!.servicePackage.validate()),
            if (snap.data!.serviceFaq.validate().isNotEmpty)
              serviceFaqWidget(data: snap.data!.serviceFaq.validate()),
            customerReviewWidget(
                data: snap.data!.ratingData!,
                serviceId: snap.data!.serviceDetail!.id,
                serviceDetailResponse: snap.data!),
            24.height,

            /// Service Approval and Rejection UI
            if (snap.data!.serviceDetail!.serviceRequestStatus ==
                SERVICE_PENDING)
              RichText(
                text: TextSpan(
                  style: secondaryTextStyle(),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${languages.note} ',
                      style: boldTextStyle(color: redColor),
                    ),
                    TextSpan(
                        text: languages.thisServiceIsCurrently,
                        style: secondaryTextStyle()),
                  ],
                ),
              ).paddingOnly(left: 16, right: 16, bottom: 16),
            if (snap.data!.serviceDetail!.serviceRequestStatus ==
                SERVICE_REJECT)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${languages.lblReason} :',
                      style: boldTextStyle(color: redColor)),
                  8.height,
                  Text(snap.data!.serviceDetail!.rejectReason.validate(),
                      style: secondaryTextStyle()),
                  16.height,
                  AppButton(
                    text: languages.lblDelete,
                    width: context.width(),
                    color: cancelled.withValues(alpha: 0.1),
                    textStyle: boldTextStyle(color: cancelled),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    onTap: () {
                      showConfirmDialogCustom(
                        context,
                        dialogType: DialogType.DELETE,
                        title: languages.doWantToDelete,
                        positiveText: languages.lblDelete,
                        negativeText: languages.lblCancel,
                        onAccept: (context) async {
                          if (snap.data != null) {
                            /// Service Delete API
                            //TODO: check this API after approval status and reason set from API
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
              ).paddingSymmetric(horizontal: 16),
          ],
        ),
      );
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: snap.connectionState == ConnectionState.waiting
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: transparentColor,
              leading: Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.only(left: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: BackWidget(color: context.iconColor)),
              scrolledUnderElevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness:
                    appStore.isDarkMode ? Brightness.light : Brightness.dark,
                statusBarColor: context.scaffoldBackgroundColor,
              ),
            ),
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
