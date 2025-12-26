import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:intl/intl.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime? minimumDate;
  final DateTime? maximumDate;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Color primaryColor;
  final Color disabledDateColor;
  final Function(DateTime, DateTime)? startEndDateChange;

  const CustomCalendar({
    Key? key,
    this.initialStartDate,
    this.initialEndDate,
    this.startEndDateChange,
    this.minimumDate,
    this.maximumDate,
    required this.primaryColor,
    required this.disabledDateColor,
  }) : super(key: key);

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  List<DateTime> dateList = <DateTime>[];
  DateTime currentMonthDate = DateTime.now();
  DateTime? startDate;
  DateTime? endDate;
  DateTime? selectedDate;

  @override
  void initState() {
    setListOfDate(currentMonthDate);
    if (widget.initialStartDate != null) {
      startDate = widget.initialStartDate;
    }
    if (widget.initialEndDate != null) {
      endDate = widget.initialEndDate;
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void setListOfDate(DateTime monthDate) {
    dateList.clear();
    final DateTime newDate = DateTime(monthDate.year, monthDate.month, 0);
    int previousMothDay = 0;
    if (newDate.weekday < 7) {
      previousMothDay = newDate.weekday;
      for (int i = 1; i <= previousMothDay; i++) {
        dateList.add(newDate.subtract(Duration(days: previousMothDay - i)));
      }
    }
    for (int i = 0; i < (42 - previousMothDay); i++) {
      dateList.add(newDate.add(Duration(days: i + 1)));
    }
  }

  bool _isDateDisabled(DateTime date) {
    if (widget.minimumDate != null && widget.maximumDate != null) {
      return date.isBefore(widget.minimumDate!) ||
          date.isAfter(widget.maximumDate!);
    } else if (widget.minimumDate != null) {
      return date.isBefore(widget.minimumDate!);
    } else if (widget.maximumDate != null) {
      return date.isAfter(widget.maximumDate!);
    }
    return false;
  }

  bool _isCurrentMonth(DateTime date) {
    return date.month == currentMonthDate.month;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: <Widget>[
          // Month navigation header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: <Widget>[
                // Previous month button
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.mainBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          currentMonthDate = DateTime(
                            currentMonthDate.year,
                            currentMonthDate.month - 1,
                          );
                          setListOfDate(currentMonthDate);
                        });
                      },
                      child: Icon(
                        Icons.chevron_left,
                        color: context.icon,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                // Month and year text
                Expanded(
                  child: Center(
                    child: Text(
                      DateFormat('MMMM yyyy').format(currentMonthDate),
                      style: context.boldTextStyle(),
                    ),
                  ),
                ),
                // Next month button
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: context.mainBorderColor,
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        setState(() {
                          currentMonthDate = DateTime(
                            currentMonthDate.year,
                            currentMonthDate.month + 2,
                            0,
                          );
                          setListOfDate(currentMonthDate);
                        });
                      },
                      child: Icon(
                        Icons.chevron_right,
                        color: context.icon,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Day names row
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: getDaysNameUI(),
            ),
          ),
          // Calendar grid
          Column(
            children: getDaysNoUI(),
          ),
        ],
      ),
    );
  }

  List<Widget> getDaysNameUI() {
    final List<String> dayNames = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return dayNames.map((day) {
      return Expanded(
        child: Center(
          child: Text(
            day,
            style: context.primaryTextStyle(color: context.textGrey),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> getDaysNoUI() {
    final List<Widget> noList = <Widget>[];
    int count = 0;

    for (int i = 0; i < dateList.length / 7; i++) {
      final List<Widget> listUI = <Widget>[];
      for (int j = 0; j < 7; j++) {
        final DateTime date = dateList[count];
        final bool isDisabled = _isDateDisabled(date);
        final bool isCurrentMonth = _isCurrentMonth(date);
        final bool isStartDate = _isStartDate(date);
        final bool isEndDate = _isEndDate(date);
        final bool isInRange = getIsInRange(date);
        final bool isStartOrEnd = isStartDate || isEndDate;

        listUI.add(
          Expanded(
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Stack(
                children: <Widget>[
                  // Range highlight background
                  if (startDate != null && endDate != null && isCurrentMonth)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        margin: EdgeInsets.only(
                          left: isStartDate ? 4 : 0,
                          right: isEndDate ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: (isStartOrEnd || isInRange)
                              ? context.secondaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.only(
                            topLeft:
                                isStartDate ? Radius.circular(8) : Radius.zero,
                            bottomLeft:
                                isStartDate ? Radius.circular(8) : Radius.zero,
                            topRight:
                                isEndDate ? Radius.circular(8) : Radius.zero,
                            bottomRight:
                                isEndDate ? Radius.circular(8) : Radius.zero,
                          ),
                        ),
                      ),
                    ),
                  // Date cell
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: isDisabled ? null : () => onDateClick(date),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isStartOrEnd && isCurrentMonth
                              ? widget.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: _getTextColor(
                                date,
                                isDisabled,
                                isCurrentMonth,
                                isStartOrEnd,
                              ),
                              fontSize: 14,
                              fontWeight: isStartOrEnd
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Today indicator
                  if (_isToday(date) && isCurrentMonth && !isStartOrEnd)
                    Positioned(
                      bottom: 6,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          height: 4,
                          width: 4,
                          decoration: BoxDecoration(
                            color: widget.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
        count += 1;
      }
      noList.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: listUI,
        ),
      );
    }
    return noList;
  }

  Color _getTextColor(
    DateTime date,
    bool isDisabled,
    bool isCurrentMonth,
    bool isStartOrEnd,
  ) {
    if (!isCurrentMonth) {
      return widget.disabledDateColor.withValues(alpha: 0.4);
    }
    if (isStartOrEnd) {
      return context.onPrimary;
    }
    if (isDisabled) {
      return widget.disabledDateColor;
    }
    return Colors.grey.shade800;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  bool _isStartDate(DateTime date) {
    if (startDate == null) return false;
    return startDate!.day == date.day &&
        startDate!.month == date.month &&
        startDate!.year == date.year;
  }

  bool _isEndDate(DateTime date) {
    if (endDate == null) return false;
    return endDate!.day == date.day &&
        endDate!.month == date.month &&
        endDate!.year == date.year;
  }

  bool getIsInRange(DateTime date) {
    if (startDate != null && endDate != null) {
      return date.isAfter(startDate!) && date.isBefore(endDate!);
    }
    return false;
  }

  bool getIsItStartAndEndDate(DateTime date) {
    return _isStartDate(date) || _isEndDate(date);
  }

  bool isStartDateRadius(DateTime date) {
    if (_isStartDate(date)) return true;
    return date.weekday == DateTime.sunday;
  }

  bool isEndDateRadius(DateTime date) {
    if (_isEndDate(date)) return true;
    return date.weekday == DateTime.saturday;
  }

  void onDateClick(DateTime date) {
    if (startDate == null) {
      startDate = date;
    } else if (startDate != date && endDate == null) {
      endDate = date;
    } else if (_isStartDate(date)) {
      startDate = null;
    } else if (_isEndDate(date)) {
      endDate = null;
    }

    if (startDate == null && endDate != null) {
      startDate = endDate;
      endDate = null;
    }

    if (startDate != null && endDate != null) {
      if (!endDate!.isAfter(startDate!)) {
        final DateTime temp = startDate!;
        startDate = endDate;
        endDate = temp;
      }
      if (date.isBefore(startDate!)) {
        startDate = date;
      }
      if (date.isAfter(endDate!)) {
        endDate = date;
      }
    }

    setState(() {
      try {
        widget.startEndDateChange!(startDate!, endDate!);
      } catch (_) {}
    });
  }
}
