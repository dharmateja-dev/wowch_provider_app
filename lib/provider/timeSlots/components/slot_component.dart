import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/components/slot_widget.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class SlotsComponent extends StatefulWidget {
  final List<String> timeSlotList;

  SlotsComponent({required this.timeSlotList});

  @override
  SlotsComponentState createState() => SlotsComponentState();
}

class SlotsComponentState extends State<SlotsComponent> {
  int selectTimeSlotIndex = -1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) {
        return Container(
          width: context.width(),
          padding: const EdgeInsets.all(16),
          decoration: boxDecorationDefault(
            color: context.cardSecondary,
            borderRadius: radius(12),
            border: Border.all(color: context.cardSecondaryBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                languages.lblTime,
                style: context.boldTextStyle(),
              ),
              16.height,
              if (widget.timeSlotList.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate slot width for 3 columns
                    // Subtract spacing for 2 gaps (12px * 2 = 24px)
                    double slotWidth = (constraints.maxWidth - 24) / 3;

                    return Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 12,
                      runSpacing: 12,
                      children: widget.timeSlotList.map((slot) {
                        return SlotWidget(
                          isAvailable: false,
                          isSelected: false,
                          width: slotWidth,
                          value: slot.validate(),
                          onTap: () {
                            //
                          },
                        );
                      }).toList(),
                    );
                  },
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    languages.noSlotsAvailable,
                    style: context.secondaryTextStyle(),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ).visible(!appStore.isLoading);
      },
    );
  }
}
