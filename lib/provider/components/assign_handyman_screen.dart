import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/handyman_name_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/base_scaffold_widget.dart';
import '../../components/empty_error_state_widget.dart';
import '../../components/handyman_add_update_screen.dart';
import '../../utils/constant.dart';
import '../../utils/context_extensions.dart';
import '../../utils/demo_data.dart';
import '../../utils/images.dart';

class AssignHandymanScreen extends StatefulWidget {
  final int? bookingId;
  final Function? onUpdate;
  final int? serviceAddressId;

  const AssignHandymanScreen(
      {Key? key,
      this.onUpdate,
      required this.bookingId,
      required this.serviceAddressId})
      : super(key: key);

  @override
  _AssignHandymanScreenState createState() => _AssignHandymanScreenState();
}

class _AssignHandymanScreenState extends State<AssignHandymanScreen> {
  ScrollController scrollController = ScrollController();

  Future<List<UserData>>? future;
  List<UserData> handymanList = [];

  int page = 1;
  bool isLastPage = false;

  UserData? userListData;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getAllHandyman(
      page: page,
      serviceAddressId: widget.serviceAddressId,
      userData: handymanList,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    ).catchError((e) {
      // Use demo data when API fails
      handymanList.clear();
      handymanList.addAll(demoHandymen);
      isLastPage = true;
      return demoHandymen;
    });
  }

  Future<void> _handleAssignHandyman() async {
    if (appStore.isLoading) return;

    showConfirmDialogCustom(
      context,
      height: 80,
      width: 290,
      shape: appDialogShape(8),
      title:
          '${languages.lblAreYouSureYouWantToAssignThisServiceTo(userListData!.firstName.validate())}',
      titleColor: context.dialogTitleColor,
      backgroundColor: context.dialogBackgroundColor,
      primaryColor: context.primary,
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
      negativeTextColor: context.dialogCancelColor,
      dialogType: DialogType.CONFIRMATION,
      onAccept: (c) async {
        var request = {
          CommonKeys.id: widget.bookingId,
          CommonKeys.handymanId: [userListData!.id.validate()],
        };

        appStore.setLoading(true);

        await assignBooking(request).then((res) async {
          appStore.setLoading(false);

          widget.onUpdate?.call();

          finish(context);

          toast(res.message);
        }).catchError((e) {
          appStore.setLoading(false);

          toast(e.toString());
        });
      },
    );
  }

  Future<void> _handleAssignToMyself() async {
    if (appStore.isLoading) return;

    showConfirmDialogCustom(
      context,
      height: 80,
      width: 290,
      shape: appDialogShape(8),
      title: languages.lblAreYouSureYouWantToAssignToYourself,
      titleColor: context.dialogTitleColor,
      backgroundColor: context.dialogBackgroundColor,
      primaryColor: context.primary,
      customCenterWidget: Image.asset(
        ic_warning,
        color: context.dialogIconColor,
        height: 70,
        width: 70,
        fit: BoxFit.cover,
      ),
      positiveText: languages.lblYes,
      positiveTextColor: context.onPrimary,
      negativeText: languages.lblCancel,
      negativeTextColor: context.dialogCancelColor,
      dialogType: DialogType.CONFIRMATION,
      onAccept: (c) async {
        var request = {
          CommonKeys.id: widget.bookingId,
          CommonKeys.handymanId: [appStore.userId.validate()],
        };

        appStore.setLoading(true);

        await assignBooking(request).then((res) async {
          appStore.setLoading(false);

          widget.onUpdate!.call();

          finish(context);

          toast(res.message);
        }).catchError((e) {
          appStore.setLoading(false);

          toast(e.toString());
        });
      },
    );
  }

  Widget buildHandymanItem({required UserData userData}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CachedImageWidget(
          url: userData.profileImage!.isNotEmpty
              ? userData.profileImage.validate()
              : "",
          height: 60,
          fit: BoxFit.cover,
          circle: true,
        ),
        16.width,
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Marquee(
              child: HandymanNameWidget(
                size: 14,
                name: userData.displayName.validate(),
                isHandymanAvailable: userData.isHandymanAvailable,
              ),
            ),
            if (userData.handymanType.validate().isNotEmpty) 4.height,
            if (userData.handymanType.validate().isNotEmpty)
              Row(
                children: [
                  Text(
                    "${userData.handymanType.validate()}",
                    style: context.primaryTextStyle(size: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.width,
                  Flexible(
                    child: Text(
                      "(${userData.handymanCommission.validate()} ${languages.commission})",
                      style: context.primaryTextStyle(size: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            4.height,
            if (userData.designation.validate().isNotEmpty)
              Text(
                "${userData.designation.validate()}",
                style: context.primaryTextStyle(size: 12),
                overflow: TextOverflow.ellipsis,
              )
            else
              Text(
                "${languages.lblMemberSince} ${DateTime.parse(userData.createdAt.validate()).year}",
                style: context.primaryTextStyle(size: 12),
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ).flexible(),
      ],
    );
  }

  Widget buildRadioListTile({required UserData userData}) {
    if (!userData.isHandymanAvailable.validate()) {
      return buildHandymanItem(userData: userData)
          .paddingSymmetric(vertical: 13, horizontal: 16);
    }
    return RadioGroup(
      groupValue: userListData,
      onChanged: (value) {
        if (userData.isHandymanAvailable.validate()) {
          if (userListData == value) {
            userListData = null;
            setState(() {});
          } else {
            userListData = value;
            setState(() {});
          }
        } else {
          Fluttertoast.cancel();
          toast(languages.lblHandymanIsOffline);
        }
      },
      child: RadioListTile<UserData>(
        value: userData,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        controlAffinity: ListTileControlAffinity.trailing,
        title: buildHandymanItem(userData: userData),
        toggleable: false,
        activeColor: context.primary,
        selected: true,
      ),
    );
  }

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
    return SafeArea(
      top: false,
      child: AppScaffold(
        scaffoldBackgroundColor: context.scaffoldSecondary,
        appBarTitle: languages.lblAssignHandyman,
        body: Stack(
          fit: StackFit.expand,
          children: [
            SnapHelperWidget<List<UserData>>(
              future: future,
              loadingWidget: LoaderWidget(),
              onSuccess: (snap) {
                return AnimatedListView(
                  controller: scrollController,
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  slideConfiguration: SlideConfiguration(verticalOffset: 400),
                  padding: const EdgeInsets.only(top: 8, bottom: 90),
                  itemCount: snap.length,
                  emptyWidget: NoDataWidget(
                    title: languages.noHandymanAvailable,
                    imageWidget: const EmptyStateWidget(),
                    retryText: languages.lblAddHandyman,
                    onRetry: () {
                      HandymanAddUpdateScreen(
                        userType: USER_TYPE_HANDYMAN,
                        onUpdate: () {
                          init();
                          setState(() {});
                        },
                      ).launch(context);
                    },
                  ),
                  onNextPage: () {
                    if (!isLastPage) {
                      page++;
                      appStore.setLoading(true);

                      init();
                      setState(() {});
                    }
                  },
                  itemBuilder: (BuildContext context, index) {
                    return Column(
                      children: [
                        buildRadioListTile(userData: snap[index])
                            .paddingOnly(bottom: 2, top: 2),
                        Divider(
                            endIndent: 16.0,
                            indent: 16.0,
                            height: 0,
                            thickness: 0.5,
                            color: context.mainBorderColor),
                      ],
                    );
                  },
                  onSwipeRefresh: () async {
                    page = 1;

                    init();
                    setState(() {});

                    return await 2.seconds.delay;
                  },
                  disposeScrollController: false,
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
            Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: Row(
                children: [
                  AppButton(
                    onTap: () {
                      _handleAssignToMyself();
                    },
                    width: context.width(),
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: radius(),
                        side: BorderSide(color: context.primary)),
                    color: context.cardSecondary,
                    elevation: 0,
                    textColor: context.primary,
                    text: languages.lblAssignToMyself,
                  ).expand(),
                  if (userListData != null) 16.width,
                  if (userListData != null)
                    AppButton(
                      onTap: () {
                        if (userListData != null) {
                          _handleAssignHandyman();
                        } else {
                          toast(languages.lblSelectHandyman);
                        }
                      },
                      color: context.primary,
                      width: context.width(),
                      text: languages.lblAssign,
                    ).expand(),
                ],
              ),
            ),
            Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading),
            )
          ],
        ),
      ),
    );
  }
}
