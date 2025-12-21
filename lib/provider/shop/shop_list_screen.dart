import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/empty_error_state_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/shop_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/shop/add_edit_shop_screen.dart';
import 'package:handyman_provider_flutter/provider/shop/components/shop_component.dart';
import 'package:handyman_provider_flutter/provider/shop/shimmer/shop_list_shimmer.dart';
import 'package:handyman_provider_flutter/provider/shop/shop_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

/// Demo shop data for UI testing
List<ShopModel> get demoShopList => [
      ShopModel(
        id: 1,
        name: 'Ayush',
        address: '65A, Indrapuri, Bhopal, M...',
        shopStartTime: '9:00 AM',
        shopEndTime: '6:16 PM',
        cityName: 'Bhopal',
        stateName: 'Madhya Pradesh',
        countryName: 'India',
        shopImage: [],
        services: [
          ServiceData(id: 1, name: 'Custom Cake Creations'),
          ServiceData(id: 2, name: 'Office Cleaning'),
          ServiceData(id: 3, name: 'Full Home Sanitization'),
        ],
      ),
      ShopModel(
        id: 2,
        name: 'Prime Home Services',
        address: '123 Main Street, Downtown',
        shopStartTime: '8:00 AM',
        shopEndTime: '8:00 PM',
        cityName: 'Mumbai',
        stateName: 'Maharashtra',
        countryName: 'India',
        shopImage: [],
        services: [
          ServiceData(id: 4, name: 'Deep Cleaning'),
          ServiceData(id: 5, name: 'Pest Control'),
        ],
      ),
      ShopModel(
        id: 3,
        name: 'Quick Fix Station',
        address: '456 Oak Avenue, Residency',
        shopStartTime: '10:00 AM',
        shopEndTime: '7:00 PM',
        cityName: 'Delhi',
        stateName: 'Delhi',
        countryName: 'India',
        shopImage: [],
        services: [
          ServiceData(id: 6, name: 'Plumbing Repair'),
          ServiceData(id: 7, name: 'Electrical Work'),
          ServiceData(id: 8, name: 'AC Service'),
        ],
      ),
    ];

class ShopListScreen extends StatefulWidget {
  final bool fromShopDocument;
  final bool fromServiceDetail;

  final int serviceId;

  final String serviceName;

  final List<ShopModel> selectedShops;

  const ShopListScreen({
    Key? key,
    this.fromShopDocument = false,
    this.fromServiceDetail = false,
    this.selectedShops = const <ShopModel>[],
    this.serviceName = '',
    this.serviceId = 0,
  }) : super(key: key);

  @override
  State<ShopListScreen> createState() => _ShopListScreenState();
}

class _ShopListScreenState extends State<ShopListScreen> {
  TextEditingController searchController = TextEditingController();
  List<ShopModel> shops = [];
  List<ShopModel> selectedShops = [];
  List<int> selectedShopIds = [];

  Future<List<ShopModel>>? future;

  int page = 1;
  bool changeListType = false;
  bool isLastPage = false;
  int? selectedShopId;
  String? selectedShopName;

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> init() async {
    if (widget.selectedShops.isNotEmpty) {
      selectedShops = List.from(widget.selectedShops.validate());
      selectedShopIds = selectedShops.map((e) => e.id).toList();
    }
    getShops(showLoader: false);
  }

  Future<void> getShops({bool showLoader = true}) async {
    if (DEMO_MODE_ENABLED) {
      // Use demo data
      shops = demoShopList;
      future = Future.value(shops);
      setState(() {});
      return;
    }

    appStore.setLoading(showLoader);
    future = getShopList(
      page,
      search: searchController.text.validate(),
      perPage: 10,
      shopList: shops,
      serviceIds: widget.serviceId > 0
          ? widget.serviceId.toString()
          : filterStore.serviceId.join(","),
      lastPageCallBack: (b) {
        isLastPage = b;
      },
    ).whenComplete(
      () => appStore.setLoading(false),
    );
    setState(() {});
  }

  Future<void> setPageToOne() async {
    setState(() {
      page = 1;
    });
    await getShops();
  }

  Future<void> onNextPage() async {
    if (!isLastPage) {
      setState(() {
        page++;
      });
      await getShops();
    }
  }

