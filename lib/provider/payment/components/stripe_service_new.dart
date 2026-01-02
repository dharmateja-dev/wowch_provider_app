import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../models/stripe_pay_model.dart';
import '../../../networks/network_utils.dart';
import '../../../utils/app_configuration.dart';
import '../../../utils/common.dart';
import '../../../utils/configs.dart';

class StripeServiceNew {
  late PaymentSetting paymentSetting;
  num totalAmount = 0;
  late Function(Map<String, dynamic>) onComplete;

  StripeServiceNew({
    required PaymentSetting paymentSetting,
    required num totalAmount,
    required Function(Map<String, dynamic>) onComplete,
  }) {
    this.paymentSetting = paymentSetting;
    this.totalAmount = totalAmount;
    this.onComplete = onComplete;
  }

  //StripPayment
  Future<dynamic> stripePay() async {
    // Load Stripe keys from environment variables
    // These are set in the .env file at project root
    String stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';
    String stripePublishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
    String stripeURL = dotenv.env['STRIPE_API_URL'] ??
        'https://api.stripe.com/v1/payment_intents';

    // Validate that environment variables are set
    if (stripeSecretKey.isEmpty || stripePublishableKey.isEmpty) {
      log('ERROR: Stripe keys not found in .env file');
      throw 'Stripe configuration error. Please check .env file.';
    }

    // Try to use backend values if available, otherwise use .env keys
    try {
      if (paymentSetting.isTest == 1 && paymentSetting.testValue != null) {
        if (paymentSetting.testValue!.stripeKey?.isNotEmpty == true) {
          stripeSecretKey = paymentSetting.testValue!.stripeKey!;
        }
        if (paymentSetting.testValue!.stripeUrl?.isNotEmpty == true) {
          stripeURL = paymentSetting.testValue!.stripeUrl!;
        }
        if (paymentSetting.testValue!.stripePublickey?.isNotEmpty == true) {
          stripePublishableKey = paymentSetting.testValue!.stripePublickey!;
        }
      } else if (paymentSetting.liveValue != null) {
        if (paymentSetting.liveValue!.stripeKey?.isNotEmpty == true) {
          stripeSecretKey = paymentSetting.liveValue!.stripeKey!;
        }
        if (paymentSetting.liveValue!.stripeUrl?.isNotEmpty == true) {
          stripeURL = paymentSetting.liveValue!.stripeUrl!;
        }
        if (paymentSetting.liveValue!.stripePublickey?.isNotEmpty == true) {
          stripePublishableKey = paymentSetting.liveValue!.stripePublickey!;
        }
      }
    } catch (e) {
      log('Using .env Stripe keys');
    }

    log('Stripe Secret Key: ${stripeSecretKey.substring(0, 20)}...');
    log('Stripe Publishable Key: ${stripePublishableKey.substring(0, 20)}...');
    log('Stripe URL: $stripeURL');

    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    Stripe.publishableKey = stripePublishableKey;

    Request request =
        http.Request(HttpMethodType.POST.name, Uri.parse(stripeURL));

    request.bodyFields = {
      'amount': '${(totalAmount * 100).toInt()}',
      'currency': 'usd', // Hardcoded USD for demo mode with US test keys
      'description':
          'Name: ${appStore.userFullName} - Email: ${appStore.userEmail}',
    };

    request.headers.addAll(buildHeaderForStripe(stripeSecretKey));

    log('URL: ${request.url}');
    log('Request: ${request.bodyFields}');

    appStore.setLoading(true);
    await request.send().then((value) {
      http.Response.fromStream(value).then((response) async {
        appStore.setLoading(false);
        log('Stripe Response Status: ${response.statusCode}');
        log('Stripe Response Body: ${response.body}');

        if (response.statusCode.isSuccessful()) {
          StripePayModel res =
              StripePayModel.fromJson(jsonDecode(response.body));

          SetupPaymentSheetParameters setupPaymentSheetParameters =
              SetupPaymentSheetParameters(
            paymentIntentClientSecret: res.clientSecret.validate(),
            style: appThemeMode,
            appearance: PaymentSheetAppearance(
              colors: PaymentSheetAppearanceColors(primary: primary),
            ),
            applePay: PaymentSheetApplePay(
                merchantCountryCode: STRIPE_MERCHANT_COUNTRY_CODE),
            googlePay: PaymentSheetGooglePay(
              merchantCountryCode: STRIPE_MERCHANT_COUNTRY_CODE,
              testEnv: true,
            ),
            merchantDisplayName: APP_NAME,
            billingDetails: BillingDetails(
              name: appStore.userFullName,
              email: appStore.userEmail,
            ),
          );

          await Stripe.instance
              .initPaymentSheet(
                  paymentSheetParameters: setupPaymentSheetParameters)
              .then((value) async {
            await Stripe.instance.presentPaymentSheet().then((value) async {
              onComplete.call({'transaction_id': res.id});
            }).catchError((e, s) {
              log('Stripe PaymentSheet Error: $e');
              appStore.setLoading(false);
              throw 'Payment failed. Try again.';
            });
          }).catchError((e, s) {
            log('Stripe InitPaymentSheet Error: $e');
            appStore.setLoading(false);
            throw 'Unable to initiate payment. Try again.';
          });
        } else {
          appStore.setLoading(false);
          log('Stripe API Error ${response.statusCode}: ${response.body}');
          throw 'Stripe Error: ${response.statusCode}';
        }
      }).catchError((e) {
        appStore.setLoading(false);
        log('Stripe Response Error: $e');
        throw e.toString();
      });
    }).catchError((e) {
      appStore.setLoading(false);
      log('Stripe Request Error: $e');
      toast(e.toString(), print: true);
      throw e.toString();
    });
  }
}
