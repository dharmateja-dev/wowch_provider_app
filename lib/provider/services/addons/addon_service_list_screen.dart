import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/provider/services/addons/shimmer/addon_service_list_shimmer.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_widgets.dart';
import '../../../components/cached_image_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../components/price_widget.dart';
import '../../../main.dart';
import '../../../models/booking_detail_response.dart';
import '../../../networks/rest_apis.dart';
import '../../../utils/common.dart';
import 'add_addon_service_screen.dart';

class AddonServiceListScreen extends StatefulWidget {
  @override
  _AddonServiceListScreenState createState() => _AddonServiceListScreenState();
}

class _AddonServiceListScreenState extends State<AddonServiceListScreen> {
  Future<List<ServiceAddon>>? future;
  List<ServiceAddon> addonServiceList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();

    afterBuildCreated(() {
      setStatusBarColor(context.primary);
    });
  }

  void init() async {
    future = getAddonsServiceList(
      addonServiceData: addonServiceList,
      page: page,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
  }

  // region Delete Addon Service
  void removeAddonService({int? addonId}) {
    deleteAddonService(addonId.validate()).then((value) async {
      toast(value.message.validate());
      init();

      setState(() {});
      await 2.seconds.delay;
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  Future<void> confirmationDialog({
    required ServiceAddon addonServiceData,
  }) async {
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.DELETE,
      title:
          '${languages.areYouSureWantToDeleteThe} ${addonServiceData.name.validate()} ${languages.addOns}?',
      height: 80,
      width: 290,
      shape: appDialogShape(8),
      backgroundColor: context.dialogBackgroundColor,
      titleColor: context.dialogTitleColor,
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
      negativeTextColor: context.primary,
      onAccept: (context) async {
        ifNotTester(context, () {
          appStore.setLoading(true);
          removeAddonService(addonId: addonServiceData.id.validate());
          setState(() {});
        });
      },
    );
  }

  // endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldBackgroundColor: context.scaffoldSecondary,
      appBarTitle: languages.addOns,
      actions: [
        IconButton(
          icon: Icon(Icons.add, size: 28, color: context.onPrimary),
          onPressed: () async {
            bool? res = await AddAddonServiceScreen().launch(context);

            if (res ?? false) {
              appStore.setLoading(true);
              init();

              setState(() {});
            }
          },
        ).visible(rolesAndPermissionStore.serviceAddOnAdd),
      ],
      body: Stack(
        children: [
          SnapHelperWidget<List<ServiceAddon>>(
            future: future,
            loadingWidget: AddonServiceListShimmer(),
            onSuccess: (snap) {
              return AnimatedListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemCount: snap.length,
                emptyWidget: NoDataWidget(
                  title: languages.oppsLooksLikeYou,
                  imageWidget: const EmptyStateWidget(),
                ).paddingSymmetric(horizontal: 16),
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                itemBuilder: (BuildContext context, index) {
                  ServiceAddon data = snap[index];

                  return Container(
                    width: context.width(),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: boxDecorationDefault(
                      borderRadius: radius(12),
                      color: context.cardSecondary,
                      border: Border.all(
                        color: context.cardSecondaryBorder,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Addon Image
                              ClipRRect(
                                borderRadius: radius(10),
                                child: CachedImageWidget(
                                  url: data.serviceAddonImage
                                          .validate()
                                          .isNotEmpty
                                      ? data.serviceAddonImage.validate()
                                      : '',
                                  height: 70,
                                  width: 70,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              16.width,

                              // Addon Details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Addon Name
                                  Marquee(
                                    child: Text(
                                      data.name
                                          .validate()
                                          .capitalizeFirstLetter(),
                                      style: context.boldTextStyle(size: 15),
                                    ),
                                  ),

                                  // Service Name (which service this addon belongs to)
                                  if (data.serviceName.isNotEmpty) ...[
                                    4.height,
                                    Text(
                                      data.serviceName.validate(),
                                      style:
                                          context.secondaryTextStyle(size: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],

                                  8.height,

                                  // Price
                                  PriceWidget(
                                    price: data.price.validate(),
                                    color: context.primaryLiteColor,
                                    size: 16,
                                    isBoldText: true,
                                  ),
                                ],
                              ).expand(),

                              // Popup Menu
                              if (rolesAndPermissionStore.serviceAddOnEdit ||
                                  rolesAndPermissionStore.serviceAddOnDelete)
                                PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    size: 22,
                                    color: context.iconMuted,
                                  ),
                                  color: context.cardSecondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: radius(8),
                                  ),
                                  padding: EdgeInsets.zero,
                                  onSelected: (selection) async {
                                    if (selection == 1) {
                                      bool? res = await AddAddonServiceScreen(
                                        addonServiceData: data,
                                      ).launch(context);

                                      if (res ?? false) {
                                        appStore.setLoading(true);
                                        init();

                                        setState(() {});
                                      }
                                    } else if (selection == 2) {
                                      confirmationDialog(
                                          addonServiceData: data);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    List<PopupMenuEntry<int>> menuItems = [];

                                    if (rolesAndPermissionStore
                                        .serviceAddOnEdit) {
                                      menuItems.add(
                                        PopupMenuItem(
                                          value: 1,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit_outlined,
                                                size: 18,
                                                color: context.primary,
                                              ),
                                              8.width,
                                              Text(
                                                languages.lblEdit,
                                                style:
                                                    context.primaryTextStyle(),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    if (rolesAndPermissionStore
                                        .serviceAddOnDelete) {
                                      menuItems.add(
                                        PopupMenuItem(
                                          value: 2,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete_outline,
                                                size: 18,
                                                color: context.error,
                                              ),
                                              8.width,
                                              Text(
                                                languages.lblDelete,
                                                style: context.primaryTextStyle(
                                                  color: context.error,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    return menuItems;
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).onTap(
                    () async {
                      if (rolesAndPermissionStore.serviceAddOnEdit) {
                        bool? res = await AddAddonServiceScreen(
                          addonServiceData: data,
                        ).launch(context);

                        if (res ?? false) {
                          appStore.setLoading(true);
                          init();

                          setState(() {});
                        }
                      }
                    },
                    highlightColor: context.primary.withValues(alpha: 0.1),
                    hoverColor: context.primary.withValues(alpha: 0.05),
                    splashColor: context.primary.withValues(alpha: 0.1),
                  );
                },
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: const ErrorStateWidget(),
                retryText: languages.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(
            builder: (context) => LoaderWidget().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}
