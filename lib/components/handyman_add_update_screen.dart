import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/selectZoneModel.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/models/user_type_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:nb_utils/nb_utils.dart';

import '../provider/earning/handyman_payout_list_screen.dart';

class HandymanAddUpdateScreen extends StatefulWidget {
  final String? userType;
  final UserData? data;
  final Function? onUpdate;

  HandymanAddUpdateScreen({this.userType, this.data, this.onUpdate});

  @override
  HandymanAddUpdateScreenState createState() => HandymanAddUpdateScreenState();
}

class HandymanAddUpdateScreenState extends State<HandymanAddUpdateScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController cPasswordCont = TextEditingController();
  TextEditingController designationCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode cPasswordFocus = FocusNode();
  FocusNode designationFocus = FocusNode();

  ValueNotifier valueNotifier = ValueNotifier(true);

  Country selectedCountry = defaultCountry();

  List<ZoneResponse> providerZoneList = [];
  ZoneResponse? selectedServiceZone;

  List<UserTypeData> commissionList = [
    UserTypeData(name: languages.lblSelectCommission, id: -1)
  ];
  UserTypeData? selectedHandymanCommission;

  int? serviceZoneId;
  int? commissionId;

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();

    if (widget.data != null) {
      isUpdate = true;
      fNameCont.text = widget.data!.firstName.validate();
      lNameCont.text = widget.data!.lastName.validate();
      emailCont.text = widget.data!.email.validate();
      userNameCont.text = widget.data!.username.validate();
      mobileCont.text =
          widget.data!.contactNumber?.split("-").last.validate() ?? "";
      serviceZoneId = widget.data!.handymanZoneID.validate();
      commissionId = widget.data!.handymanCommissionId.validate();
      designationCont.text = widget.data!.designation.validate();
      selectedCountry = Country(
        phoneCode:
            widget.data!.contactNumber?.split("-").first.validate() ?? "",
        countryCode: "",
        e164Sc: 0,
        geographic: true,
        level: 0,
        name: "",
        example: "",
        displayName: "",
        displayNameNoCountryCode: "",
        e164Key: "",
      );
      widget.data!.contactNumber?.split("-").first.validate();
    }

    init();
    afterBuildCreated(() {
      appStore.setLoading(true);
    });
  }

  Future<void> init() async {
    if (DEMO_MODE_ENABLED) {
      // Use demo data and skip API calls
      appStore.setLoading(false);
      return;
    }
    getAddressList();
    getCommissionList();
  }

  Future<void> getAddressList() async {
    appStore.setLoading(true);
    await getZoneWithPagination(
            providerId: appStore.userId,
            zoneList: providerZoneList,
            isRequiredAllZones: true)
        .then((value) {
      appStore.setLoading(false);

      providerZoneList.forEach((e) {
        if (e.id == serviceZoneId) {
          selectedServiceZone = e;
        }
      });
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> getCommissionList() async {
    getCommissionType(type: USER_TYPE_HANDYMAN, providerId: appStore.userId)
        .then((value) {
      appStore.setLoading(false);
      commissionList.addAll(value.userTypeData!);

      commissionList.forEach((e) {
        if (e.id == commissionId) {
          selectedHandymanCommission = e;
        }
      });
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      commissionList = [
        UserTypeData(name: languages.lblSelectCommission, id: -1)
      ];
      log(e.toString());
    });
  }

  // Build mobile number with phone code and number
  String buildMobileNumber() {
    return '${selectedCountry.phoneCode}-${mobileCont.text.trim()}';
  }

  /// Register the Handyman
  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      if (selectedHandymanCommission == null ||
          selectedHandymanCommission!.id == -1) {
        return toast(languages.pleaseSelectCommission);
      }
      formKey.currentState!.save();
      hideKeyboard(context);
      String? type = widget.userType;
      var request = {
        if (isUpdate) CommonKeys.id: widget.data!.id,
        UserKeys.firstName: fNameCont.text,
        UserKeys.lastName: lNameCont.text,
        UserKeys.userName: userNameCont.text,
        UserKeys.userType: type,
        UserKeys.providerId: appStore.userId,
        UserKeys.status: USER_STATUS_CODE,
        UserKeys.contactNumber: buildMobileNumber(),
        UserKeys.designation: designationCont.text.validate(),
        if (serviceZoneId != null && serviceZoneId != -1)
          UserKeys.handyman_zone_id: serviceZoneId.validate(),
        UserKeys.email: emailCont.text,
        UserKeys.handymanTypeId: selectedHandymanCommission?.id,
        if (!isUpdate) UserKeys.password: passwordCont.text
      };
      appStore.setLoading(true);
      if (isUpdate) {
        await updateProfile(request).then((res) async {
          toast(res.message.validate());
          finish(context, widget.onUpdate!.call());
        }).catchError((e) {
          toast(e.toString());
        });
      } else {
        await registerUser(request).then((res) async {
          toast(res.message.validate());
          finish(context, widget.onUpdate!.call());
        }).catchError((e) {
          toast(e.toString());
        });
      }
      appStore.setLoading(false);
    }
  }

  /// Remove the Handyman
  Future<void> removeHandyman(int? id) async {
    appStore.setLoading(true);
    await deleteHandyman(id.validate()).then((value) {
      appStore.setLoading(false);

      finish(context, widget.onUpdate!.call());

      toast(languages.lblTrashHandyman, print: true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// Restore the Handyman
  Future<void> restoreHandymanData() async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: widget.data!.id,
      'type': RESTORE,
    };

    await restoreHandyman(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      finish(context, widget.onUpdate!.call());
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// ForceFully Delete the Handyman
  Future<void> forceDeleteHandymanData() async {
    appStore.setLoading(true);
    var req = {
      CommonKeys.id: widget.data!.id,
      'type': FORCE_DELETE,
    };

    await restoreHandyman(req).then((value) {
      appStore.setLoading(false);
      toast(value.message);
      finish(context, widget.onUpdate!.call());
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  /// Parse date string - handles both ISO 8601 and yyyy-MM-dd HH:mm:ss formats
  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      try {
        // Try parsing with space separator instead of T
        return DateTime.parse(dateString.replaceFirst(' ', 'T'));
      } catch (e) {
        return DateTime.now();
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
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
          isUpdate ? languages.lblUpdate : languages.lblAddHandyman,
          style: context.boldTextStyle(color: context.onPrimary, size: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (widget.data != null) {
                HandymanPayoutListScreen(user: widget.data!).launch(context);
              }
            },
            icon: Icon(Icons.payments_outlined,
                size: 24, color: context.onPrimary),
            tooltip: languages.handymanPayoutList,
          ).visible(isUpdate),
          if (isUpdate && rolesAndPermissionStore.handymanDelete)
            PopupMenuButton(
              icon: Icon(Icons.more_vert, size: 24, color: context.onPrimary),
              color: context.cardSecondary,
              onSelected: (selection) async {
                if (selection == 1) {
                  showConfirmDialogCustom(
                    context,
                    height: 80,
                    width: 290,
                    shape: appDialogShape(8),
                    dialogType: DialogType.DELETE,
                    title: languages.lblDoYouWantToDelete,
                    titleColor: context.dialogTitleColor,
                    backgroundColor: context.dialogBackgroundColor,
                    primaryColor: context.error,
                    customCenterWidget: Image.asset(
                      ic_warning,
                      color: context.dialogIconColor,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                    positiveText: languages.lblDelete,
                    positiveTextColor: context.onPrimary,
                    negativeText: languages.lblCancel,
                    negativeTextColor: context.dialogCancelColor,
                    onAccept: (_) {
                      ifNotTester(context, () {
                        removeHandyman(widget.data!.id.validate());
                      });
                    },
                  );
                } else if (selection == 2) {
                  showConfirmDialogCustom(
                    context,
                    height: 80,
                    width: 290,
                    shape: appDialogShape(8),
                    dialogType: DialogType.CONFIRMATION,
                    title: languages.lblDoYouWantToRestore,
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
                    positiveText: languages.lblRestore,
                    positiveTextColor: context.onPrimary,
                    negativeText: languages.lblCancel,
                    negativeTextColor: context.dialogCancelColor,
                    onAccept: (_) {
                      ifNotTester(context, () {
                        restoreHandymanData();
                      });
                    },
                  );
                } else if (selection == 3) {
                  showConfirmDialogCustom(
                    context,
                    height: 80,
                    width: 290,
                    shape: appDialogShape(8),
                    dialogType: DialogType.DELETE,
                    title: languages.lblDoYouWantToDeleteForcefully,
                    titleColor: context.dialogTitleColor,
                    backgroundColor: context.dialogBackgroundColor,
                    primaryColor: context.error,
                    customCenterWidget: Image.asset(
                      ic_warning,
                      color: context.dialogIconColor,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                    ),
                    positiveText: languages.lblDelete,
                    positiveTextColor: context.onPrimary,
                    negativeText: languages.lblCancel,
                    negativeTextColor: context.dialogCancelColor,
                    onAccept: (_) {
                      ifNotTester(context, () {
                        forceDeleteHandymanData();
                      });
                    },
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  enabled: widget.data!.deletedAt == null,
                  child: Text(
                    languages.lblDelete,
                    style: context.boldTextStyle(
                      color: widget.data!.deletedAt == null
                          ? context.onSurface
                          : context.textGrey,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  enabled: widget.data!.deletedAt != null,
                  child: Text(
                    languages.lblRestore,
                    style: context.boldTextStyle(
                      color: widget.data!.deletedAt != null
                          ? context.onSurface
                          : context.textGrey,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  enabled: widget.data!.deletedAt != null,
                  child: Text(
                    languages.lblForceDelete,
                    style: context.boldTextStyle(
                      color: widget.data!.deletedAt != null
                          ? context.error
                          : context.textGrey,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  if (isUpdate)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.primary.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: CachedImageWidget(
                        url: widget.data!.profileImage.validate(value: profile),
                        height: 100,
                        width: 100,
                        circle: true,
                        fit: BoxFit.cover,
                      ),
                    ).center(),

                  24.height,

                  // First Name
                  Text(languages.hintFirstNameTxt,
                      style: context.boldTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: fNameCont,
                    focus: fNameFocus,
                    enabled:
                        isUpdate ? rolesAndPermissionStore.handymanEdit : true,
                    nextFocus: lNameFocus,
                    decoration: inputDecoration(
                      context,
                      prefixIcon: ic_profile
                          .iconImage(
                              context: context,
                              color: context.iconMuted,
                              size: 12)
                          .paddingAll(14),
                      hintText: languages.hintFirstNameTxt,
                      fillColor: context.profileInputFillColor,
                      borderRadius: 8,
                    ),
                  ),

                  16.height,

                  // Last Name
                  Text(languages.hintLastNameTxt,
                      style: context.boldTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: lNameCont,
                    focus: lNameFocus,
                    enabled:
                        isUpdate ? rolesAndPermissionStore.handymanEdit : true,
                    nextFocus: userNameFocus,
                    decoration: inputDecoration(
                      context,
                      hintText: languages.hintLastNameTxt,
                      fillColor: context.profileInputFillColor,
                      prefixIcon: ic_profile
                          .iconImage(
                              context: context,
                              color: context.iconMuted,
                              size: 12)
                          .paddingAll(14),
                      borderRadius: 8,
                    ),
                  ),

                  16.height,

                  // Username
                  Text(languages.hintUserNameTxt,
                      style: context.boldTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.USERNAME,
                    controller: userNameCont,
                    focus: userNameFocus,
                    nextFocus: emailFocus,
                    enabled:
                        isUpdate ? rolesAndPermissionStore.handymanEdit : true,
                    decoration: inputDecoration(
                      context,
                      hintText: languages.hintUserNameTxt,
                      fillColor: context.profileInputFillColor,
                      prefixIcon: ic_profile
                          .iconImage(
                              context: context,
                              color: context.iconMuted,
                              size: 12)
                          .paddingAll(14),
                      borderRadius: 8,
                    ),
                  ),

                  16.height,

                  // Email
                  Text(languages.hintEmailAddressTxt,
                      style: context.boldTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.EMAIL_ENHANCED,
                    controller: emailCont,
                    focus: emailFocus,
                    nextFocus: mobileFocus,
                    enabled:
                        isUpdate ? rolesAndPermissionStore.handymanEdit : true,
                    decoration: inputDecoration(
                      context,
                      hintText: languages.hintEmailAddressTxt,
                      fillColor: context.profileInputFillColor,
                      prefixIcon: ic_message
                          .iconImage(
                              context: context,
                              color: context.iconMuted,
                              size: 12)
                          .paddingAll(14),
                      borderRadius: 8,
                    ),
                  ),

                  16.height,

                  // Contact Number
                  Text(languages.hintContactNumberTxt,
                      style: context.boldTextStyle()),
                  8.height,
                  IgnorePointer(
                    ignoring: isUpdate
                        ? !rolesAndPermissionStore.handymanEdit
                        : false,
                    child: AppTextField(
                      textFieldType:
                          isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
                      controller: mobileCont,
                      focus: mobileFocus,
                      nextFocus: designationFocus,
                      decoration: inputDecoration(
                        context,
                        hintText: languages.addYourPhoneNumber,
                        fillColor: context.profileInputFillColor,
                        borderRadius: 8,
                        prefixIcon: GestureDetector(
                          onTap: () => changeCountry(),
                          child: ValueListenableBuilder(
                            valueListenable: valueNotifier,
                            builder: (context, value, child) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "+${selectedCountry.phoneCode}",
                                  style: context.boldTextStyle(size: 14),
                                ),
                                2.width,
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: context.icon,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ).paddingAll(14),
                      ),
                      maxLength: 15,
                      buildCounter: (context,
                              {required currentLength,
                              required isFocused,
                              maxLength}) =>
                          null,
                      validator: (mobileCont) {
                        if (mobileCont!.isEmpty)
                          return languages.lblPleaseEnterMobileNumber;
                        return null;
                      },
                    ),
                  ),

                  16.height,

                  // Designation
                  Text(languages.lblDesignation,
                      style: context.boldTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: designationCont,
                    isValidationRequired: false,
                    enabled:
                        isUpdate ? rolesAndPermissionStore.handymanEdit : true,
                    focus: designationFocus,
                    nextFocus: passwordFocus,
                    decoration: inputDecoration(
                      context,
                      hintText: languages.lblDesignation,
                      fillColor: context.profileInputFillColor,
                      borderRadius: 8,
                      prefixIcon: ic_profile
                          .iconImage(
                              context: context,
                              color: context.iconMuted,
                              size: 12)
                          .paddingAll(14),
                    ),
                  ),

                  16.height,

                  // Commission Dropdown
                  if (commissionList.isNotEmpty) ...[
                    Text(languages.lblSelectCommission,
                        style: context.boldTextStyle()),
                    8.height,
                    IgnorePointer(
                      ignoring: isUpdate
                          ? !rolesAndPermissionStore.handymanEdit
                          : false,
                      child: DropdownButtonFormField<UserTypeData>(
                        decoration: inputDecoration(
                          context,
                          hintText: languages.lblSelectCommission,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                        ),
                        isExpanded: true,
                        dropdownColor: context.cardSecondary,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: context.icon),
                        initialValue: selectedHandymanCommission,
                        items: commissionList.map((data) {
                          return DropdownMenuItem<UserTypeData>(
                            value: data,
                            child: Row(
                              children: [
                                Text(data.name.toString(),
                                    style: context.primaryTextStyle()),
                                4.width,
                                if (data.type == COMMISSION_TYPE_PERCENT)
                                  Text(
                                    '(${data.commission.toString()}%)',
                                    style: context.secondaryTextStyle(),
                                  )
                                else if (data.type == COMMISSION_TYPE_FIXED)
                                  Text(
                                    '(${data.commission.validate().toPriceFormat()})',
                                    style: context.secondaryTextStyle(),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (UserTypeData? value) async {
                          selectedHandymanCommission = value;
                          commissionId =
                              selectedHandymanCommission!.id.validate();
                          setState(() {});
                        },
                      ),
                    ),
                    16.height,
                  ],

                  // Service Zone Dropdown
                  if (providerZoneList.isNotEmpty) ...[
                    Text(languages.selectServiceZone,
                        style: context.boldTextStyle()),
                    8.height,
                    IgnorePointer(
                      ignoring: isUpdate
                          ? !rolesAndPermissionStore.handymanEdit
                          : false,
                      child: DropdownButtonFormField<ZoneResponse>(
                        decoration: inputDecoration(
                          context,
                          hintText: languages.selectServiceZone,
                          fillColor: context.profileInputFillColor,
                          borderRadius: 8,
                        ),
                        isExpanded: true,
                        dropdownColor: context.cardSecondary,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: context.icon),
                        initialValue: selectedServiceZone,
                        items: providerZoneList.map((data) {
                          return DropdownMenuItem<ZoneResponse>(
                            value: data,
                            child: Text(
                              data.name.validate(),
                              style: context.primaryTextStyle(),
                            ),
                          );
                        }).toList(),
                        onChanged: (ZoneResponse? value) async {
                          selectedServiceZone = value;
                          serviceZoneId = selectedServiceZone!.id.validate();
                          setState(() {});
                        },
                      ),
                    ),
                    16.height,
                  ],

                  // Password (only for new handyman)
                  if (!isUpdate) ...[
                    Text(languages.hintPassword,
                        style: context.boldTextStyle()),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: passwordCont,
                      focus: passwordFocus,
                      enabled: isUpdate
                          ? rolesAndPermissionStore.handymanEdit
                          : true,
                      obscureText: true,
                      suffixPasswordVisibleWidget: ic_show
                          .iconImage(
                              context: context,
                              size: 10,
                              color: context.iconMuted)
                          .paddingAll(14),
                      suffixPasswordInvisibleWidget: ic_hide
                          .iconImage(
                              context: context,
                              size: 10,
                              color: context.iconMuted)
                          .paddingAll(14),
                      decoration: inputDecoration(
                        context,
                        hintText: languages.hintPassword,
                        fillColor: context.profileInputFillColor,
                        borderRadius: 8,
                        prefixIcon: ic_passwordIcon
                            .iconImage(
                                context: context,
                                size: 10,
                                color: context.iconMuted)
                            .paddingAll(14),
                      ),
                      isValidationRequired: true,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return languages.hintRequired;
                        } else if (val.length < 8 || val.length > 12) {
                          return languages.passwordLengthShouldBe;
                        }
                        return null;
                      },
                      onFieldSubmitted: (s) {
                        ifNotTester(context, () {
                          register();
                        });
                      },
                    ),
                    16.height,
                  ],

                  // Registration Info (for update mode)
                  if (isUpdate && widget.data!.createdAt != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardSecondary,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.cardSecondaryBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.data!.displayName.validate(value: "${widget.data!.firstName} ${widget.data!.lastName}")} ${languages.lblRegistered} ${_parseDate(widget.data!.createdAt!).timeAgo}',
                            style: context.secondaryTextStyle(),
                          ),
                          4.height,
                          Text(
                            formatBookingDate(widget.data!.createdAt),
                            style: context.secondaryTextStyle(size: 12),
                          ),
                          if (widget.data!.emailVerifiedAt
                              .validate()
                              .isNotEmpty) ...[
                            8.height,
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.primary,
                                  ),
                                  child: Icon(Icons.check,
                                      color: context.onPrimary, size: 14),
                                ),
                                8.width,
                                Expanded(
                                  child: Text(
                                    languages.lblEmailIsVerified,
                                    style: context.primaryTextStyle(
                                        color: context.primary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  100.height,
                ],
              ),
            ),
          ),

          // Save Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Observer(
              builder: (context) => AppButton(
                text: languages.btnSave,
                color: context.primary,
                textStyle: boldTextStyle(color: context.onPrimary),
                width: context.width(),
                onTap: appStore.isLoading
                    ? null
                    : () {
                        register();
                      },
              ),
            ),
          ),

          // Loader
          Observer(
            builder: (_) => LoaderWidget().center().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }

  // Change country code function...
  Future<void> changeCountry() async {
    showCountryPicker(
      context: context,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(0),
        bottomSheetHeight: 600,
        textStyle: context.primaryTextStyle(),
        searchTextStyle: context.primaryTextStyle(
          color: context.searchTextColor,
        ),
        backgroundColor: context.bottomSheetBackgroundColor,
        inputDecoration: InputDecoration(
          fillColor: context.searchFillColor,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
          ),
          hintText: languages.search,
          hintStyle: context.primaryTextStyle(
            size: 14,
            color: context.searchHintColor,
          ),
          prefixIcon: Icon(Icons.search, color: context.searchHintColor),
        ),
      ),
      showPhoneCode: true,
      onSelect: (Country country) {
        selectedCountry = country;
        valueNotifier.value = !valueNotifier.value;
      },
    );
  }
}
