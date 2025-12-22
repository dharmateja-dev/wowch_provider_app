import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/notification_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/notification_list_response.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/services/service_detail_screen.dart';
import 'package:handyman_provider_flutter/provider/wallet/wallet_history_screen.dart';
import 'package:handyman_provider_flutter/screens/booking_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_data.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/app_widgets.dart';
import '../components/base_scaffold_widget.dart';
import '../components/empty_error_state_widget.dart';

class NotificationFragment extends StatefulWidget {
  @override
  NotificationScreenState createState() => NotificationScreenState();
}

class NotificationScreenState extends State<NotificationFragment> {
  late Future<List<NotificationData>> future;
  List<NotificationData> list = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();

    LiveStream().on(LIVESTREAM_UPDATE_NOTIFICATIONS, (p0) {
      appStore.setLoading(true);

      init(type: MARK_AS_READ);
      setState(() {});
    });
    init();
  }

  Future<void> init({String type = ''}) async {
    // Demo Mode: Use demo data instead of backend API
    if (DEMO_MODE_ENABLED) {
      list = demoNotifications;
      cachedNotifications = list;
      future = Future.value(list);
      setState(() {});
      return;
    }

    future = getNotification(
      {NotificationKey.type: type},
      notificationList: list,
      lastPageCallback: (val) => isLastPage = val,
    );
  }

  Future<void> readNotificationGeneric(
      {required String type, String? id}) async {
    //TODO: check for booking_id
    // Map request = {CommonKeys.bookingId: id};
    Map request = {CommonKeys.serviceId: id};

    try {
      if (type == 'booking') {
        await bookingDetail(request);
      } else if (type == 'service') {
        await getServiceDetail(request);
      }
      init();
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose(LIVESTREAM_UPDATE_NOTIFICATIONS);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldBackgroundColor: context.scaffoldSecondary,
      appBarTitle: Navigator.canPop(context) ? languages.notification : null,
      actions: [
        IconButton(
          icon: Icon(Icons.clear_all_rounded, color: context.onPrimary),
          onPressed: () async {
            showConfirmDialogCustom(
              context,
              onAccept: (_) async {
                appStore.setLoading(true);

                init(type: MARK_AS_READ);
                setState(() {});
              },
              dialogType: DialogType.CONFIRMATION,
              height: 80,
              width: 290,
              shape: appDialogShape(8),
              backgroundColor: context.dialogBackgroundColor,
              titleColor: context.dialogTitleColor,
              primaryColor: context.primary,
              customCenterWidget: Image.asset(
                ic_warning,
                color: context.dialogIconColor,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
              ),
              negativeText: languages.lblNo,
              negativeTextColor: context.dialogCancelColor,
              positiveText: languages.lblYes,
              positiveTextColor: context.onPrimary,
              title: languages.confirmationRequestTxt,
            );
          },
        ),
      ],
      body: SnapHelperWidget<List<NotificationData>>(
        initialData: cachedNotifications,
        future: future,
        loadingWidget: LoaderWidget(),
        onSuccess: (list) {
          return AnimatedListView(
            itemCount: list.length,
            shrinkWrap: true,
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            emptyWidget: NoDataWidget(
              title: languages.noNotificationTitle,
              subTitle: languages.noNotificationSubTitle,
              imageWidget: const EmptyStateWidget(),
            ),
            itemBuilder: (context, index) {
              NotificationData data = list[index];
              return GestureDetector(
                onTap: () async {
                  if (isUserTypeHandyman) {
                    if (data.data!.notificationType
                        .validate()
                        .contains(BOOKING)) {
                      readNotificationGeneric(
                          type: 'booking', id: data.data!.id.toString());
                      BookingDetailScreen(bookingId: data.data!.id)
                          .launch(context);
                    } else {
                      //
                    }
                  } else if (isUserTypeProvider) {
                    if (data.data!.notificationType
                            .validate()
                            .contains(WALLET) ||
                        data.data!.notificationType
                            .validate()
                            .contains(PAYOUT) ||
                        data.data!.notificationType
                            .validate()
                            .contains(WITHDRAW)) {
                      WalletHistoryScreen().launch(context);
                    } else if (data.data!.notificationType
                            .validate()
                            .contains(BOOKING) ||
                        data.data!.notificationType
                            .validate()
                            .contains(PAYMENT_MESSAGE_STATUS)) {
                      readNotificationGeneric(
                          type: 'booking', id: data.data!.id.toString());
                      BookingDetailScreen(bookingId: data.data!.id)
                          .launch(context);
                    }

                    ///handle post job detail on notification click
                    /*else if (data.data!.notificationType.validate().contains(POSTJOB)) {
                      readNotification(id: data.data!.id.toString());
                      getPostJobDetail({PostJob.postRequestId: data.data!.id}).then((response) {
                        if (response.postRequestDetail != null) {
                          JobPostDetailScreen(postJobData: response.postRequestDetail!).launch(context);
                        } else {
                          toast("Post job data not found.");
                        }
                      }).catchError((e) {
                        toast(e.toString());
                      });
                    }*/
                    else if (data.data!.notificationType
                            .validate()
                            .contains(SERVICE_REQUEST_APPROVE) ||
                        data.data!.notificationType
                            .validate()
                            .contains(SERVICE_REQUEST_REJECT)) {
                      readNotificationGeneric(
                          type: 'service', id: data.data!.id.toString());
                      ServiceDetailScreen(serviceId: data.data!.id)
                          .launch(context);
                    } else {
                      //
                    }
                  }
                },
                child: NotificationWidget(data: data),
              );
            },
            onSwipeRefresh: () async {
              page = 1;
              init();
              setState(() {});
              return await 2.seconds.delay;
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
}
