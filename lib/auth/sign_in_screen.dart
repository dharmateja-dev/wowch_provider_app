import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/auth/component/user_demo_mode_screen.dart';
import 'package:handyman_provider_flutter/auth/forgot_password_dialog.dart';
import 'package:handyman_provider_flutter/auth/sign_up_screen.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/handyman/handyman_dashboard_screen.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/provider/provider_dashboard_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../networks/rest_apis.dart';
import '../utils/demo_mode.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  //-------------------------------- Variables -------------------------------//

  /// TextEditing controller
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  /// FocusNodes
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  /// FormKey
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// AutoValidate mode
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;

  bool isRemember = getBoolAsync(IS_REMEMBERED);

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    super.dispose();
    emailCont.dispose();
    passwordCont.dispose();
    passwordFocus.dispose();
    emailFocus.dispose();
  }

  void init() async {
    if (await isIqonicProduct) {
      // In demo mode, start with empty fields - user can use demo buttons
      if (DEMO_MODE_ENABLED) {
        emailCont.text = '';
        passwordCont.text = '';
      } else {
        emailCont.text = getStringAsync(USER_EMAIL);
        passwordCont.text = getStringAsync(USER_PASSWORD);
      }
      setState(() {});
    }
  }

  //------------------------------------ UI ----------------------------------//

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: context.scaffold,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: Navigator.of(context).canPop()
              ? BackWidget(iconColor: context.icon)
              : null,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: context.statusBarBrightness,
            statusBarColor: context.scaffold,
          ),
        ),
        body: AbsorbPointer(
          absorbing: appStore.isLoading,
          child: SizedBox(
            height: context.height(),
            width: context.width(),
            child: Stack(
              children: [
                Form(
                  key: formKey,
                  autovalidateMode: autovalidateMode,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (context.height() * 0.085).toInt().height,
                        // Hello again with Welcome text
                        _buildHelloAgainWithWelcomeText(),
                        AutofillGroup(
                          onDisposeAction: AutofillContextAction.commit,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languages.hintEmailAddressTxt,
                                style: context.boldTextStyle(size: 14),
                              ),
                              8.height,
                              // Enter email text field.
                              AppTextField(
                                textStyle: context.primaryTextStyle(),
                                textFieldType: TextFieldType.EMAIL_ENHANCED,
                                controller: emailCont,
                                focus: emailFocus,
                                autoFocus: true,
                                nextFocus: passwordFocus,
                                errorThisFieldRequired: languages.hintRequired,
                                decoration: inputDecoration(
                                  context,
                                  prefixIcon: ic_message
                                      .iconImage(
                                        context: context,
                                        color: context.iconMuted,
                                        size: 10,
                                      )
                                      .paddingAll(14),
                                  hintText: languages.hintEmailAddressTxt,
                                  borderRadius: 8,
                                  fillColor: context.fillColor,
                                ),
                                autoFillHints: [AutofillHints.email],
                                onFieldSubmitted: (val) =>
                                    FocusScope.of(context)
                                        .requestFocus(passwordFocus),
                              ),
                              16.height,
                              Text(
                                languages.hintPassword,
                                style: context.boldTextStyle(size: 14),
                              ),
                              8.height,
                              // Enter password text field
                              AppTextField(
                                textStyle: context.primaryTextStyle(),
                                textFieldType: TextFieldType.PASSWORD,
                                controller: passwordCont,
                                focus: passwordFocus,
                                obscureText: true,
                                errorThisFieldRequired: languages.hintRequired,
                                suffixPasswordVisibleWidget: ic_show
                                    .iconImage(
                                      context: context,
                                      color: context.iconMuted,
                                      size: 10,
                                    )
                                    .paddingAll(14),
                                suffixPasswordInvisibleWidget: ic_hide
                                    .iconImage(
                                      context: context,
                                      color: context.iconMuted,
                                      size: 10,
                                    )
                                    .paddingAll(14),
                                errorMinimumPasswordLength:
                                    "${languages.errorPasswordLength} $passwordLengthGlobal",
                                decoration: inputDecoration(
                                  context,
                                  hintText: languages.hintPassword,
                                  prefixIcon: ic_passwordIcon
                                      .iconImage(
                                        context: context,
                                        color: context.iconMuted,
                                        size: 10,
                                      )
                                      .paddingAll(14),
                                  borderRadius: 8,
                                  fillColor: context.fillColor,
                                ),
                                autoFillHints: [AutofillHints.password],
                                isValidationRequired: true,
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return languages.hintRequired;
                                  } else if (val.length < 8 ||
                                      val.length > 12) {
                                    return languages.passwordLengthShouldBe;
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (s) {
                                  _handleLogin();
                                },
                              ),
                              8.height,
                            ],
                          ),
                        ),
                        _buildForgotRememberWidget(),
                        _buildButtonWidget(),
                        16.height,
                        // Show demo login options only when explicitly enabled
                        if (DEMO_MODE_ENABLED && SHOW_DEMO_BUTTONS)
                          UserDemoModeScreen(
                            onChanged: (email, password) {
                              if (email.isNotEmpty && password.isNotEmpty) {
                                emailCont.text = email;
                                passwordCont.text = password;
                              } else {
                                emailCont.clear();
                                passwordCont.clear();
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                Observer(
                  builder: (_) =>
                      LoaderWidget().center().visible(appStore.isLoading),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //region Widgets
  Widget _buildHelloAgainWithWelcomeText() {
    return Container(
      child: Column(
        children: [
          Text(languages.lblLoginTitle, style: context.boldTextStyle(size: 24))
              .center(),
          16.height,
          Text(
            languages.lblLoginSubtitle,
            style: context.primaryTextStyle(size: 16),
            textAlign: TextAlign.center,
          ).paddingSymmetric(horizontal: 16).center(),
          64.height,
        ],
      ),
    );
  }

  Widget _buildForgotRememberWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: isRemember,
                  onChanged: (value) async {
                    await setValue(IS_REMEMBERED, isRemember);
                    isRemember = !isRemember;
                    setState(() {});
                  },
                  activeColor: context.primary,
                  checkColor: context.onPrimary,
                  side: BorderSide(color: context.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                Text(languages.rememberMe, style: context.primaryTextStyle()),
              ],
            ),
            GestureDetector(
              onTap: () {
                showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM,
                  backgroundColor: context.dialogBackgroundColor,
                  builder: (_) => ForgotPasswordScreen(),
                );
              },
              child: Text(
                languages.forgotPassword,
                style: context.boldTextStyle(
                  color: context.primary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.right,
              ),
            ).flexible(),
          ],
        ),
        32.height,
      ],
    );
  }

  Widget _buildButtonWidget() {
    return Column(
      children: [
        AppButton(
          text: languages.signIn,
          color: context.primary,
          textColor: context.onPrimary,
          width: context.width() - context.navigationBarHeight,
          onTap: () {
            _handleLogin();
          },
        ),
        32.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(languages.doNotHaveAccount, style: context.primaryTextStyle()),
            8.width,
            GestureDetector(
              onTap: () {
                hideKeyboard(context);
                SignUpScreen().launch(context);
              },
              child: Text(
                languages.signUp,
                style: context.boldTextStyle(
                    color: context.primary, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ],
    );
  }

  //endregion

  //region Methods
  void _handleLogin() {
    hideKeyboard(context);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _handleLoginUsers();
    }
  }

  void _handleLoginUsers() async {
    hideKeyboard(context);

    // Demo Mode: Use dummy data instead of backend API
    if (DEMO_MODE_ENABLED) {
      await _handleDemoLogin();
      return;
    }

    Map<String, dynamic> request = {
      'email': emailCont.text.trim(),
      'password': passwordCont.text.trim(),
    };

    appStore.setLoading(true);

    try {
      UserData user = await loginUser(request);

      if (user.status != 1) {
        appStore.setLoading(false);
        return toast(languages.pleaseContactYourAdmin);
      }

      await setValue(USER_PASSWORD, passwordCont.text);
      await setValue(IS_REMEMBERED, isRemember);
      await saveUserData(user);

      authService.verifyFirebaseUser();

      redirectWidget(res: user);
    } catch (e) {
      appStore.setLoading(false);
      toast(e.toString());
    }
  }

  /// Demo Login Handler
  /// Simulates real login by validating credentials and setting up user data
  /// Works with any valid email format when DEMO_MODE_ENABLED is true
  Future<void> _handleDemoLogin() async {
    appStore.setLoading(true);

    // Simulate network delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 800));

    // Validate credentials
    if (!DemoData.validateCredentials(
        emailCont.text.trim(), passwordCont.text.trim())) {
      appStore.setLoading(false);
      toast('Invalid email or password');
      return;
    }

    // Get user based on email - determines Provider or Handyman
    UserData demoUser = DemoData.getUserForEmail(emailCont.text.trim());

    // Save demo user data to app store
    await appStore.setUserId(demoUser.id ?? 1);
    await appStore.setFirstName(demoUser.firstName ?? 'Demo');
    await appStore.setLastName(demoUser.lastName ?? 'User');
    await appStore.setUserEmail(demoUser.email ?? 'demo@provider.com');
    await appStore.setUserName(demoUser.username ?? 'demo_user');
    await appStore.setContactNumber(demoUser.contactNumber ?? '+1234567890');
    await appStore.setUserProfile(demoUser.profileImage ?? '');
    await appStore.setUserType(demoUser.userType ?? USER_TYPE_PROVIDER);
    await appStore.setDesignation(demoUser.designation ?? '');
    await appStore.setAddress(demoUser.address ?? '');
    await appStore.setCountryId(demoUser.countryId ?? 1);
    await appStore.setStateId(demoUser.stateId ?? 1);
    await appStore.setCityId(demoUser.cityId ?? 1);
    await appStore.setUId(demoUser.uid ?? 'demo_uid');
    await appStore.setToken(demoUser.apiToken ?? 'demo_token');
    await appStore.setProviderId(demoUser.providerId ?? 1);
    await appStore.setLoggedIn(true);
    await appStore.setTester(true);

    // Set createdAt for handyman experience calculation
    await appStore
        .setCreatedAt(demoUser.createdAt ?? DateTime.now().toString());

    // Set subscription and commission demo data for Provider
    if (demoUser.userType == USER_TYPE_PROVIDER) {
      // Set subscription plan demo data to show Current Plan container
      await appStore.setEarningType(EARNING_TYPE_SUBSCRIPTION);
      await appStore.setPlanTitle('Free Plan');
      await appStore.setPlanEndDate('2024-02-09');
      await appStore.setPlanSubscribeStatus(true);

      // Set commission demo data to show Provider Type & My Commission container
      await setValue(DASHBOARD_COMMISSION,
          '{"name":"company","commission":70,"type":"percent"}');
    }

    // Set remember credentials
    await setValue(USER_PASSWORD, 'demo_password');
    await setValue(IS_REMEMBERED, isRemember);

    toast('Demo login successful!');

    // Navigate to appropriate dashboard
    redirectWidget(res: demoUser);
  }

  void redirectWidget({required UserData res}) async {
    appStore.setLoading(false);
    TextInput.finishAutofillContext();

    if (res.status.validate() == 1) {
      await appStore.setToken(res.apiToken.validate());
      appStore.setTester(res.email == DEFAULT_PROVIDER_EMAIL ||
          res.email == DEFAULT_HANDYMAN_EMAIL);

      if (res.userType.validate().trim() == USER_TYPE_PROVIDER) {
        ProviderDashboardScreen(index: 0).launch(context,
            isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        toast("Your Account signed in successfully.");
      } else if (res.userType.validate().trim() == USER_TYPE_HANDYMAN) {
        HandymanDashboardScreen().launch(context,
            isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        toast("Your Account signed in successfully.");
      } else {
        toast(languages.cantLogin, print: true);
      }
    } else {
      toast(languages.lblWaitForAcceptReq);
    }
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }
}