  String getScreenTitle() {
    if (widget.selectedShops.isNotEmpty) return languages.lblSelectShops;
    if (widget.serviceName.isNotEmpty)
      return languages.lblShopsOffer(widget.serviceName);
    return languages.lblAllShop;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.primary,
        leading: BackWidget(color: context.onPrimary),
        title: Text(
          getScreenTitle(),
          style: context.boldTextStyle(color: context.onPrimary, size: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await AddEditShopScreen()
                  .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
              if (result == true) setPageToOne();
            },
            icon: Icon(Icons.add, size: 28, color: context.onPrimary),
            tooltip: languages.addNewShop,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search Field
              Container(
                margin:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                child: AppTextField(
                  textFieldType: TextFieldType.OTHER,
                  controller: searchController,
                  onChanged: (value) {
                    setPageToOne();
                  },
                  decoration: inputDecoration(
                    context,
                    hintText: languages.lblSearchHere,
                    fillColor: context.profileInputFillColor,
                    borderRadius: 8,
                    prefixIcon:
                        Icon(Icons.search, color: context.iconMuted, size: 20)
                            .paddingAll(14),
                  ).copyWith(
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: context.iconMuted, size: 20),
                            onPressed: () {
                              searchController.clear();
                              setPageToOne();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              SnapHelperWidget<List<ShopModel>>(
                future: future,
                errorBuilder: (error) {
                  return Center(
                    child: NoDataWidget(
                      title: error,
                      imageWidget: ErrorStateWidget(),
                      retryText: languages.reload,
                      onRetry: () {
                        setPageToOne();
                      },
                    ),
                  );
                },
                loadingWidget: ShopListShimmer(),
                onSuccess: (list) {
                  if (list.isEmpty) {
                    return NoDataWidget(
                      title: languages.shopNotFound,
                      subTitle: languages.lblNoShopsFound,
                      imageWidget: EmptyStateWidget(),
                      onRetry: () {
                        getShops();
                      },
                    ).center().paddingOnly(bottom: 100);
                  }

                  return AnimatedListView(
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 16, bottom: 80),
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: 1,
                    onSwipeRefresh: () async {
                      setPageToOne();
                      return await 2.seconds.delay;
                    },
                    onNextPage: onNextPage,
                    itemBuilder: (context, index) {
                      if (shops.isNotEmpty)
                        return AnimatedWrap(
                          spacing: 16.0,
                          runSpacing: 16.0,
                          scaleConfiguration: ScaleConfiguration(
                              duration: 400.milliseconds,
                              delay: 50.milliseconds),
                          listAnimationType: ListAnimationType.FadeIn,
                          fadeInConfiguration:
                              FadeInConfiguration(duration: 2.seconds),
                          alignment: WrapAlignment.start,
                          itemCount: shops.length,
                          itemBuilder: (context, index) {
                            final shop = shops[index];

                            return Container(
                              decoration: BoxDecoration(
                                color: context.cardSecondary,
                                borderRadius: radius(12),
                                border: Border.all(
                                  color: selectedShopId == shop.id
                                      ? context.primary
                                      : context.cardSecondaryBorder,
                                  width: 1,
                                ),
                              ),
                              child: ShopComponent(
                                shop: shop,
                                imageSize: changeListType ? 80 : 56,
                                onRefreshCall: () {
                                  setPageToOne();
                                },
                              ),
                            ).onTap(
                              () async {
                                if (widget.fromShopDocument) {
                                  // ✅ Single selection
                                  setState(() {
                                    selectedShopId = shop.id;
                                    selectedShopName = shop.name;
                                  });
                                } else if (widget.fromServiceDetail) {
                                  // ✅ Multi selection toggle
                                  setState(() {
                                    if (selectedShopIds.contains(shop.id)) {
                                      selectedShopIds.remove(shop.id);
                                      selectedShops
                                          .removeWhere((s) => s.id == shop.id);
                                    } else {
                                      selectedShopIds.add(shop.id);
                                      selectedShops.add(shop);
                                    }
                                  });
                                } else {
                                  // Normal flow → open details
                                  ShopDetailScreen(shopId: shop.id)
                                      .launch(context);
                                }
                              },
                              borderRadius: radius(),
                            );
                          },
                        );
                      return Offstage();
                    },
                  );
                },
              ).expand(),
              if (widget.fromShopDocument && selectedShopId != null)
                AppButton(
                  margin: EdgeInsets.only(bottom: 12),
                  width: context.width() - context.navigationBarHeight,
                  text: languages.select,
                  color: context.primary,
                  textStyle: boldTextStyle(color: context.onPrimary),
                  onTap: () {
                    final selectedShop =
                        shops.firstWhere((e) => e.id == selectedShopId);
                    finish(context, selectedShop); // return single shop
                  },
                ).paddingOnly(left: 16.0, right: 16.0)
              else if (widget.fromServiceDetail && selectedShopIds.isNotEmpty)
                AppButton(
                  margin: EdgeInsets.only(bottom: 12),
                  width: context.width() - context.navigationBarHeight,
                  text: languages.lblSelectShops,
                  color: context.primary,
                  textStyle: boldTextStyle(color: context.onPrimary),
                  onTap: () {
                    finish(context, selectedShops); // return multiple shops
                  },
                ).paddingOnly(left: 16.0, right: 16.0),
            ],
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
