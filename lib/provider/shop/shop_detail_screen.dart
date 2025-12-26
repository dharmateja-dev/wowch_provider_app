import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/empty_error_state_widget.dart';
import 'package:handyman_provider_flutter/generated/assets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/models/shop_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/service_widget.dart';
import 'package:handyman_provider_flutter/provider/services/service_list_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import 'shimmer/shop_detail_shimmer.dart';

/// Demo shop detail for UI testing
ShopDetailResponse getDemoShopDetail(int shopId) {
  // Placeholder image URLs for demo
  const demoShopImages = [
    'https://picsum.photos/seed/shop1/400/300',
    'https://picsum.photos/seed/shop2/400/300',
    'https://picsum.photos/seed/shop3/400/300',
  ];

  const demoServiceImages = [
    'https://picsum.photos/seed/service1/400/300',
    'https://picsum.photos/seed/service2/400/300',
    'https://picsum.photos/seed/service3/400/300',
    'https://picsum.photos/seed/service4/400/300',
    'https://picsum.photos/seed/service5/400/300',
    'https://picsum.photos/seed/service6/400/300',
    'https://picsum.photos/seed/service7/400/300',
    'https://picsum.photos/seed/service8/400/300',
  ];

  // Find the shop from demo list or create a default one
  final demoShops = [
    ShopModel(
      id: 1,
      name: 'Ayush',
      registrationNumber: 'REG001',
      address: '65A, Indrapuri',
      cityName: 'Bhopal',
      stateName: 'Madhya Pradesh',
      countryName: 'India',
      shopStartTime: '9:00 AM',
      shopEndTime: '6:16 PM',
      email: 'ayushdixit190@gmail.com',
      contactNumber: '91+ 1234567890',
      latitude: 23.2599,
      longitude: 77.4126,
      providerName: 'Ayush Kumar',
      shopImage: [demoShopImages[0]],
      services: [
        ServiceData(
            id: 1,
            name: 'Filter Replacement',
            categoryName: 'AC Repair',
            price: 600,
            totalRating: 4,
            imageAttachments: [demoServiceImages[0]]),
        ServiceData(
            id: 2,
            name: 'Full Home Sanitization',
            categoryName: 'Cleaning',
            price: 600,
            totalRating: 5,
            imageAttachments: [demoServiceImages[1]]),
        ServiceData(
            id: 3,
            name: 'Office Cleaning',
            categoryName: 'Cleaning',
            price: 600,
            totalRating: 4,
            imageAttachments: [demoServiceImages[2]]),
        ServiceData(
            id: 4,
            name: 'Custome Cake Creation',
            categoryName: 'Bakery',
            price: 600,
            totalRating: 5,
            imageAttachments: [demoServiceImages[3]]),
      ],
    ),
    ShopModel(
      id: 2,
      name: 'Prime Home Services',
      registrationNumber: 'REG002',
      address: '123 Main Street, Downtown',
      cityName: 'Mumbai',
      stateName: 'Maharashtra',
      countryName: 'India',
      shopStartTime: '8:00 AM',
      shopEndTime: '8:00 PM',
      email: 'prime@example.com',
      contactNumber: '+91 98765 12345',
      latitude: 19.0760,
      longitude: 72.8777,
      providerName: 'Prime Services',
      shopImage: [demoShopImages[1]],
      services: [
        ServiceData(
            id: 4,
            name: 'Deep Cleaning',
            categoryName: 'Cleaning',
            price: 2500,
            totalRating: 4.6,
            imageAttachments: [demoServiceImages[4]]),
        ServiceData(
            id: 5,
            name: 'Pest Control',
            categoryName: 'Home Care',
            price: 1800,
            totalRating: 4.4,
            imageAttachments: [demoServiceImages[5]]),
      ],
    ),
    ShopModel(
      id: 3,
      name: 'Quick Fix Station',
      registrationNumber: 'REG003',
      address: '456 Oak Avenue, Residency',
      cityName: 'Delhi',
      stateName: 'Delhi',
      countryName: 'India',
      shopStartTime: '10:00 AM',
      shopEndTime: '7:00 PM',
      email: 'quickfix@example.com',
      contactNumber: '+91 98765 67890',
      latitude: 28.7041,
      longitude: 77.1025,
      providerName: 'Quick Fix Team',
      shopImage: [demoShopImages[2]],
      services: [
        ServiceData(
            id: 6,
            name: 'Plumbing Repair',
            categoryName: 'Plumbing',
            price: 500,
            totalRating: 4.2,
            imageAttachments: [demoServiceImages[6]]),
        ServiceData(
            id: 7,
            name: 'Electrical Work',
            categoryName: 'Electrical',
            price: 600,
            totalRating: 4.3,
            imageAttachments: [demoServiceImages[7]]),
        ServiceData(
            id: 8,
            name: 'AC Service',
            categoryName: 'Appliance Repair',
            price: 800,
            totalRating: 4.5,
            imageAttachments: [demoServiceImages[0]]),
      ],
    ),
  ];

  final shop = demoShops.firstWhere(
    (s) => s.id == shopId,
    orElse: () => demoShops.first,
  );

  return ShopDetailResponse(shopDetail: shop);
}

class ShopDetailScreen extends StatefulWidget {
  final int shopId;

