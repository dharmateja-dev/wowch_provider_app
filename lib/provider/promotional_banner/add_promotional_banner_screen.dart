import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/provider/promotional_banner/promotional_banner_repository.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/num_extenstions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_common_dialog.dart';
import '../../components/app_widgets.dart';
import '../../components/chat_gpt_loder.dart';
import '../../components/custom_image_picker.dart';
import '../../components/date_range_component.dart';
import '../../components/empty_error_state_widget.dart';
import '../../components/price_widget.dart';
import '../../main.dart';
import '../../models/service_model.dart';
import '../../models/static_data_model.dart';
import '../../networks/rest_apis.dart';
import '../../utils/app_configuration.dart';
import '../../utils/common.dart';
import '../../utils/configs.dart';
import '../../utils/constant.dart';
import '../../utils/model_keys.dart';
import '../payment/components/airtel_money/airtel_money_service.dart';
import '../payment/components/cinet_pay_services_new.dart';
import '../payment/components/flutter_wave_service_new.dart';
import '../payment/components/midtrans_service.dart';
import '../payment/components/paypal_service.dart';
import '../payment/components/paystack_service.dart';
import '../payment/components/phone_pe/phone_pe_service.dart';
import '../payment/components/razorpay_service_new.dart';
import '../payment/components/sadad_services_new.dart';
import '../payment/components/stripe_service_new.dart';

class AddPromotionalBannerScreen extends StatefulWidget {
  final Function(bool) callback;

  const AddPromotionalBannerScreen({required this.callback});

  @override
  _AddPromotionalBannerScreenState createState() =>
      _AddPromotionalBannerScreenState();
}

