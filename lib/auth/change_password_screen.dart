import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
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

class ChangePasswordScreen extends StatefulWidget {
  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController oldPasswordCont = TextEditingController();
  TextEditingController newPasswordCont = TextEditingController();
  TextEditingController reenterPasswordCont = TextEditingController();

  FocusNode oldPasswordFocus = FocusNode();
  FocusNode newPasswordFocus = FocusNode();
  FocusNode reenterPasswordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> changePassword() async {
    if (formKey.currentState!.validate()) {
      if (oldPasswordCont.text.trim() != getStringAsync(USER_PASSWORD)) {
        return toast(languages.youMustProvideValidCurrentPassword);
      }

      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);

      var request = {
        UserKeys.oldPassword: oldPasswordCont.text,
        UserKeys.newPassword: newPasswordCont.text,
      };

      await changeUserPassword(request).then(
        (res) async {
          appStore.setLoading(false);
          toast(res.message);
          await setValue(USER_PASSWORD, newPasswordCont.text);
          finish(context);
        },
      ).catchError(
        (e) {
          toast(e.toString(), print: true);
          appStore.setLoading(false);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        center: true,
        languages.changePassword,
        backWidget: BackWidget(),
        textColor: context.onPrimary,
        color: context.primary,
        elevation: 0.0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: context.height(),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.always,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languages.changePasswordTitle,
                        style: context.primaryTextStyle()),
                    24.height,
                    Text(languages.hintOldPasswordTxt,
                        style: context.boldTextStyle()),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: oldPasswordCont,
                      focus: oldPasswordFocus,
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
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return languages.hintRequired;
                        } else if (val.length < 8 || val.length > 12) {
                          return languages.passwordLengthShouldBe;
                        }
                        return null;
                      },
                      nextFocus: newPasswordFocus,
                      decoration: inputDecoration(context,
                          borderRadius: 8,
                          hintText: languages.hintOldPasswordTxt,
                          prefixIcon: ic_passwordIcon
                              .iconImage(
                                context: context,
                                color: context.iconMuted,
                                size: 14,
                              )
                              .paddingAll(14)),
                    ),
                    16.height,
                    Text(languages.hintNewPasswordTxt,
                        style: context.boldTextStyle()),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: newPasswordCont,
                      focus: newPasswordFocus,
                      obscureText: true,
                      suffixPasswordVisibleWidget: ic_show
                          .iconImage(
                              context: context,
                              size: 14,
                              color: context.iconMuted)
                          .paddingAll(14),
                      suffixPasswordInvisibleWidget: ic_hide
                          .iconImage(
                              context: context,
                              size: 14,
                              color: context.iconMuted)
                          .paddingAll(14),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return languages.hintRequired;
                        } else if (val.length < 8 || val.length > 12) {
                          return languages.passwordLengthShouldBe;
                        }
                        return null;
                      },
                      nextFocus: reenterPasswordFocus,
                      decoration: inputDecoration(context,
                          borderRadius: 8,
                          hintText: languages.hintNewPasswordTxt,
                          prefixIcon: ic_passwordIcon
                              .iconImage(
                                context: context,
                                color: context.iconMuted,
                                size: 14,
                              )
                              .paddingAll(14)),
                    ),
                    16.height,
                    Text(languages.hintReenterPasswordTxt,
                        style: context.boldTextStyle()),
                    8.height,
                    AppTextField(
                      textFieldType: TextFieldType.PASSWORD,
                      controller: reenterPasswordCont,
                      obscureText: true,
                      focus: reenterPasswordFocus,
                      suffixPasswordVisibleWidget: ic_show
                          .iconImage(
                              context: context,
                              size: 14,
                              color: context.iconMuted)
                          .paddingAll(14),
                      suffixPasswordInvisibleWidget: ic_hide
                          .iconImage(
                              context: context,
                              size: 14,
                              color: context.iconMuted)
                          .paddingAll(14),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return languages.hintRequired;
                        } else if (v.length < 8 || v.length > 12) {
                          return languages.passwordLengthShouldBe;
                        } else if (newPasswordCont.text != v) {
                          return languages.passwordNotMatch;
                        }
                        return null;
                      },
                      onFieldSubmitted: (s) {
                        ifNotTester(context, () {
                          changePassword();
                        });
                      },
                      decoration: inputDecoration(context,
                          borderRadius: 8,
                          hintText: languages.hintReenterPasswordTxt,
                          prefixIcon: ic_passwordIcon
                              .iconImage(
                                context: context,
                                color: context.iconMuted,
                                size: 14,
                              )
                              .paddingAll(14)),
                    ),
                    24.height,
                    AppButton(
                      text: languages.confirm,
                      height: 40,
                      color: primary,
                      textStyle: boldTextStyle(color: white),
                      width: context.width() - context.navigationBarHeight,
                      onTap: () {
                        ifNotTester(context, () {
                          changePassword();
                        });
                      },
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
          ),
          Observer(
              builder: (_) =>
                  LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
