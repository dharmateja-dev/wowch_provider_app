import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/components/slot_widget.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

class AvailableSlotsComponent extends StatefulWidget {
  final List<String>? selectedSlots;
  final List<String> availableSlots;
  final Function(List<String> selectedSlots) onChanged;
  final bool? isProvider;

  AvailableSlotsComponent(
      {this.selectedSlots,
      required this.availableSlots,
      required this.onChanged,
      this.isProvider = true,
      Key? key})
      : super(key: key);

  @override
  _AvailableSlotsComponentState createState() =>
      _AvailableSlotsComponentState();
}

class _AvailableSlotsComponentState extends State<AvailableSlotsComponent> {
  List<String> localSelectedSlot = [];
  int selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  void init() async {
    if (widget.selectedSlots.validate().isNotEmpty) {
      localSelectedSlot = widget.selectedSlots.validate();
      widget.onChanged.call(localSelectedSlot);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    // Calculate slot width for 3 columns
    // Screen width - outer padding(16*2) - container padding(16*2) - spacing between slots(12*2)
    double availableWidth = context.width() - 32 - 32 - 24;
    double slotWidth = availableWidth / 3;

    if (widget.isProvider.validate()) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // Use LayoutBuilder to get actual available width
          double actualSlotWidth =
              (constraints.maxWidth - 24) / 3; // 24 = spacing (12 * 2)

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(24, (index) {
              String value =
                  "${(index + 1).toString().length >= 2 ? index + 1 : '0${index + 1}'}:00:00";

              bool isSelected = localSelectedSlot.contains(value);

              return SlotWidget(
                isAvailable: false,
                isSelected: isSelected,
                activeColor: context.primary,
                width: actualSlotWidth,
                value: value,
                onTap: () {
                  if (isSelected) {
                    localSelectedSlot.remove(value);
                  } else {
                    localSelectedSlot.add(value);
                  }

                  setState(() {});

                  widget.onChanged.call(localSelectedSlot);
                },
              );
            }),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double actualSlotWidth = (constraints.maxWidth - 24) / 3;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(widget.availableSlots.length, (index) {
            String value = widget.availableSlots[index];

            if (widget.selectedSlots.validate().isNotEmpty) {
              if (widget.selectedSlots.validate().first == value) {
                selectedIndex = index;
              }
            }
            bool isSelected = selectedIndex == index;
            bool isAvailable = widget.availableSlots.contains(value);

            return SlotWidget(
              isAvailable: isAvailable,
              isSelected: isSelected,
              activeColor: context.primary,
              width: actualSlotWidth,
              value: value,
              onTap: () {
                if (isAvailable) {
                  if (isSelected) {
                    selectedIndex = -1;
                    widget.onChanged.call([]);
                  } else {
                    selectedIndex = index;
                    widget.onChanged.call([value]);
                  }
                  setState(() {});
                } else {
                  toast(languages.thisSlotIsNotAvailable);
                }
              },
            );
          }),
        );
      },
    );
  }
}
