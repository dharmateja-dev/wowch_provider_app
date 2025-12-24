import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/image_border_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/booking_detail_response.dart';
import 'package:handyman_provider_flutter/provider/services/service_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

/// Helper function to format review date with fallback
String _formatReviewDate(String dateString) {
  try {
    // Try parsing ISO 8601 format first
    DateTime date = DateTime.parse(dateString);
    return DateFormat('dd MMM yyyy').format(date);
  } catch (e) {
    try {
      // Try parsing yyyy-MM-dd HH:mm:ss format
      DateTime date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      // Return original string if parsing fails
      return dateString;
    }
  }
}

class ReviewWidget extends StatelessWidget {
  final RatingData data;
  final bool isCustomer;
  final bool showServiceName;

  ReviewWidget(
      {required this.data,
      this.isCustomer = false,
      this.showServiceName = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (showServiceName) {
          ServiceDetailScreen(serviceId: data.serviceId.validate().toInt())
              .launch(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        width: context.width(),
        decoration: boxDecorationDefault(
          color: context.cardSecondary,
          border: Border.all(color: context.cardSecondaryBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ImageBorder(
                src: data.profileImage.validate().isNotEmpty
                    ? data.profileImage.validate()
                    : (isCustomer
                        ? data.customerProfileImage.validate()
                        : data.handymanProfileImage.validate()),
                height: 45),
            16.width,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                data.customerName.validate().isNotEmpty
                                    ? data.customerName.validate()
                                    : "New booking received",
                                style: context.boldTextStyle(size: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            4.height,
                            if (data.createdAt.validate().isNotEmpty)
                              Text(_formatReviewDate(data.createdAt.validate()),
                                  style: context.primaryTextStyle(
                                      size: 12, color: context.textGrey)),
                          ],
                        ),
                      ),
                      8.width,
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(ic_star_fill,
                              height: 16, color: context.starColor),
                          4.width,
                          Text('${data.rating.validate().toStringAsFixed(1)}',
                              style: context.boldTextStyle(size: 14)),
                        ],
                      ),
                    ],
                  ),
                  if (data.review.validate().isNotEmpty) ...[
                    8.height,
                    Text(
                      data.review.validate(),
                      style: context.primaryTextStyle(size: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (showServiceName)
                    Text('${languages.lblService}: ${data.serviceName.validate()}',
                            style: context.primaryTextStyle(size: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis)
                        .paddingTop(6),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
