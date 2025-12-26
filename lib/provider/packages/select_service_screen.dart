import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/empty_error_state_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/package_response.dart';
import 'package:handyman_provider_flutter/models/service_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/packages/components/selected_service_component.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/context_ext.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../models/caregory_response.dart';

class SelectServiceScreen extends StatefulWidget {
  final int? categoryId;
  final int? subCategoryId;
  final bool isUpdate;
  final PackageData? packageData;
  final String? languageCode;

  SelectServiceScreen(
      {this.categoryId,
      this.subCategoryId,
      this.isUpdate = false,
      this.packageData,
      this.languageCode});

  @override
  _SelectServiceScreenState createState() => _SelectServiceScreenState();
}

class _SelectServiceScreenState extends State<SelectServiceScreen> {
  ScrollController scrollController = ScrollController();

  TextEditingController searchCont = TextEditingController();

  List<ServiceData> serviceList = [];
  List<CategoryData> categoryList = [];
  List<CategoryData> subCategoryList = [];

  CategoryData? selectedCategory;
  CategoryData? selectedSubCategory;

  int page = 1;
  int? categoryId = -1;
  int? subCategoryId = -1;

  bool isApiCalled = false;
  bool isLastPage = false;
  bool? isPackageTypeSingle;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (widget.isUpdate) {
      categoryId = widget.categoryId ?? -1;
      subCategoryId = widget.subCategoryId ?? -1;
      if (widget.packageData != null) {
        isPackageTypeSingle =
            widget.packageData!.packageType.validate() == PACKAGE_TYPE_SINGLE
                ? true
                : false;
      }
    } else {
      appStore.selectedServiceList.clear();
      isPackageTypeSingle = appStore.isCategoryWisePackageService;
    }

