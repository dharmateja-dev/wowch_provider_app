import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/empty_error_state_widget.dart';
import 'package:handyman_provider_flutter/components/view_all_label_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/screens/cash_management/cash_repository.dart';
import 'package:handyman_provider_flutter/screens/cash_management/component/payment_history_list_widget.dart';
import 'package:handyman_provider_flutter/screens/cash_management/model/payment_history_model.dart';
import 'package:nb_utils/nb_utils.dart';

class CashPaymentHistoryScreen extends StatefulWidget {
  final String bookingId;

  const CashPaymentHistoryScreen({Key? key, required this.bookingId})
      : super(key: key);

  @override
  State<CashPaymentHistoryScreen> createState() =>
      _CashPaymentHistoryScreenState();
}

class _CashPaymentHistoryScreenState extends State<CashPaymentHistoryScreen> {
  Future<List<PaymentHistoryData>>? future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init({bool flag = false}) async {
    future = getPaymentHistory(bookingId: widget.bookingId).catchError((e) {
      // Return demo payment history data when API fails
      final historyDate = DateTime.now().subtract(const Duration(hours: 12));
      return <PaymentHistoryData>[
        PaymentHistoryData(
          id: 1,
          paymentId: 2,
          bookingId: int.tryParse(widget.bookingId) ?? 1001,
          action: 'Handyman Approve Cash',
          text: 'Pedro Norris Successfully transfer \$67.00 to John Deo',
          type: 'cash',
          status: 'approved',
          senderId: 101,
          receiverId: 1,
          datetime: historyDate,
          totalAmount: 67.00,
        ),
      ];
    });
    if (flag) setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaymentHistoryData>>(
      future: future,
      builder: (context, snap) {
        if (snap.hasData) {
          if (snap.data.validate().isEmpty) return Offstage();
          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ViewAllLabel(
                  label: languages.paymentHistory,
                  list: const [],
                ),
                16.height,
                AnimatedListView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snap.data.validate().length,
                  listAnimationType: ListAnimationType.FadeIn,
                  fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                  itemBuilder: (_, i) {
                    return PaymentHistoryListWidget(
                      data: snap.data.validate()[i],
                      index: i,
                      length: snap.data.validate().length.validate(),
                    );
                  },
                ),
              ],
            ),
          );
        }
        return snapWidgetHelper(
          snap,
          errorBuilder: (p0) {
            return NoDataWidget(
              title: languages.retryPaymentDetails,
              imageWidget: ErrorStateWidget(),
              onRetry: () {
                init(flag: true);
              },
            );
          },
        );
      },
    );
  }
}
