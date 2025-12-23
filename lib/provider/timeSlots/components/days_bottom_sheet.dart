import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class DaysBottomSheet extends StatefulWidget {
  final String selectedDay;

  DaysBottomSheet({required this.selectedDay});

  @override
  DaysBottomSheetState createState() => DaysBottomSheetState();
}

class DaysBottomSheetState extends State<DaysBottomSheet> {
  List<String> localDayList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    localDayList.add(widget.selectedDay);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.45,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: boxDecorationDefault(
            borderRadius: radiusOnly(topLeft: 16, topRight: 16),
            color: context.bottomSheetBackgroundColor,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Drag Handle
                    Container(
                      height: 5,
                      width: 40,
                      decoration: boxDecorationDefault(
                        borderRadius: radius(60),
                        color: context.iconMuted,
                      ),
                    ).center(),
                    16.height,

                    // Title
                    Text(
                      languages.copyTo,
                      style: context.boldTextStyle(size: 18),
                    ),
                    8.height,

                    // Days List
                    ListView.builder(
                      itemCount: daysList.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (_, i) {
                        if (daysList[i] == widget.selectedDay)
                          return const SizedBox();

                        bool isChecked = localDayList.contains(daysList[i]);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: boxDecorationDefault(
                            color: context.cardSecondary,
                            borderRadius: radius(8),
                          ),
                          child: Theme(
                            data: ThemeData(
                              unselectedWidgetColor: context.iconMuted,
                            ),
                            child: CheckboxListTile(
                              checkboxShape: RoundedRectangleBorder(
                                  borderRadius: radius(4)),
                              autofocus: false,
                              activeColor: context.primary,
                              checkColor: context.onPrimary,
                              title: Text(
                                daysList[i],
                                style: context.boldTextStyle(),
                              ),
                              value: isChecked,
                              onChanged: (bool? value) {
                                if (localDayList.contains(daysList[i])) {
                                  localDayList.remove(daysList[i]);
                                } else {
                                  localDayList.add(daysList[i]);
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).paddingBottom(70),

              // Save Button
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: AppButton(
                  text: languages.btnSave,
                  color: context.primary,
                  textColor: context.onPrimary,
                  textStyle: context.boldTextStyle(color: context.onPrimary),
                  shapeBorder: RoundedRectangleBorder(borderRadius: radius(8)),
                  width: context.width() - 32,
                  onTap: () async {
                    if (localDayList.isNotEmpty) finish(context, localDayList);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
