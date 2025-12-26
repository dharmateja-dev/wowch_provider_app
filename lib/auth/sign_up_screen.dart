// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/sign_in_screen.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_type_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';
import '../components/back_widget.dart';
import '../components/cached_image_widget.dart';
import '../models/user_data.dart';
import '../models/zone_model.dart';
import '../provider/provider_list_screen.dart';
import 'upload_documents_screen.dart';

bool isNew = false;

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  Future<ZoneModel>? providerZoneFuture;

  //-------------------------------- Variables -------------------------------//

  /// TextEditing controller
  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController designationCont = TextEditingController();

  /// FocusNodes
  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode userTypeFocus = FocusNode();
  FocusNode typeFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode designationFocus = FocusNode();

  String? selectedUserTypeValue;
  bool isFirstTimeValidation = true;

  List<UserTypeData> commissionTypeList = [
    UserTypeData(name: languages.lblSelectCommission, id: -1)
  ];

  UserTypeData? selectedUserCommissionType;

  bool isAcceptedTc = false;
  Country selectedCountry = defaultCountry();

  ValueNotifier _valueNotifier = ValueNotifier(true);

  UserData? selectedProvider;

  int? selectedProviderId;

  @override
  void dispose() {
    super.dispose();

    fNameCont.dispose();
    lNameCont.dispose();
    emailCont.dispose();
    userNameCont.dispose();
    mobileCont.dispose();
    passwordCont.dispose();
    designationCont.dispose();

    fNameFocus.dispose();
    lNameFocus.dispose();
    emailFocus.dispose();
    userNameFocus.dispose();
    mobileFocus.dispose();
    userTypeFocus.dispose();
    typeFocus.dispose();
    passwordFocus.dispose();
    designationFocus.dispose();
  }

  String? selectedZone;

  List<ZoneModel> zoneList = [];
  List<String> selectedZoneIds = [];

  bool isZoneTileExpanded = false;

  @override
  void initState() {
    super.initState();
    getZoneListApi();
  }

  Future<void> getZoneListApi() async {
    appStore.setLoading(true);
    selectedZone = null;

    await getZoneList(services: []).then((value) async {
      zoneList = value; // zoneList will now have data
      setState(() {});
      _valueNotifier.notifyListeners();
    }).catchError((e) {
      toast('$e', print: true);
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: context.scaffold,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            elevation: 0,
            leading: Navigator.of(context).canPop()
                ? BackWidget(iconColor: context.icon)
                : null,
            backgroundColor: transparentColor,
            scrolledUnderElevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: context.statusBarBrightness,
                statusBarColor: context.scaffold),
          ),
          body: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Observer(
                builder: (context) {
                  return AbsorbPointer(
                    absorbing: appStore.isLoading,
                    child: Form(
                      key: formKey,
                      autovalidateMode: isFirstTimeValidation
                          ? AutovalidateMode.disabled
                          : AutovalidateMode.onUserInteraction,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildTopWidget(),
                            _buildFormWidget(),
                            _buildFooterWidget(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              /// 🔄 Loader shown when loading
              Observer(
                builder: (context) =>
                    LoaderWidget().center().visible(appStore.isLoading),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //------------------------------ Helper Widgets-----------------------------//
  // Build hello user With Create Your Account for Better Experience text...
  Widget _buildTopWidget() {
    return Column(
      children: [
        (context.height() * 0.08).toInt().height,
        Text(languages.lblSignupTitle, style: context.boldTextStyle(size: 24))
            .center(),
        16.height,
        Text(languages.lblSignupSubtitle,
                style: context.primaryTextStyle(size: 16),
                textAlign: TextAlign.center)
            .center()
            .paddingSymmetric(horizontal: 16),
        55.height,
      ],
    );
  }

  Widget _buildFormWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languages.hintFirstNameTxt,
          style: context.boldTextStyle(size: 14),
        ),
        8.height,
        // First name text field...
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: fNameCont,
          focus: fNameFocus,
          nextFocus: lNameFocus,
          errorThisFieldRequired: languages.hintRequired,
          decoration: inputDecoration(context,
              hintText: languages.hintFirstNameTxt,
              borderRadius: 8,
              prefixIcon: profile
                  .iconImage(
                      context: context, size: 10, color: context.iconMuted)
                  .paddingAll(14)),
        ),
        16.height,
        Text(
          languages.hintLastNameTxt,
          style: context.boldTextStyle(size: 14),
        ),
        8.height,
        // Last name text field...
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: lNameCont,
          focus: lNameFocus,
          nextFocus: userNameFocus,
          errorThisFieldRequired: languages.hintRequired,
          decoration: inputDecoration(context,
              hintText: languages.hintLastNameTxt,
              borderRadius: 8,
              prefixIcon: profile
                  .iconImage(
                      context: context, size: 10, color: context.iconMuted)
                  .paddingAll(14)),
        ),
        16.height,

        // User name test field...
        Text(
          languages.hintUserNameTxt,
          style: context.boldTextStyle(size: 14),
        ),
        8.height,
        AppTextField(
          textFieldType: TextFieldType.USERNAME,
          controller: userNameCont,
          focus: userNameFocus,
          nextFocus: emailFocus,
          errorThisFieldRequired: languages.hintRequired,
          decoration: inputDecoration(context,
              hintText: languages.hintUserNameTxt,
              borderRadius: 8,
              prefixIcon: profile
                  .iconImage(
                      context: context, size: 10, color: context.iconMuted)
                  .paddingAll(14)),
        ),
        16.height,
        // Email text field...
        Text(
          languages.hintEmailAddressTxt,
          style: context.boldTextStyle(size: 14),
        ),
        8.height,
        AppTextField(
          textFieldType: TextFieldType.EMAIL_ENHANCED,
          controller: emailCont,
          focus: emailFocus,
          nextFocus: mobileFocus,
          errorThisFieldRequired: languages.hintRequired,
          decoration: inputDecoration(context,
              hintText: languages.hintEmailAddressTxt,
              borderRadius: 8,
              prefixIcon: ic_message
                  .iconImage(
                      context: context, size: 10, color: context.iconMuted)
                  .paddingAll(14)),
        ),
        16.height,
        // Contact number label
        Text(
          languages.hintContactNumberTxt,
          style: context.boldTextStyle(size: 14),
        ),
        8.height,
        // Contact number field with country code
        AppTextField(
          textFieldType: isAndroid ? TextFieldType.PHONE : TextFieldType.NAME,
          controller: mobileCont,
          focus: mobileFocus,
          errorThisFieldRequired: languages.hintRequired,
          nextFocus: designationFocus,
          decoration: inputDecoration(
            context,
            hintText: languages.addYourPhoneNumber,
            borderRadius: 8,
            prefixIcon: // Country code dropdown
                GestureDetector(
              onTap: () => changeCountry(),
              child: ValueListenableBuilder(
                valueListenable: _valueNotifier,
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
                  {required currentLength, required isFocused, maxLength}) =>
              null,
        ),
        16.height,

        // Designation text field...
        Text(
          languages.lblDesignation,
          style: context.boldTextStyle(size: 14),
        ),
        8.height,
        AppTextField(
          textFieldType: TextFieldType.USERNAME,
          controller: designationCont,
          isValidationRequired: false,
          focus: designationFocus,
          nextFocus: passwordFocus,
          decoration: inputDecoration(context,
              hintText: languages.lblDesignation,
              borderRadius: 8,
              prefixIcon: profile
                  .iconImage(
                      context: context, size: 10, color: context.iconMuted)
                  .paddingAll(14)),
        ),
        16.height,
        // User Role label
        Text(
          languages.lblUserType,
          style: context.boldTextStyle(size: 14),
        ),
        8.height,
        // User role dropdown
        ValueListenableBuilder(
          valueListenable: _valueNotifier,
          builder: (context, value, child) => Column(
            children: [
              DropdownButtonFormField<String>(
                items: [
                  DropdownMenuItem(
                    value: USER_TYPE_PROVIDER,
                    child: Text(languages.provider,
                        style: context.primaryTextStyle()),
                  ),
                  DropdownMenuItem(
                    value: USER_TYPE_HANDYMAN,
                    child: Text(languages.handyman,
                        style: context.primaryTextStyle()),
                  ),
                ],
                focusNode: userTypeFocus,
                dropdownColor: context.cardColor,
                decoration: inputDecoration(context,
                    hintText: languages.lblUserType, borderRadius: 8),
                initialValue: selectedUserTypeValue,
                validator: (value) {
                  if (value == null) return languages.hintRequired;
                  return null;
                },
                onChanged: (c) {
                  hideKeyboard(context);
                  selectedUserTypeValue = c.validate();
                  setState(() {});

                  if (selectedProvider != null) {
                    selectedProvider = null;
                    setState(() {});
                  }

                  commissionTypeList.clear();
                  selectedUserCommissionType = null;

                  getCommissionType(type: selectedUserTypeValue!).then((value) {
                    commissionTypeList = value.userTypeData.validate();
                    _valueNotifier.notifyListeners();
                  }).catchError((e) {
                    commissionTypeList = [
                      UserTypeData(name: languages.lblSelectCommission, id: -1)
                    ];
                    log(e.toString());
                  });

                  if (selectedUserTypeValue == USER_TYPE_PROVIDER) {
                    getZoneListApi();
                  } else {
                    _valueNotifier.notifyListeners();
                  }
                },
              ),
              if (selectedUserTypeValue == USER_TYPE_PROVIDER) ...[
                16.height,
                // Zone selection for providers
                Container(
                  decoration: boxDecorationDefault(
                    color: context.cardColor,
                  ),
                  child: Theme(
                    data: ThemeData(
                      dividerColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashFactory: InkSplash.splashFactory,
                    ),
                    child: ExpansionTile(
                      iconColor: context.icon,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      initiallyExpanded: zoneList.isNotEmpty,
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      title: Text(languages.selectZones,
                          style: context.secondaryTextStyle()),
                      onExpansionChanged: (val) {
                        isZoneTileExpanded = val;
                        setState(() {});
                      },
                      trailing: AnimatedCrossFade(
                        firstChild: const Icon(Icons.arrow_drop_down),
                        secondChild: const Icon(Icons.arrow_drop_up),
                        crossFadeState: isZoneTileExpanded
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: 200.milliseconds,
                      ),
                      children: zoneList.map((zone) {
                        bool isSelected =
                            selectedZoneIds.contains(zone.id.toString());
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: Theme(
                            data: ThemeData(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              unselectedWidgetColor: context.dividerColor,
                            ),
                            child: CheckboxListTile(
                              checkboxShape: RoundedRectangleBorder(
                                  borderRadius: radius(4)),
                              activeColor: context.primary,
                              checkColor: context.onPrimary,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              title: Text(zone.name.validate(),
                                  style: context.secondaryTextStyle(
                                      color: context.icon)),
                              value: isSelected,
                              onChanged: (val) {
                                if (val == true) {
                                  selectedZoneIds.add(zone.id.toString());
                                } else {
                                  selectedZoneIds.remove(zone.id.toString());
                                }
                                _valueNotifier.notifyListeners();
                                setState(() {});
                              },
                              splashRadius: 0.0,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
        // User role text field...
        if (selectedUserTypeValue == USER_TYPE_HANDYMAN)
          Container(
            decoration: boxDecorationDefault(
                color: context.cardColor, borderRadius: radius()),
            padding: EdgeInsets.only(
              top: selectedProvider != null ? 16 : 0,
              bottom: selectedProvider != null ? 16 : 0,
              left: selectedProvider != null ? 16 : 0,
              right: 4,
            ),
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selectedProvider != null)
                  GestureDetector(
                    onTap: () {
                      pickProvider();
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languages.selectedProvider,
                                style: context.secondaryTextStyle())
                            .paddingOnly(bottom: 8),
                        Row(
                          children: [
                            CachedImageWidget(
                              url: selectedProvider!.profileImage.validate(),
                              height: 24,
                              circle: true,
                              fit: BoxFit.cover,
                            ),
                            8.width,
                            Text(
                              selectedProvider!.displayName.validate(),
                              style: context.primaryTextStyle(size: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).expand(),
                if (selectedProvider != null)
                  IconButton(
                    onPressed: () {
                      selectedProvider = null;
                      setState(() {});

                      commissionTypeList.clear();
                      selectedUserCommissionType = null;

                      getCommissionType(type: selectedUserTypeValue!)
                          .then((value) {
                        commissionTypeList = value.userTypeData.validate();

                        _valueNotifier.notifyListeners();
                      }).catchError((e) {
                        commissionTypeList = [
                          UserTypeData(
                              name: languages.lblSelectCommission, id: -1)
                        ];
                        log(e.toString());
                      });
                    },
                    icon: const Icon(Icons.close),
                  )
                else
                  TextButton(
                    onPressed: () async {
                      pickProvider();
                    },
                    child: Text(languages.pickAProviderYou),
                  ),
              ],
            ),
          ),
        // Select user type text field...

        // Password text field...
        Text(
          languages.hintPassword,
          style: context.boldTextStyle(size: 14),
        ),
        8.height,
        AppTextField(
          textFieldType: TextFieldType.PASSWORD,
          controller: passwordCont,
          focus: passwordFocus,
          obscureText: true,
          suffixPasswordVisibleWidget: ic_show
              .iconImage(context: context, size: 10, color: context.iconMuted)
              .paddingAll(14),
          suffixPasswordInvisibleWidget: ic_hide
              .iconImage(context: context, size: 10, color: context.iconMuted)
              .paddingAll(14),
          errorThisFieldRequired: languages.hintRequired,
          decoration: inputDecoration(context,
              hintText: languages.hintPassword,
              prefixIcon: ic_passwordIcon
                  .iconImage(
                      context: context, size: 10, color: context.iconMuted)
                  .paddingAll(14)),
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
            saveUser();
          },
        ),
        20.height,
        AppButton(
          text: languages.lblNext,
          height: 40,
          color: context.primary,
          textStyle: context.boldTextStyle(color: context.onPrimary),
          width: context.width() - context.navigationBarHeight,
          onTap: () {
            saveUser();
          },
        ),
      ],
    );
  }

  // Pick a Provider
  void pickProvider() async {
    UserData? user =
        await ProviderListScreen(status: '$USER_STATUS_CODE').launch(context);

    if (user != null) {
      selectedProvider = user;
      selectedProviderId = user.id.validate();
      setState(() {});

      commissionTypeList.clear();
      selectedUserCommissionType = null;

      getCommissionType(
              type: selectedUserTypeValue!, providerId: selectedProviderId)
          .then((value) {
        commissionTypeList = value.userTypeData.validate();

        _valueNotifier.notifyListeners();
      }).catchError((e) {
        commissionTypeList = [
          UserTypeData(name: languages.lblSelectCommission, id: -1)
        ];
        log(e.toString());
      });
    }
  }

  // Already have an account with sign in text
  Widget _buildFooterWidget() {
    return Column(
      children: [
        16.height,
        RichTextWidget(
          list: [
            TextSpan(
                text: "${languages.alreadyHaveAccountTxt}? ",
                style: context.primaryTextStyle(size: 14)),
            TextSpan(
              text: languages.signIn,
              style: context.boldTextStyle(
                  color: context.primary, fontStyle: FontStyle.italic),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  finish(context);
                },
            ),
          ],
        ),
        30.height,
      ],
    );
  }

  //----------------------------- Helper Functions----------------------------//
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
      // optional. Shows phone code before the country name.
      onSelect: (Country country) {
        selectedCountry = country;
        _valueNotifier.notifyListeners();
      },
    );
  }

  // Build mobile number with phone code and number
  String buildMobileNumber() {
    if (mobileCont.text.isEmpty) {
      return '';
    } else {
      return '+${selectedCountry.phoneCode} ${mobileCont.text.trim()}';
    }
  }

  void saveUser() async {
    if (formKey.currentState!.validate()) {
      // TODO: Re-enable these validations after testing
      // if (selectedUserCommissionType == null ||
      //     selectedUserCommissionType!.id == -1) {
      //   return toast(languages.pleaseSelectCommission);
      // }
      // if (selectedUserTypeValue == USER_TYPE_PROVIDER &&
      //     selectedZoneIds.isEmpty) {
      //   return toast(languages.plzSelectOneZone);
      // }
      formKey.currentState!.save();
      hideKeyboard(context);
      var request = {
        UserKeys.firstName: fNameCont.text.trim(),
        UserKeys.lastName: lNameCont.text.trim(),
        UserKeys.userName: userNameCont.text.trim(),
        UserKeys.userType: selectedUserTypeValue,
        UserKeys.contactNumber: buildMobileNumber(),
        UserKeys.email: emailCont.text.trim(),
        UserKeys.password: passwordCont.text.trim(),
        UserKeys.designation: designationCont.text.trim(),
        UserKeys.status: 0,
      };

      if (selectedProvider != null) {
        request[UserKeys.providerId] = selectedProviderId;
      }

      if (selectedUserTypeValue == USER_TYPE_PROVIDER) {
        // Only add providerTypeId if commission type is selected
        if (selectedUserCommissionType != null &&
            selectedUserCommissionType!.id != -1) {
          request.putIfAbsent(UserKeys.providerTypeId,
              () => selectedUserCommissionType!.id.toString());
        }
        if (selectedZoneIds.isNotEmpty) {
          request[UserKeys.zoneId] = selectedZoneIds.join(',');
          log('✅ Zone IDs added: ${request[UserKeys.zoneId]}');
        } else {
          log('⚠️ selectedZoneIds is empty!');
        }
      }

      log('📋 Selected User Type: $selectedUserTypeValue');
      log('📋 Request: $request');

      if (selectedUserTypeValue == USER_TYPE_PROVIDER) {
        log('🚀 Navigating to UploadDocumentsScreen');
        UploadDocumentsScreen(formRequest: request).launch(context,
            pageRouteAnimation: PageRouteAnimation.SlideBottomTop);
      } else {
        await registerUser(request).then((userRegisterData) async {
          appStore.setLoading(false);
          toast(userRegisterData.message.validate());
          push(SignInScreen(),
              isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        }).catchError((e) {
          toast(e.toString(), print: true);
          appStore.setLoading(false);
        });
      }
    }
  }
}
