import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';

import 'custom_calendar.dart';
import 'package:flutter/material.dart';

class CustomDateRangePicker extends StatefulWidget {
  final DateTime minimumDate;
  final DateTime maximumDate;
  final bool barrierDismissible;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Color primaryColor;
  final Color backgroundColor;
  final Function(DateTime, DateTime) onApplyClick;
  final Function() onCancelClick;
  final Color disabledDateColor;

  const CustomDateRangePicker({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    required this.primaryColor,
    required this.backgroundColor,
    required this.onApplyClick,
    this.barrierDismissible = true,
    required this.minimumDate,
    required this.maximumDate,
    required this.onCancelClick,
    required this.disabledDateColor,
  }) : super(key: key);

  @override
  CustomDateRangePickerState createState() => CustomDateRangePickerState();
}

class CustomDateRangePickerState extends State<CustomDateRangePicker>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
    animationController?.forward();
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            if (widget.barrierDismissible) {
              Navigator.pop(context);
            }
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: InkWell(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Calendar widget
                      CustomCalendar(
                        minimumDate: widget.minimumDate,
                        maximumDate: widget.maximumDate,
                        initialEndDate: widget.initialEndDate,
                        initialStartDate: widget.initialStartDate,
                        primaryColor: widget.primaryColor,
                        disabledDateColor: widget.disabledDateColor,
                        startEndDateChange:
                            (DateTime startDateData, DateTime endDateData) {
                          setState(() {
                            startDate = startDateData;
                            endDate = endDateData;
                          });
                        },
                      ),
                      // Buttons
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 16,
                          top: 8,
                        ),
                        child: Row(
                          children: [
                            // Cancel button - outlined style
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: widget.primaryColor,
                                      width: 1.5,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  onPressed: () {
                                    widget.onCancelClick();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Cancel',
                                    style: context.primaryTextStyle(
                                        color: context.primary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Apply button - filled style
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: widget.primaryColor,
                                    foregroundColor: context.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    if (startDate != null && endDate != null) {
                                      widget.onApplyClick(startDate!, endDate!);
                                      Navigator.pop(context);
                                    }
                                  },
                                  child: Text(
                                    'Apply',
                                    style: context.primaryTextStyle(
                                        color: context.onPrimary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showCustomDateRangePicker(
  BuildContext context, {
  required bool dismissible,
  required DateTime minimumDate,
  required DateTime maximumDate,
  DateTime? startDate,
  DateTime? endDate,
  required Function(DateTime startDate, DateTime endDate) onApplyClick,
  required Function() onCancelClick,
  required Color backgroundColor,
  required Color primary,
  required Color disabledDateColor,
}) {
  showDialog<dynamic>(
    context: context,
    builder: (BuildContext context) => CustomDateRangePicker(
      barrierDismissible: dismissible,
      backgroundColor: backgroundColor,
      primaryColor: primary,
      minimumDate: minimumDate,
      maximumDate: maximumDate,
      initialStartDate: startDate,
      initialEndDate: endDate,
      onApplyClick: onApplyClick,
      onCancelClick: onCancelClick,
      disabledDateColor: disabledDateColor,
    ),
  );
}
