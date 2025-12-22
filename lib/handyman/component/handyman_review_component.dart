import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/review_list_view_component.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/screens/rating_view_all_screen.dart';
import 'package:handyman_provider_flutter/utils/demo_data.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanReviewComponent extends StatefulWidget {
  final List<RatingData>? reviews;

  HandymanReviewComponent({this.reviews});

  @override
  _HandymanReviewComponentState createState() =>
      _HandymanReviewComponentState();
}

class _HandymanReviewComponentState extends State<HandymanReviewComponent> {
  /// Get reviews - use demo data if empty for UI testing
  List<RatingData> get _reviews {
    if (widget.reviews != null && widget.reviews!.isNotEmpty) {
      return widget.reviews!;
    }
    // Use demo data for UI testing
    return DemoReviewData.reviewsJson
        .map((json) => RatingData.fromJson(json))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ViewAllLabel(
              label: languages.review,
              list: _reviews,
              onTap: () {
                RatingViewAllScreen(
                        handymanId: appStore.userId,
                        title: languages.review,
                        showServiceName: true)
                    .launch(context);
              },
            ).paddingSymmetric(horizontal: 16),
            ReviewListViewComponent(
              ratings: _reviews,
              physics: const NeverScrollableScrollPhysics(),
              showServiceName: true,
              isCustomer: true,
              padding: const EdgeInsets.only(
                  left: 16, right: 16, bottom: 8, top: 16),
            ),
            Observer(
              builder: (_) => Text(
                languages.lblNoReviewYet,
                style: secondaryTextStyle(),
              ).center().visible(!appStore.isLoading && _reviews.isEmpty),
            ),
          ],
        ),
        Observer(
          builder: (_) => LoaderWidget().center().visible(appStore.isLoading),
        ),
      ],
    );
  }
}
