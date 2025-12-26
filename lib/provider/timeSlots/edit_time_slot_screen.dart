import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/components/available_slots_component.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/components/days_bottom_sheet.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/models/slot_data.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class EditTimeSlotScreen extends StatefulWidget {
  final List<SlotData> slotData;
  final String? selectedDay;
  final Function(List<SlotData>) onSave;

  EditTimeSlotScreen(
      {required this.slotData, this.selectedDay, required this.onSave});

  @override
  EditTimeSlotScreenState createState() => EditTimeSlotScreenState();
}

class EditTimeSlotScreenState extends State<EditTimeSlotScreen> {
  UniqueKey keyForTimeSlotWidget = UniqueKey();
  int selectedDayIndex = 0;

  List<String> selectedTimeSlots = [];

  String selectedDay = daysList.first;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    daysList.forEach((element) {
      if (element == widget.selectedDay) {
        selectedDayIndex = daysList.indexOf(element);
        selectedDay = element.validate();
        keyForTimeSlotWidget = UniqueKey();
      }
    });
  }

  Future saveTimeSlot() async {
    timeSlotStore.serviceSlotData = widget.slotData;
    finish(context, true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.primary,
        leading: BackWidget(color: context.onPrimary),
        title: Text(
          languages.timeSlots,
          style: context.boldTextStyle(color: context.onPrimary, size: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day Selection Section
                Text(
                  languages.selectYourDay,
                  style: context.boldTextStyle(),
                ),
                16.height,

                // Days Selection Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: boxDecorationDefault(
                    color: context.cardSecondary,
                    borderRadius: radius(12),
                    border: Border.all(color: context.cardSecondaryBorder),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(daysList.length, (index) {
                        String data = daysList[index];
                        bool isSelected = selectedDayIndex == index;

                        return GestureDetector(
                          onTap: () {
                            selectedDayIndex = index;
                            selectedDay = data.validate();
                            keyForTimeSlotWidget = UniqueKey();
                            setState(() {});
                          },
                          child: Container(
                            height: 50,
                            width: 55,
                            margin: EdgeInsets.only(
                                right: index < daysList.length - 1 ? 12 : 0),
                            alignment: Alignment.center,
                            decoration: boxDecorationDefault(
                              color: isSelected
                                  ? context.primary
                                  : context.profileInputFillColor,
                              borderRadius: radius(8),
                              border: Border.all(
                                color: isSelected
                                    ? context.primary
                                    : context.cardSecondaryBorder,
                              ),
                            ),
                            child: Text(
                              data.validate().toUpperCase(),
                              style: context.boldTextStyle(
                                size: 12,
                                color: isSelected
                                    ? context.onPrimary
                                    : context.onSurface,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                24.height,

                // Choose Time Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      languages.chooseTime,
                      style: context.boldTextStyle(),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        languages.copyTo,
                        style: context.primaryTextStyle(
                          color: context.primary,
                          size: 14,
                        ),
                      ),
                      onPressed: () async {
                        List<String> list = await showModalBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          isScrollControlled: true,
                          isDismissible: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: radiusOnly(
                                topLeft: defaultRadius,
                                topRight: defaultRadius),
                          ),
                          builder: (_) {
                            return DaysBottomSheet(selectedDay: selectedDay);
                          },
                        );

                        list.forEach((element) {
                          widget.slotData.removeWhere((e) =>
                              e.day.validate().toLowerCase() ==
                              element.toLowerCase());
                          widget.slotData.add(SlotData(
                              day: element.toLowerCase(),
                              slot: selectedTimeSlots.toSet().toList()));
                        });

                        keyForTimeSlotWidget = UniqueKey();
                        setState(() {});
                      },
                    ),
                  ],
                ),

                16.height,

                // Available Slots Component
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: boxDecorationDefault(
                    color: context.cardSecondary,
                    borderRadius: radius(12),
                    border: Border.all(color: context.cardSecondaryBorder),
                  ),
                  child: AvailableSlotsComponent(
                    key: keyForTimeSlotWidget,
                    onChanged: (List<String> selectedSlots) {
                      selectedTimeSlots = selectedSlots;
                      setState(() {});
                    },
                    availableSlots: [],
                    selectedSlots: widget.slotData
                        .firstWhere(
                            (element) =>
                                element.day.validate().toLowerCase() ==
                                selectedDay.toLowerCase(),
                            orElse: () => SlotData(slot: [], day: ''))
                        .slot
                        .validate(),
                  ),
                ),
              ],
            ),
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardSecondary,
          boxShadow: [
            BoxShadow(
              color: context.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: AppButton(
          width: context.width(),
          color: context.primary,
          textColor: context.onPrimary,
          shapeBorder: RoundedRectangleBorder(borderRadius: radius(8)),
          text: languages.lblUpdate,
          textStyle: context.boldTextStyle(color: context.onPrimary),
          onTap: () {
            widget.slotData.removeWhere((e) =>
                e.day.validate().toLowerCase() == dayListMap[selectedDay]);
            widget.slotData.add(SlotData(
                day: dayListMap[selectedDay],
                slot: selectedTimeSlots.toSet().toList()));
            widget.onSave.call(widget.slotData);
            setState(() {});
          },
        ),
      ),
    );
  }
}
