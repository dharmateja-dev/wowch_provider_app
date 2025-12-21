import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/provider/shimmer/handyman_commission_list_shimmer.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/empty_error_state_widget.dart';
import '../components/base_scaffold_widget.dart';
import '../main.dart';
import '../models/user_type_response.dart';
import '../networks/rest_apis.dart';
import '../utils/common.dart';
import 'add_handyman_commission_screen.dart';

/// Demo handyman commission data for UI testing
UserTypeResponse get demoHandymanCommissionData => UserTypeResponse(
      userTypeData: [
        UserTypeData(
          id: 1,
          name: 'Freelance',
          commission: 5.00,
          type: COMMISSION_TYPE_FIXED,
          status: 1,
          createdBy: 0, // Not created by current user (admin created)
        ),
        UserTypeData(
          id: 2,
          name: 'Company',
          commission: 60,
          type: COMMISSION_TYPE_PERCENT,
          status: 1,
          createdBy: 0, // Not created by current user (admin created)
        ),
      ],
    );

class HandymanCommissionTypeListScreen extends StatefulWidget {
  const HandymanCommissionTypeListScreen({super.key});

  @override
  _HandymanCommissionTypeListScreenState createState() =>
      _HandymanCommissionTypeListScreenState();
}

class _HandymanCommissionTypeListScreenState
    extends State<HandymanCommissionTypeListScreen> {
  Future<UserTypeResponse>? future;

  int page = 1;

  bool isLastPage = false;

  bool isSwitched = false;

  Future<void> changeStatus(UserTypeData typeDataModel, int status) async {
    appStore.setLoading(true);
    Map request = {
      CommonKeys.id: typeDataModel.id,
      UserKeys.status: status,
      "name": typeDataModel.name,
      "commission": typeDataModel.commission,
      "type": typeDataModel.type,
    };

    await saveProviderHandymanTypeList(request: request).then((value) {
      appStore.setLoading(false);
      toast(value.message.toString(), print: true);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
      if (typeDataModel.status.validate() == 1) {
        typeDataModel.status = 0;
      } else {
        typeDataModel.status = 1;
      }
      setState(() {});
    });
  }

  /// Delete Provider & Handyman Type List
  Future<void> removeProviderHandymanTypeList(int? id) async {
    appStore.setLoading(true);
    await deleteProviderHandymanTypeList(id.validate()).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      init();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// Restore Provider & Handyman  Type List
  Future<void> restoreProviderHandymanTypeList(
      {required int commissionId}) async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: commissionId,
      "type": RESTORE,
    };

    await restoreProviderHandymanType(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      init();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// ForceFully Delete Provider & Handyman Type List
  Future<void> forceDeleteProviderHandymanTypeList(
      {required int commissionId}) async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: commissionId,
      "type": FORCE_DELETE,
    };

    await restoreProviderHandymanType(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      init();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (DEMO_MODE_ENABLED) {
      future = Future.value(demoHandymanCommissionData);
    } else {
      future = getCommissionType(
          type: USER_TYPE_HANDYMAN,
          providerId: appStore.userId,
          isDelete: true);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldBackgroundColor: context.scaffoldSecondary,
      appBarTitle: languages.handymanCommission,
      actions: [
        IconButton(
          icon: Icon(Icons.add, color: context.onPrimary),
          onPressed: () async {
            bool? res =
                await AddHandymanCommissionTypeListScreen().launch(context);
            if (res ?? false) {
              page = 1;
              init();
              setState(() {});
            }
          },
        ).visible(appStore.isLoggedIn &&
            rolesAndPermissionStore.handymanTypeList &&
            rolesAndPermissionStore.handymanTypeAdd),
      ],
      body: SnapHelperWidget<UserTypeResponse>(
        future: future,
        loadingWidget: HandymanCommissionListShimmer(),
        onSuccess: (data) {
          return AnimatedListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
            itemCount: data.userTypeData?.length,
            itemBuilder: (_, index) {
              UserTypeData typeData = data.userTypeData![index];
              bool isProvider = typeData.createdBy == appStore.userId;
              return Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: context.width(),
                decoration: BoxDecoration(
                    border: Border.all(color: context.cardSecondaryBorder),
                    borderRadius: radius(),
                    color: context.cardSecondary),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset(ic_profile,
                            height: 18, color: context.primary),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(languages.handymanCommission,
                                style: context.boldTextStyle(size: 12)),
                            4.height,
                            Text(
                              typeData.name.validate(),
                              style: context.primaryTextStyle(),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isProvider &&
                            (rolesAndPermissionStore.handymanTypeEdit ||
                                rolesAndPermissionStore.handymanTypeDelete))
                          PopupMenuButton(
                            icon: Icon(Icons.more_vert,
                                size: 24, color: context.icon),
                            color: context.cardSecondary,
                            onSelected: (selection) async {
                              if (selection == 1) {
                                bool? res =
                                    await AddHandymanCommissionTypeListScreen(
                                            typeData: typeData)
                                        .launch(context);
                                if (res ?? false) {
                                  page = 1;
                                  init();
                                  setState(() {});
                                }
                              }
                              if (selection == 2) {
                                showConfirmDialogCustom(
                                  context,
                                  height: 80,
                                  width: 290,
                                  shape: appDialogShape(8),
                                  dialogType: DialogType.DELETE,
                                  title: languages.lblDoYouWantToDelete,
                                  titleColor: context.dialogTitleColor,
                                  backgroundColor:
                                      context.dialogBackgroundColor,
                                  positiveText: languages.lblDelete,
                                  positiveTextColor: context.onPrimary,
                                  negativeText: languages.lblCancel,
                                  negativeTextColor: context.dialogCancelColor,
                                  primaryColor: Colors.redAccent,
                                  customCenterWidget: Image.asset(
                                    ic_delete,
                                    color: Colors.redAccent,
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  onAccept: (_) {
                                    ifNotTester(context, () {
                                      removeProviderHandymanTypeList(
                                          typeData.id.validate());
                                    });
                                  },
                                );
                              } else if (selection == 3) {
                                showConfirmDialogCustom(
                                  context,
                                  height: 80,
                                  width: 290,
                                  shape: appDialogShape(8),
                                  dialogType: DialogType.ACCEPT,
                                  title: languages.lblDoYouWantToRestore,
                                  titleColor: context.dialogTitleColor,
                                  backgroundColor:
                                      context.dialogBackgroundColor,
                                  positiveText: languages.accept,
                                  positiveTextColor: context.onPrimary,
                                  negativeText: languages.lblCancel,
                                  negativeTextColor: context.dialogCancelColor,
                                  primaryColor: context.primary,
                                  customCenterWidget: Icon(
                                    Icons.restore,
                                    color: context.primary,
                                    size: 50,
                                  ),
                                  onAccept: (_) {
                                    ifNotTester(context, () {
                                      restoreProviderHandymanTypeList(
                                          commissionId: typeData.id.validate());
                                    });
                                  },
                                );
                              } else if (selection == 4) {
                                showConfirmDialogCustom(
                                  context,
                                  height: 80,
                                  width: 290,
                                  shape: appDialogShape(8),
                                  dialogType: DialogType.DELETE,
                                  title:
                                      languages.lblDoYouWantToDeleteForcefully,
                                  titleColor: context.dialogTitleColor,
                                  backgroundColor:
                                      context.dialogBackgroundColor,
                                  positiveText: languages.lblDelete,
                                  positiveTextColor: context.onPrimary,
                                  negativeText: languages.lblCancel,
                                  negativeTextColor: context.dialogCancelColor,
                                  primaryColor: Colors.redAccent,
                                  customCenterWidget: Image.asset(
                                    ic_delete,
                                    color: Colors.redAccent,
                                    height: 70,
                                    width: 70,
                                    fit: BoxFit.cover,
                                  ),
                                  onAccept: (_) {
                                    ifNotTester(context, () {
                                      forceDeleteProviderHandymanTypeList(
                                          commissionId: typeData.id.validate());
                                    });
                                  },
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              if (rolesAndPermissionStore.handymanTypeEdit)
                                PopupMenuItem(
                                  child: Text(languages.lblEdit,
                                      style: context.boldTextStyle(
                                          color: typeData.deletedAt == null
                                              ? textPrimaryColorGlobal
                                              : textSecondaryColor)),
                                  value: 1,
                                  enabled: typeData.deletedAt == null,
                                ),
                              if (rolesAndPermissionStore.handymanTypeDelete)
                                PopupMenuItem(
                                  child: Text(languages.lblDelete,
                                      style: boldTextStyle(
                                          color: typeData.deletedAt == null
                                              ? textPrimaryColorGlobal
                                              : textSecondaryColor)),
                                  value: 2,
                                  enabled: typeData.deletedAt == null,
                                ),
                              PopupMenuItem(
                                child: Text(languages.lblRestore,
                                    style: boldTextStyle(
                                        color: typeData.deletedAt != null
                                            ? textPrimaryColorGlobal
                                            : textSecondaryColor)),
                                value: 3,
                                enabled: typeData.deletedAt != null,
                              ),
                              if (rolesAndPermissionStore.handymanTypeDelete)
                                PopupMenuItem(
                                  child: Text(languages.lblForceDelete,
                                      style: boldTextStyle(
                                          color: typeData.deletedAt != null
                                              ? textPrimaryColorGlobal
                                              : textSecondaryColor)),
                                  value: 4,
                                  enabled: typeData.deletedAt != null,
                                ),
                            ],
                          ),
                      ],
                    ),
                    Divider(
                        color: context.cardSecondaryBorder,
                        thickness: 1.0,
                        height: 16),
                    Row(
                      children: [
                        Image.asset(percent_line,
                            height: 18, color: context.primary),
                        16.width,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(languages.commission,
                                style: context.boldTextStyle(size: 12)),
                            4.height,
                            if (typeData.type.validate().toLowerCase() ==
                                COMMISSION_TYPE_PERCENT.toLowerCase())
                              Text(
                                '${typeData.commission}%',
                                style: context.primaryTextStyle(size: 12),
                              ),
                            if (typeData.type.validate().toLowerCase() ==
                                COMMISSION_TYPE_FIXED.toLowerCase())
                              Text(
                                  typeData.commission
                                      .validate()
                                      .toPriceFormat(),
                                  style: context.primaryTextStyle(size: 12)),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                        color: context.cardSecondaryBorder,
                        thickness: 1.0,
                        height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(ic_status,
                                height: 16, color: context.primary),
                            16.width,
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(languages.lblStatus,
                                    style: context.boldTextStyle(size: 12)),
                                4.height,
                                Text(
                                  typeData.status == 1
                                      ? ACTIVE.toUpperCase()
                                      : INACTIVE.toUpperCase(),
                                  style: boldTextStyle(
                                      size: 12,
                                      color: typeData.status == 1
                                          ? context.primary
                                          : Colors.redAccent),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isProvider && typeData.deletedAt == null)
                          Transform.scale(
                            scale: 0.8,
                            child: Switch.adaptive(
                              value: typeData.status == 1,
                              activeThumbColor: context.primary,
                              activeTrackColor:
                                  context.primary.withOpacity(0.4),
                              onChanged: (_) {
                                ifNotTester(context, () {
                                  if (typeData.status.validate() == 1) {
                                    typeData.status = 0;
                                    changeStatus(typeData, 0);
                                  } else {
                                    typeData.status = 1;
                                    changeStatus(typeData, 1);
                                  }
                                });
                                setState(() {});
                              },
                            ).withHeight(24),
                          ),
                      ],
                    ),
                    if (!isProvider) noteWidget(),
                  ],
                ),
              );
            },
            emptyWidget: NoDataWidget(
              title: languages.noCommissionTypeListFound,
              imageWidget: const EmptyStateWidget(),
            ),
            onSwipeRefresh: () async {
              page = 1;

              init();
              setState(() {});

              return 2.seconds.delay;
            },
            onNextPage: () {
              if (!isLastPage) {
                page = page++;
                init();
                setState(() {});
              }
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
    );
  }

  Widget noteWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: context.cardSecondaryBorder, thickness: 1.0, height: 16),
        6.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(languages.notes, style: context.primaryTextStyle(size: 12)),
            2.width,
            Text(
              languages.thisCommissionHasBeen,
              style: context.primaryTextStyle(size: 12),
              maxLines: 2,
            ).expand(),
          ],
        ),
      ],
    );
  }
}