    getCategory();
  }

  //region Get Services List
  Future<void> fetchAllServices(
      {String? searchText = "",
      int? categoryId = -1,
      int? subCategoryId = -1}) async {
    appStore.setLoading(true);
    await getServicesList(page,
            search: searchText,
            categoryId: categoryId,
            subCategoryId: subCategoryId,
            providerId: appStore.userId,
            type: SERVICE_TYPE_FIXED,
            languageCode: widget.languageCode.validate())
        .then((value) {
      isApiCalled = true;

      if (page == 1) serviceList.clear();

      isLastPage = value.data!.length != PER_PAGE_ITEM;

      serviceList.addAll(value.data!);

      if (appStore.selectedServiceList.validate().isNotEmpty) {
        appStore.selectedServiceList.validate().forEach((e1) {
          serviceList.forEach((e2) {
            if (e2.id == e1.id) {
              e2.isSelected = true;
            }
          });
        });
      }

      appStore.setLoading(false);

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      isApiCalled = false;

      toast(e.toString());
    });
  }

  //endregion

  // region Get Category List
  Future<void> getCategory() async {
    appStore.setLoading(true);

    await getCategoryList(
            perPage: CATEGORY_TYPE_ALL,
            languageCode: widget.languageCode.validate())
        .then((value) async {
      categoryList = value.data.validate();
      if (widget.isUpdate && categoryId != -1)
        selectedCategory = value.data!
            .firstWhere((element) => element.id == widget.categoryId);

      if (selectedCategory != null) {
        selectedCategory = value.data!
            .firstWhere((element) => element.id == widget.categoryId);
        categoryId = selectedCategory!.id.validate();

        if (categoryId != -1) {
          await getSubCategory(categoryId: categoryId.validate());
        } else {
          await fetchAllServices(categoryId: categoryId, searchText: '');
        }
      } else {
        await fetchAllServices(categoryId: categoryId, searchText: '');
      }

      if (!widget.isUpdate) setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
  }

  //endregion

  // region Get Sub Category List
  Future<void> getSubCategory({required int categoryId}) async {
    getSubCategoryList(
            catId: categoryId.toInt(),
            languageCode: widget.languageCode.validate())
        .then((value) async {
      subCategoryList = value.data.validate();
      CategoryData allValue = CategoryData(id: -1, name: 'All');
      subCategoryList.insert(0, allValue);

      if (widget.isUpdate) {
        if (subCategoryId != -1) {
          selectedSubCategory =
              value.data!.firstWhere((element) => element.id == subCategoryId);
        }
      } else {
        selectedSubCategory = subCategoryList.first;
      }

      if (subCategoryId != -1) {
        selectedSubCategory =
            value.data!.firstWhere((element) => element.id == subCategoryId);
        await fetchAllServices(
            categoryId: categoryId.validate(),
            subCategoryId: selectedSubCategory!.id.validate(),
            searchText: '');
      } else {
        selectedSubCategory = subCategoryList.first;
        subCategoryId = selectedSubCategory!.id.validate();
        await fetchAllServices(
            categoryId: categoryId.validate(),
            subCategoryId: subCategoryId,
            searchText: '');
      }

      setState(() {});
    }).catchError((e) {
      log(e.toString());
    });
  }

  // endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: appBarWidget(
        languages.selectService,
        textColor: context.onPrimary,
        color: context.primary,
      ),
      body: Stack(
        children: [
          AnimatedScrollView(
            controller: scrollController,
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            crossAxisAlignment: CrossAxisAlignment.start,
            physics: const AlwaysScrollableScrollPhysics(),
            onNextPage: () {
              if (!isLastPage) {
                page++;
                fetchAllServices();
                setState(() {});
              }
            },
            children: [
              24.height,

              // Category Based Package Toggle
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: boxDecorationDefault(
                  color: context.cardSecondary,
                  borderRadius: radius(12),
                  border: Border.all(color: context.cardSecondaryBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${languages.categoryBasedPackage} ${appStore.isCategoryWisePackageService ? languages.enabled : languages.disabled}',
                          style: context.boldTextStyle(),
                        ),
                        4.height,
                        Text(
                          languages.subTitleOfSelectService,
                          style: context.secondaryTextStyle(size: 12),
                        ),
                      ],
                    ).expand(),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch.adaptive(
                        value: isPackageTypeSingle.validate(),
                        // ignore: deprecated_member_use
                        activeColor: context.primary,
                        activeTrackColor:
                            context.primary.withValues(alpha: 0.3),
                        inactiveThumbColor: context.iconMuted,
                        inactiveTrackColor:
                            context.iconMuted.withValues(alpha: 0.3),
                        onChanged: (v) {
                          showConfirmDialogCustom(
                            context,
                            dialogType: DialogType.CONFIRMATION,
                            primaryColor: context.primary,
                            backgroundColor: context.dialogBackgroundColor,
                            titleColor: context.dialogTitleColor,
                            title:
                                '${languages.doYouWantTo} ${!appStore.isCategoryWisePackageService ? languages.enable : languages.disable} ${languages.categoryBasedPackage}?',
                            positiveText: context.translate.lblYes,
                            positiveTextColor: context.onPrimary,
                            negativeText: context.translate.lblNo,
                            negativeTextColor: context.primary,
                            onAccept: (p0) {
                              if (appStore.isCategoryWisePackageService) {
                                appStore.selectedServiceList.clear();
                                appStore.setLoading(true);
                                searchCont.text = '';

                                fetchAllServices(categoryId: -1);
                              } else {
                                appStore.selectedServiceList.clear();
                                categoryId = -1;
                                searchCont.text = '';

                                appStore.setLoading(true);

                                fetchAllServices(categoryId: categoryId);
                                serviceList.clear();
                              }
                              isPackageTypeSingle = v;
                              appStore.setCategoryBasedPackageService(
                                  isPackageTypeSingle.validate());
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              24.height,

              // Category and subCategory Dropdown
              if (isPackageTypeSingle.validate())
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: boxDecorationDefault(
                    color: context.cardSecondary,
                    borderRadius: radius(12),
                    border: Border.all(color: context.cardSecondaryBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Label
                      Text(languages.hintSelectCategory,
                          style: context.boldTextStyle()),
                      8.height,
                      DropdownButtonFormField<CategoryData>(
                        decoration: inputDecoration(
                          context,
                          fillColor: context.profileInputFillColor,
                          hintText: languages.hintSelectCategory,
                        ),
                        initialValue: selectedCategory,
                        dropdownColor: context.cardSecondary,
                        items: categoryList.map((data) {
                          return DropdownMenuItem<CategoryData>(
                            value: data,
                            child: Text(
                              data.name.validate(),
                              style: context.primaryTextStyle(),
                            ),
                          );
                        }).toList(),
                        onChanged: (CategoryData? value) async {
                          selectedCategory = value!;
                          categoryId = value.id;

                          serviceList.clear();
                          subCategoryList.clear();
                          appStore.selectedServiceList.clear();
                          subCategoryId = -1;

                          appStore.setLoading(true);
                          getSubCategory(categoryId: categoryId.validate());
                        },
                      ),

                      16.height,

                      // Sub Category Label
                      Text(languages.lblSelectSubCategory,
                          style: context.boldTextStyle()),
                      8.height,
                      DropdownButtonFormField<CategoryData>(
                        decoration: inputDecoration(
                          context,
                          fillColor: context.profileInputFillColor,
                          hintText: languages.lblSelectSubCategory,
                        ),
                        initialValue: selectedSubCategory,
                        dropdownColor: context.cardSecondary,
                        items: subCategoryList.map((data) {
                          return DropdownMenuItem<CategoryData>(
                            value: data,
                            child: Text(
                              data.name.validate(),
                              style: context.primaryTextStyle(),
                            ),
                          );
                        }).toList(),
                        onChanged: (CategoryData? value) async {
                          selectedSubCategory = value!;
                          subCategoryId = value.id;

                          if (selectedSubCategory != null) {
                            appStore.setLoading(true);
                            fetchAllServices(
                                categoryId: categoryId.validate(),
                                subCategoryId: subCategoryId,
                                searchText: '');
                          }
                        },
                      ),
                    ],
                  ),
                ),

              // Search Service TextField
              if (!isPackageTypeSingle.validate())
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(languages.lblSearchHere,
                          style: context.boldTextStyle()),
                      8.height,
                      AppTextField(
                        controller: searchCont,
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(
                          context,
                          hintText: languages.lblSearchHere,
                          fillColor: context.profileInputFillColor,
                        ),
                        onFieldSubmitted: (s) {
                          appStore.setLoading(true);
                          fetchAllServices(searchText: s);
                        },
                      ),
                    ],
                  ),
                ),

              // Selected Service Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text(
                    languages.includedInThisPackage,
                    style: context.boldTextStyle(),
                  ).paddingSymmetric(horizontal: 16),
                  16.height,
                  if (!appStore.isLoading &&
                      appStore.selectedServiceList.isNotEmpty)
                    SelectedServiceComponent(
                      onItemRemove: (data) {
                        int index = serviceList.indexOf(serviceList
                            .firstWhere((element) => element.id == data.id));
                        serviceList[index].isSelected = false;
                        setState(() {});
                      },
                    )
                  else
                    Container(
                      height: 120,
                      width: context.width(),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: boxDecorationDefault(
                        borderRadius: radius(12),
                        color: context.cardSecondary,
                        border: Border.all(color: context.cardSecondaryBorder),
                      ),
                      child: Text(
                        languages.packageServicesWillAppearHere,
                        style: context.secondaryTextStyle(),
                      ).center(),
                    ),
                  16.height,
                ],
              ),

              if (appStore.selectedServiceList.isEmpty) 16.height,

              // Service List Section
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languages.lblServices,
                      style: context.boldTextStyle(),
                    ),
                    4.height,
                    Text(
                      languages.showingFixPriceServices,
                      style: context.secondaryTextStyle(size: 12),
                    ),
                  ],
                ),
              ),

              if ((serviceList.isNotEmpty) &&
                  (categoryId != -1 || !isPackageTypeSingle.validate()))
                AnimatedListView(
                  itemCount: serviceList.length,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 8, bottom: 70),
                  disposeScrollController: false,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (_, i) {
                    ServiceData data = serviceList[i];
                    bool isSelected = data.isSelected.validate();

                    return Container(
                      width: context.width(),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: boxDecorationDefault(
                        borderRadius: radius(12),
                        color: context.cardSecondary,
                        border: Border.all(
                          color: isSelected
                              ? context.primaryLiteColor
                              : context.cardSecondaryBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: radius(10),
                                child: CachedImageWidget(
                                  url: data.imageAttachments!.isNotEmpty
                                      ? data.imageAttachments!.first.validate()
                                      : "",
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              16.width,
                              Text(
                                data.name.validate(),
                                style: context.primaryTextStyle(),
                              ).expand(),
                            ],
                          ).expand(),
                          16.width,
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? context.primaryLiteColor
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? context.primaryLiteColor
                                    : context.iconMuted,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 18,
                              color: isSelected
                                  ? context.onPrimary
                                  : Colors.transparent,
                            ),
                          ),
                          8.width,
                        ],
                      ).onTap(
                        () {
                          if (data.isSelected.validate()) {
                            appStore.removeSelectedPackageService(data);
                          } else {
                            appStore.addSelectedPackageService(data);
                          }
                          data.isSelected = !data.isSelected.validate();

                          setState(() {});
                        },
                        highlightColor: context.primary.withValues(alpha: 0.1),
                        splashColor: context.primary.withValues(alpha: 0.1),
                      ),
                    );
                  },
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      fetchAllServices();
                      setState(() {});
                    }
                  },
                )
              else
                Observer(
                  builder: (context) {
                    return NoDataWidget(
                      imageWidget: const EmptyStateWidget(),
                      title: context.translate.noServiceFound,
                      imageSize: const Size(150, 150),
                      subTitle: "",
                    ).visible((!appStore.isLoading && serviceList.isEmpty));
                  },
                ),

              16.height,

              Observer(builder: (context) {
                return NoDataWidget(
                  imageWidget: const EmptyStateWidget(),
                  title: languages.pleaseSelectTheCategory,
                  imageSize: const Size(150, 150),
                  subTitle: "",
                ).center().visible(!appStore.isLoading &&
                    categoryId == -1 &&
                    isPackageTypeSingle.validate());
              }),
            ],
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: context.primary,
        onPressed: () {
          Map res = {
            "categoryId": categoryId,
            "subCategoryId": subCategoryId,
            "packageType": isPackageTypeSingle!
                ? PACKAGE_TYPE_SINGLE
                : PACKAGE_TYPE_MULTIPLE,
          };
          finish(context, res);
        },
        child: Icon(Icons.check, color: context.onPrimary),
      ),
    );
  }
}
