import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/price_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/package_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/packages/add_package_screen.dart';
import 'package:handyman_provider_flutter/provider/packages/package_detail_screen.dart';
import 'package:handyman_provider_flutter/provider/packages/shimmer/package_list_shimmer.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';

class PackageListScreen extends StatefulWidget {
  @override
  _PackageListScreenState createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  Future<List<PackageData>>? future;
  List<PackageData> packageList = [];

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
    future = getAllPackageList(
      packageData: packageList,
      page: page,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    );
  }

  // region Delete Package
  void removePackage({int? packageId}) {
    deletePackage(packageId.validate()).then((value) async {
      toast(value.message.validate());
      init();

      setState(() {});
      await 2.seconds.delay;
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  Future<void> confirmationDialog({required PackageData packageData}) async {
    showConfirmDialogCustom(
      context,
      title:
          '${languages.areYouSureWantToDeleteThe} ${packageData.name.validate()} ${languages.package}?',
      dialogType: DialogType.DELETE,
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
          removePackage(packageId: packageData.id.validate());
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
      appBarTitle: languages.packages,
      actions: [
        IconButton(
          icon: Icon(Icons.add, size: 28, color: context.onPrimary),
          onPressed: () async {
            bool? res = await AddPackageScreen().launch(context);

            if (res ?? false) {
              appStore.setLoading(true);
              init();

              setState(() {});
            }
          },
        ).visible(appStore.isLoggedIn &&
            rolesAndPermissionStore.servicePackageList &&
            rolesAndPermissionStore.servicePackageAdd),
      ],
      body: Stack(
        children: [
          SnapHelperWidget<List<PackageData>>(
            future: future,
            loadingWidget: PackageListShimmer(),
            onSuccess: (snap) {
              return AnimatedListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                shrinkWrap: true,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemCount: snap.length,
                emptyWidget: NoDataWidget(
                  title: languages.packageNotAvailable,
                  imageWidget: const EmptyStateWidget(),
                ),
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
                  PackageData data = snap[index];

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
                        // Package Image and Info
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Package Image
                              ClipRRect(
                                borderRadius: radius(10),
                                child: CachedImageWidget(
                                  url: data.imageAttachments
                                          .validate()
                                          .isNotEmpty
                                      ? data.imageAttachments!.first.validate()
                                      : '',
                                  height: 80,
                                  width: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              16.width,

                              // Package Details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Package Name
                                  Marquee(
                                    child: Text(
                                      data.name.validate(),
                                      style: context.boldTextStyle(size: 15),
                                    ),
                                  ),

                                  // Description
                                  if (data.description
                                      .validate()
                                      .isNotEmpty) ...[
                                    4.height,
                                    Text(
                                      data.description.validate(),
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
                              if (rolesAndPermissionStore.servicePackageEdit ||
                                  rolesAndPermissionStore.servicePackageDelete)
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
                                      bool? res =
                                          await AddPackageScreen(data: data)
                                              .launch(context);

                                      if (res ?? false) {
                                        appStore.setLoading(true);
                                        init();

                                        setState(() {});
                                      }
                                    } else if (selection == 2) {
                                      confirmationDialog(packageData: data);
                                    }
                                  },
                                  itemBuilder: (context) {
                                    List<PopupMenuEntry<int>> menuItems = [];
                                    if (rolesAndPermissionStore
                                        .servicePackageEdit) {
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
                                        .servicePackageDelete) {
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
                    () {
                      PackageDetailScreen(packageData: data).launch(context);
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
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