class _AddPromotionalBannerScreenState
    extends State<AddPromotionalBannerScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UniqueKey uniqueKey = UniqueKey();

  List<File> imageFiles = [];

  TextEditingController titleCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();
  TextEditingController linkCont = TextEditingController();

  bool isPaymentPending = false;

  FocusNode titleFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();
  FocusNode linkFocus = FocusNode();
  Future<List<ServiceData>>? future;

  List<ServiceData> serviceList = [];
  List<PaymentSetting> paymentList = [];

  ServiceData? selectedService;

  DateTime today = DateTime.now();

  PaymentSetting? selectedPaymentSetting;

  String selectedType = PROMOTIONAL_TYPE_SERVICE;

  String startingDate = '';
  String endingDate = '';
  String totalDaysCount = '';
  String bannerId = '';

  List<StaticDataModel> typeStaticData = [
    StaticDataModel(key: PROMOTIONAL_TYPE_SERVICE, value: languages.lblService),
    StaticDataModel(key: PROMOTIONAL_TYPE_LINK, value: languages.link),
  ];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    getPaymentMethods();
    future = getSearchList(
      status: SERVICE_APPROVE,
      page,
      providerId: appStore.userType == USER_TYPE_HANDYMAN
          ? appStore.providerId
          : appStore.userId,
      services: serviceList,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    ).then((list) {
      serviceList = list.validate();
      serviceList.forEach((element) {
        if (filterStore.serviceId.contains(element.id)) {
          element.isSelected = true;
        }
      });
      return serviceList;
    });
    // Sync new configurations for secret keys
    await setValue(LAST_APP_CONFIGURATION_SYNCED_TIME, 0);
    getAppConfigurations();
  }

  /// Get All Service API
  Future<void> getAllService() async {
    appStore.setLoading(true);

    await getAllServiceList(providerId: appStore.providerId, perPage: 'all')
        .then((value) {
      serviceList = value.data.validate();

      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
    appStore.setLoading(false);
  }

  /// Get Payment Methods API
  Future<void> getPaymentMethods() async {
    appStore.setLoading(true);

    await getPaymentGateways(requireCOD: false).then((paymentListData) {
      paymentList = paymentListData.validate();

      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  ///Region Save Promotional Banner API
  Future<void> checkValidation() async {
    hideKeyboard(context);

    if (imageFiles.isEmpty) {
      toast(languages.pleaseSelectImages);
      return;
    }

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (selectedPaymentSetting == null) {
        return toast(languages.chooseAnyOnePayment);
      }

      Map<String, dynamic> req = {
        PromotionalBannerKey.bannerType: selectedType,
        PromotionalBannerKey.startDate: startingDate,
        PromotionalBannerKey.endDate: endingDate,
      };

      if (descriptionCont.text.isNotEmpty) {
        req.putIfAbsent(PromotionalBannerKey.description,
            () => descriptionCont.text.validate());
      }

      if (selectedService != null) {
        req.putIfAbsent(PromotionalBannerKey.serviceId,
            () => selectedService!.id.validate());
      }

      if (linkCont.text.isNotEmpty) {
        req.putIfAbsent(PromotionalBannerKey.bannerRedirectUrl,
            () => linkCont.text.validate());
      }

      log("Request: $req");
      savePromotionalBannerMultiPart(
        value: req,
        imageFile: imageFiles
            .where((element) => !element.path.contains('http'))
            .toList(),
        callback: (id) {
          appStore.setLoading(false);
          bannerId = id.toString();
          isPaymentPending = true;
          setState(() {});
        },
      ).then((value) {
        appStore.setLoading(false);
        _handleClick();
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  //endregion

  /// Region Handle Payment Method Click
  Future<void> _handleClick() async {
    _handlePayment().catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  Future<void> _handlePayment() async {
    if (selectedPaymentSetting!.type == PAYMENT_METHOD_STRIPE) {
      StripeServiceNew stripeServiceNew = StripeServiceNew(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_STRIPE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );

      stripeServiceNew.stripePay().catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_RAZOR) {
      RazorPayServiceNew razorPayServiceNew = RazorPayServiceNew(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_RAZOR,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['paymentId'],
          );
        },
      );
      razorPayServiceNew.razorPayCheckout().catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_FLUTTER_WAVE) {
      FlutterWaveServiceNew flutterWaveServiceNew = FlutterWaveServiceNew();

      flutterWaveServiceNew.checkout(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_FLUTTER_WAVE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_CINETPAY) {
      List<String> supportedCurrencies = ["XOF", "XAF", "CDF", "GNF", "USD"];

      if (!supportedCurrencies.contains(appConfigurationStore.currencyCode)) {
        toast(languages.cinetpayIsnTSupportedByCurrencies);
        return;
      } else if (totalAmount < 100) {
        return toast(
            '${languages.totalAmountShouldBeMoreThan} ${100.toPriceFormat()}');
      } else if (totalAmount > 1500000) {
        return toast(
            '${languages.totalAmountShouldBeLessThan} ${1500000.toPriceFormat()}');
      }

      CinetPayServicesNew cinetPayServices = CinetPayServicesNew(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_CINETPAY,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );

      cinetPayServices.payWithCinetPay(context: context).catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_SADAD_PAYMENT) {
      SadadServicesNew sadadServices = SadadServicesNew(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          savePay(
            paymentMethod: PAYMENT_METHOD_SADAD_PAYMENT,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );

      sadadServices.payWithSadad(context).catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_PAYPAL) {
      PayPalService.paypalCheckOut(
        context: context,
        paymentSetting: selectedPaymentSetting!,
        totalAmount: totalAmount,
        onComplete: (p0) {
          log('PayPalService onComplete: $p0');
          savePay(
            paymentMethod: PAYMENT_METHOD_PAYPAL,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            txnId: p0['transaction_id'],
          );
        },
      );
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_AIRTEL) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        barrierDismissible: false,
        builder: (context) {
          return AppCommonDialog(
            title: languages.airtelMoneyPayment,
            child: AirtelMoneyDialog(
              amount: totalAmount,
              reference: APP_NAME,
              paymentSetting: selectedPaymentSetting!,
              bookingId: appStore.userId.validate().toInt(),
              onComplete: (res) {
                log('RES: $res');
                savePay(
                  paymentMethod: PAYMENT_METHOD_AIRTEL,
                  paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
                  txnId: res['transaction_id'],
                );
              },
            ),
          );
        },
      ).then((value) => appStore.setLoading(false));
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_PAYSTACK) {
      PayStackService paystackServices = PayStackService();
      appStore.setLoading(true);
      await paystackServices.init(
        context: context,
        currentPaymentMethod: selectedPaymentSetting!,
        loderOnOFF: (p0) {
          appStore.setLoading(p0);
        },
        totalAmount: totalAmount.toDouble(),
        bookingId: appStore.userId.validate().toInt(),
        onComplete: (res) {
          savePay(
            paymentMethod: PAYMENT_METHOD_PAYSTACK,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            txnId: res["transaction_id"],
          );
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      appStore.setLoading(false);
      paystackServices.checkout().catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_MIDTRANS) {
      MidtransService midtransService = MidtransService();
      appStore.setLoading(true);
      await midtransService.initialize(
        currentPaymentMethod: selectedPaymentSetting!,
        totalAmount: totalAmount,
        loaderOnOFF: (p0) {
          appStore.setLoading(p0);
        },
        onComplete: (res) {
          savePay(
            paymentMethod: PAYMENT_METHOD_MIDTRANS,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            txnId: res["transaction_id"],
          );
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      appStore.setLoading(false);
      midtransService.midtransPaymentCheckout().catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    } else if (selectedPaymentSetting!.type == PAYMENT_METHOD_PHONEPE) {
      PhonePeServices peServices = PhonePeServices(
        paymentSetting: selectedPaymentSetting!,
        totalAmount: totalAmount.toDouble(),
        bookingId: appStore.userId.validate().toInt(),
        onComplete: (res) {
          log('RES: $res');
          savePay(
            paymentMethod: PAYMENT_METHOD_PHONEPE,
            paymentStatus: SERVICE_PAYMENT_STATUS_PAID,
            txnId: res["transaction_id"],
          );
        },
      );

      peServices.phonePeCheckout(context).catchError((e) {
        appStore.setLoading(false);
        toast(e);
      });
    }
  }

  Future<void> savePay(
      {String txnId = '',
      String paymentMethod = '',
      String paymentStatus = ''}) async {
    Map request = {
      PromotionalBannerKey.bannerId: bannerId.validate(),
      PromotionalBannerKey.txnId:
          txnId.isNotEmpty ? txnId : "#${bannerId.validate()}",
      PromotionalBannerKey.paymentStatus: paymentStatus,
      PromotionalBannerKey.paymentType: paymentMethod,
    };

    appStore.setLoading(true);
    log('Request : $request');

    await savePromotionalBannerPayment(request).then((value) async {
      toast(value.message.validate());
      isPaymentPending = false;
      setState(() {});
      finish(context);
      widget.callback.call(true);
    }).catchError((e) {
      appStore.setLoading(false);
      log(e.toString());
    }).whenComplete(() => appStore.setLoading(false));
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (appStore.isLoading) {
      appStore.setLoading(false);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AppScaffold(
        scaffoldBackgroundColor: context.scaffoldSecondary,
        appBarTitle: languages.addPromotionalBanner,
        body: Stack(
          children: [
            Column(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Promotional Banner Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        width: context.width(),
                        decoration: BoxDecoration(
                          color:
                              context.primaryLiteColor.withValues(alpha: 0.15),
                          border: Border.all(
                            color: context.primaryLiteColor,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                color: context.primaryLiteColor,
                              ),
                              child: Center(
                                child: Image.asset(
                                  ic_outline_banner,
                                  height: 26,
                                  width: 26,
                                  color: context.onPrimary,
                                ),
                              ),
                            ),
                            16.width,
                            Observer(builder: (context) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languages.promoteYourBusinessBanners(
                                        appConfigurationStore.bannerPerDayAmount
                                            .toPriceFormat()),
                                    style: context.boldTextStyle(size: 14),
                                  ),
                                  8.height,
                                  Text(
                                    languages.advertiseYourServicesEffectively,
                                    style: context.secondaryTextStyle(size: 12),
                                  ),
                                ],
                              ).expand();
                            }),
                          ],
                        ),
                      ),

                      20.height,

                      // Form
                      Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image Picker
                            Text(
                              languages.lblImage,
                              style: context.boldTextStyle(),
                            ),
                            8.height,
                            CustomImagePicker(
                              key: uniqueKey,
                              height: 170,
                              isMultipleImages: false,
                              isCrop: true,
                              onRemoveClick: (value) {
                                showConfirmDialogCustom(
                                  context,
                                  dialogType: DialogType.DELETE,
                                  backgroundColor:
                                      context.dialogBackgroundColor,
                                  titleColor: context.dialogTitleColor,
                                  primaryColor: context.error,
                                  positiveText: languages.lblDelete,
                                  positiveTextColor: context.onPrimary,
                                  negativeText: languages.lblCancel,
                                  negativeTextColor: context.primary,
                                  onAccept: (p0) {
                                    imageFiles.removeWhere(
                                        (element) => element.path == value);
                                    setState(() {});
                                  },
                                );
                              },
                              onFileSelected: (List<File> files) async {
                                imageFiles = files;
                                setState(() {});
                              },
                            ),

                            16.height,

                            // Description
                            Text(
                              languages.shortDescription,
                              style: context.boldTextStyle(),
                            ),
                            8.height,
                            AppTextField(
                              textFieldType: TextFieldType.MULTILINE,
                              controller: descriptionCont,
                              focus: descriptionFocus,
                              minLines: 3,
                              maxLines: 10,
                              enableChatGPT:
                                  appConfigurationStore.chatGPTStatus,
                              promptFieldInputDecorationChatGPT:
                                  inputDecoration(context).copyWith(
                                hintText: languages.writeHere,
                                fillColor: context.profileInputFillColor,
                                filled: true,
                                hintStyle: context.primaryTextStyle(),
                              ),
                              isValidationRequired: false,
                              testWithoutKeyChatGPT:
                                  appConfigurationStore.testWithoutKey,
                              loaderWidgetForChatGPT:
                                  const ChatGPTLoadingWidget(),
                              decoration: inputDecoration(
                                context,
                                hintText: languages.eGHandymanTrustedService,
                                fillColor: context.profileInputFillColor,
                              ),
                            ),

                            16.height,

                            // Type Selection
                            Text(
                              languages.hintSelectType,
                              style: context.boldTextStyle(),
                            ),
                            8.height,
                            DropdownButtonFormField<StaticDataModel>(
                              decoration: inputDecoration(
                                context,
                                fillColor: context.profileInputFillColor,
                              ),
                              isExpanded: true,
                              initialValue: typeStaticData.first,
                              dropdownColor: context.cardSecondary,
                              items: typeStaticData.map((StaticDataModel data) {
                                return DropdownMenuItem<StaticDataModel>(
                                  value: data,
                                  child: Text(
                                    data.value.validate(),
                                    style: context.primaryTextStyle(),
                                  ),
                                );
                              }).toList(),
                              validator: (value) {
                                if (value == null)
                                  return errorThisFieldRequired;
                                return null;
                              },
                              onChanged: (StaticDataModel? value) async {
                                if (selectedService != null) {
                                  selectedService = null;
                                } else if (linkCont.text.isNotEmpty) {
                                  linkCont.clear();
                                }

                                selectedType = value!.key.validate();
                                setState(() {});
                              },
                            ),

                            16.height,

                            // Service Selection (if type is service)
                            if (selectedType == PROMOTIONAL_TYPE_SERVICE) ...[
                              Text(
                                languages.selectService,
                                style: context.boldTextStyle(),
                              ),
                              8.height,
                              DropdownButtonFormField<ServiceData>(
                                decoration: inputDecoration(
                                  context,
                                  fillColor: context.profileInputFillColor,
                                ),
                                hint: Text(
                                  languages.chooseService,
                                  style: context.secondaryTextStyle(),
                                ),
                                initialValue: selectedService,
                                dropdownColor: context.cardSecondary,
                                items: serviceList.map((data) {
                                  return DropdownMenuItem<ServiceData>(
                                    value: data,
                                    child: Text(
                                      data.name.validate(),
                                      style: context.primaryTextStyle(),
                                    ),
                                  );
                                }).toList(),
                                validator: (value) {
                                  if (value == null)
                                    return errorThisFieldRequired;

                                  return null;
                                },
                                onChanged: (ServiceData? value) async {
                                  selectedService = value!;

                                  setState(() {});
                                },
                              ),
                            ],

                            // Link Input (if type is link)
                            if (selectedType == PROMOTIONAL_TYPE_LINK) ...[
                              Text(
                                languages.enterLink,
                                style: context.boldTextStyle(),
                              ),
                              8.height,
                              AppTextField(
                                controller: linkCont,
                                focus: linkFocus,
                                textFieldType: TextFieldType.URL,
                                decoration: inputDecoration(
                                  context,
                                  hintText: languages.eGHttpsWwwYourlinkCom,
                                  fillColor: context.profileInputFillColor,
                                ),
                              ),
                            ],

                            // Date Range
                            DateRangeComponent(
                              padding: const EdgeInsets.only(top: 16),
                              onApplyCallback: (startDate, endDate, totalDays) {
                                if (startDate != null &&
                                    endDate != null &&
                                    totalDays != null) {
                                  startingDate = startDate;
                                  endingDate = endDate;

                                  totalDaysCount = totalDays;

                                  setState(() {});
                                }
                              },
                            ),

                            if (totalDaysCount.isNotEmpty)
                              Text(
                                languages.daysSelected(totalDaysCount),
                                style: context.boldTextStyle(
                                  color: context.primary,
                                  size: 12,
                                ),
                              ).paddingTop(8),

                            if (totalDaysCount.isNotEmpty &&
                                DateTime.parse(startingDate)
                                    .isAfter(DateTime.now())) ...[
                              16.height,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    languages.notes,
                                    style: context.boldTextStyle(size: 12),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    languages.selecteDateNote
                                        .replaceAll("{startDate}",
                                            startingDate.validate())
                                        .replaceAll(
                                            "{endDate}", endingDate.validate()),
                                    style: context.secondaryTextStyle(size: 12),
                                  ).expand(),
                                ],
                              ),
                            ],

                            // Payment Methods
                            if (paymentList.isNotEmpty) ...[
                              20.height,
                              Text(
                                languages.lblChoosePaymentMethod,
                                style: context.boldTextStyle(),
                              ),
                              8.height,
                              AnimatedListView(
                                itemCount: paymentList.length,
                                shrinkWrap: true,
                                listAnimationType: ListAnimationType.FadeIn,
                                physics: const NeverScrollableScrollPhysics(),
                                fadeInConfiguration:
                                    FadeInConfiguration(duration: 2.seconds),
                                emptyWidget: NoDataWidget(
                                  imageWidget: const EmptyStateWidget(),
                                  title: languages.noPaymentMethodsFound,
                                ),
                                itemBuilder: (context, index) {
                                  PaymentSetting paymentData =
                                      paymentList[index];

                                  return RadioGroup<PaymentSetting>(
                                    groupValue: selectedPaymentSetting,
                                    onChanged: (value) {
                                      selectedPaymentSetting = value;
                                      setState(() {});
                                    },
                                    child: RadioListTile<PaymentSetting>(
                                      dense: true,
                                      activeColor: context.primary,
                                      value: paymentData,
                                      controlAffinity:
                                          ListTileControlAffinity.trailing,
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      title: Text(
                                        paymentData.title.validate(),
                                        style: context.primaryTextStyle(),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              16.height,

                              // Total Amount Card
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: boxDecorationDefault(
                                  borderRadius: radius(12),
                                  color: context.cardSecondary,
                                  border: Border.all(
                                    color: context.cardSecondaryBorder,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      languages.lblTotalAmount,
                                      style: context.boldTextStyle(),
                                    ),
                                    16.width,
                                    Observer(builder: (context) {
                                      return PriceWidget(
                                        price: totalAmount.toDouble(),
                                        color: context.primaryLiteColor,
                                        isBoldText: true,
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              16.height,
                            ],
                          ],
                        ),
                      ).paddingSymmetric(horizontal: 16),
                    ],
                  ),
                ).expand(),

                // Submit Button
                Observer(
                  builder: (_) => AppButton(
                    margin:
                        const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                    text:
                        isPaymentPending ? languages.pay : languages.lblSubmit,
                    height: 40,
                    color: appStore.isLoading
                        ? context.primary.withValues(alpha: 0.5)
                        : context.primary,
                    textStyle: context.boldTextStyle(color: context.onPrimary),
                    width: context.width(),
                    onTap: appStore.isLoading
                        ? () {}
                        : () {
                            if (isPaymentPending) {
                              _handleClick(); // Retry payment if pending
                            } else {
                              checkValidation(); // Submit form and proceed to payment
                            }
                          },
                  ),
                ),
              ],
            ),
            Observer(
                builder: (_) =>
                    LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }

  num get totalAmount => (appConfigurationStore.bannerPerDayAmount *
      totalDaysCount.toInt(defaultValue: 1));
}
