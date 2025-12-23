import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class DaysComponent extends StatefulWidget {
  final List<String> daysList;
  final Function(String)? onDayChanged;

  DaysComponent({required this.daysList, this.onDayChanged, super.key});

  @override
  DaysComponentState createState() => DaysComponentState();
}

class DaysComponentState extends State<DaysComponent> {
  int selectedDayIndex = 0;

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Row(
        children: List.generate(widget.daysList.length, (index) {
          String data = widget.daysList[index];
          bool isSelected = selectedDayIndex == index;

          return GestureDetector(
            onTap: () {
              selectedDayIndex = index;
              setState(() {});
              widget.onDayChanged?.call(data);
            },
            child: Container(
              height: 36,
              margin: EdgeInsets.only(
                  right: index < widget.daysList.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: boxDecorationDefault(
                color: isSelected ? context.primary : context.cardSecondary,
                borderRadius: radius(8),
                border: Border.all(
                  color: isSelected
                      ? context.primary
                      : context.cardSecondaryBorder,
                ),
              ),
              child: Text(
                data.validate().toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.boldTextStyle(
                  size: 12,
                  color: isSelected ? context.onPrimary : context.onSurface,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