  const ShopDetailScreen({
    Key? key,
    required this.shopId,
  }) : super(key: key);

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  Future<ShopDetailResponse>? future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (DEMO_MODE_ENABLED) {
      future = Future.value(getDemoShopDetail(widget.shopId));
    } else {
      future = getShopDetail(widget.shopId);
    }
  }

  //TODO: Uncomment this when shop favorite feature is enabled

  // Future<void> _toggleFavorite(ShopModel shop) async {
  //   if (shop.isFavourite == 1) {
  //     // Remove from favorites
  //     shop.isFavourite = 0;
  //     setState(() {});

  //     await removeShopFromWishList(shopId: shop.id.validate()).then((value) {
  //       if (!value) {
  //         shop.isFavourite = 1;
  //         setState(() {});
  //       }
  //     });
  //   } else {
  //     // Add to favorites
  //     shop.isFavourite = 1;
  //     setState(() {});

  //     await addShopToWishList(shopId: shop.id.validate()).then((value) {
  //       if (!value) {
  //         shop.isFavourite = 0;
  //         setState(() {});
  //       }
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.primary,
        leading: BackWidget(color: context.onPrimary),
        title: Text(
          languages.lblShopDetails,
          style: context.boldTextStyle(color: context.onPrimary, size: 18),
        ),
        centerTitle: true,
      ),
      body: SnapHelperWidget<ShopDetailResponse>(
        future: future,
        loadingWidget: ShopDetailShimmer(),
        errorBuilder: (error) {
          return NoDataWidget(
            title: error,
            imageWidget: ErrorStateWidget(),
            retryText: languages.reload,
            onRetry: () {
              init();
              setState(() {});
            },
          ).center();
        },
        onSuccess: (shopResponse) {
          final ShopModel? shop = shopResponse.shopDetail;
          if (shop == null) {
            return NoDataWidget(
              title: languages.noDataFound,
              imageWidget: EmptyStateWidget(),
              retryText: languages.reload,
              onRetry: () {
                init();
                setState(() {});
              },
            ).center();
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 60, left: 16, top: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Shop Image - Centered
                Container(
                  height: 180,
                  width: context.width(),
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(12),
                    backgroundColor: context.cardSecondary,
                    border: Border.all(color: context.cardSecondaryBorder),
                  ),
                  child: shop.shopFirstImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: radius(12),
                          child: CachedImageWidget(
                            url: shop.shopFirstImage,
                            fit: BoxFit.contain,
                            width: context.width(),
                            height: 180,
                          ),
                        )
                      : Center(
                          child: Image.asset(
                            Assets.iconsIcDefaultShop,
                            height: 80,
                            width: 80,
                            color: context.primary,
                          ),
                        ),
                ),
                16.height,

                /// Shop Name
                Text(shop.name, style: context.boldTextStyle(size: 18)),
                12.height,

                /// Shop Contact Details
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email
                    if (shop.email.validate().isNotEmpty)
                      _buildContactRow(
                        context: context,
                        icon: ic_message,
                        text: shop.email.validate(),
                        onTap: () => launchMail(shop.email.validate()),
                      ),

                    // Phone
                    if (shop.contactNumber.validate().isNotEmpty)
                      _buildContactRow(
                        context: context,
                        icon: calling,
                        text: shop.contactNumber.validate(),
                        onTap: () => launchCall(shop.contactNumber.validate()),
                      ),

                    // Address
                    if (shop.address.isNotEmpty)
                      _buildContactRow(
                        context: context,
                        icon: ic_location,
                        text:
                            "${shop.address}\n${shop.cityName}, ${shop.stateName}",
                        onTap: () {
                          if (shop.latitude != 0 && shop.longitude != 0) {
                            launchMapFromLatLng(
                                latitude: shop.latitude,
                                longitude: shop.longitude);
                          } else {
                            launchMap(shop.address);
                          }
                        },
                      ),

                    // Timing
                    if (shop.shopStartTime.isNotEmpty &&
                        shop.shopEndTime.isNotEmpty)
                      _buildContactRow(
                        context: context,
                        icon: ic_time_slots,
                        text: "${shop.shopStartTime} - ${shop.shopEndTime}",
                      ),
                  ],
                ),
                24.height,

                /// My Services Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      languages.lblMyService,
                      style: context.boldTextStyle(size: 16),
                    ),
                    if (shop.services.validate().length >= 4)
                      GestureDetector(
                        onTap: () {
                          ServiceListScreen(shopId: shop.id).launch(context);
                        },
                        child: Text(
                          languages.viewAll,
                          style: context.primaryTextStyle(size: 12),
                        ),
                      ),
                  ],
                ),
                16.height,

                // Services Grid
                if (shop.services.validate().isNotEmpty)
                  AnimatedWrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: shop.services.validate().take(4).map((service) {
                      return ServiceComponent(
                        width: context.width() / 2 - 22,
                        data: ServiceData(
                          id: service.id,
                          name: service.name,
                          price: service.price,
                          discount: 0,
                          providerName: shop.providerName,
                          providerImage: shop.providerImage,
                          imageAttachments: service.imageAttachments,
                          categoryName: service.categoryName,
                          totalRating: service.totalRating,
                          visitType: VISIT_OPTION_SHOP,
                        ),
                      );
                    }).toList(),
                  )
                else
                  NoDataWidget(
                    title: languages.noServiceFound,
                    imageWidget: EmptyStateWidget(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContactRow({
    required BuildContext context,
    required String icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              icon,
              width: 16,
              height: 16,
              color: context.primary,
            ),
            10.width,
            Expanded(
              child: Text(
                text,
                style: context.primaryTextStyle(size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
