import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/components/days_component.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/components/disclaimer_widget.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/components/slot_component.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/edit_time_slot_screen.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/models/slot_data.dart';
import 'package:handyman_provider_flutter/provider/timeSlots/services/time_slot_services.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

// Dummy time slots for testing UI
const List<String> dummyTimeSlots = [
  '07:00:00',
  '08:00:00',
  '09:00:00',
  '10:00:00',
  '11:00:00',
  '12:00:00',
  '13:00:00',
  '14:00:00',
  '15:00:00',
  '16:00:00',
  '17:00:00',
  '18:00:00',
  '19:00:00',
  '20:00:00',
  '21:00:00',
  '22:00:00',
  '23:00:00',
  '00:00:00',
];

class MyTimeSlotsScreen extends StatefulWidget {
  final bool isFromService;

  MyTimeSlotsScreen({this.isFromService = false});

  @override
  _MyTimeSlotsScreenState createState() => _MyTimeSlotsScreenState();
}

class _MyTimeSlotsScreenState extends State<MyTimeSlotsScreen> {
  List<SlotData> timeSlotsList = [];

  String selectedDay = daysList.first;

  bool isTimeSlotAvailableForAll = false;
  bool useDummyData = true; // Toggle for dummy data

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (useDummyData) {
      // Use dummy data for UI testing
      timeSlotsList = daysList.map((day) {
        return SlotData(
          day: dayListMap[day],
          slot: dummyTimeSlots.toList(),
        );
      }).toList();
      setState(() {});
    } else {
      timeSlotsList = await getProviderTimeSlots();
      setState(() {});
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> setForAllServices(bool status) async {
    timeSlotStore.setLoading(true);

    toast(languages.pleaseWaitWhileWeChangeTheStatus);

    Map request = {
      "slots_for_all_services": status ? 1 : 0,
      "id": appStore.userId,
    };

    await updateAllServicesApi(request: request).then((value) {
      isTimeSlotAvailableForAll = status;
      setState(() {});
      Fluttertoast.cancel();
      toast(value.message);
    }).catchError((e) {
      Fluttertoast.cancel();
      toast(e.toString());
    });

    timeSlotStore.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    List<String> temp = timeSlotsList.isNotEmpty
        ? timeSlotsList
            .firstWhere(
                (element) =>
                    element.day!.toLowerCase() == dayListMap[selectedDay],
                orElse: () => SlotData(slot: [], day: ''))
            .slot
            .validate()
        : [];

    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.primary,
        leading: BackWidget(color: context.onPrimary),
        title: Text(
          languages.myTimeSlots,
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
                // Day Selection Card
                Container(
                  decoration: boxDecorationDefault(
                    color: context.cardSecondary,
                    borderRadius: radius(12),
                    border: Border.all(color: context.cardSecondaryBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            languages.day,
                            style: context.boldTextStyle(),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 20,
                              color: context.iconMuted,
                            ),
                            onPressed: () async {
                              await EditTimeSlotScreen(
                                slotData: timeSlotsList,
                                selectedDay: selectedDay,
                                onSave: (val) async {
                                  Map<String, dynamic> request = {
                                    "id": "",
                                    "provider_id": appStore.userId.validate(),
                                    "slots": val
                                        .map((e) => e.toJsonRequest())
                                        .toList()
                                  };
                                  appStore.setLoading(true);

                                  await saveProviderSlot(request).then((value) {
                                    toast(value.message.validate());

                                    if (widget.isFromService) {
                                      finish(context);
                                      finish(context, true);
                                      init();
                                    } else {
                                      finish(context, true);
                                      init();
                                    }
                                  }).catchError((e) {
                                    log(e.toString());
                                  });

                                  appStore.setLoading(false);
                                },
                              ).launch(context,
                                  pageRouteAnimation: PageRouteAnimation.Fade);
                            },
                          ),
                        ],
                      ).paddingOnly(left: 16, right: 8, top: 8),
                      DaysComponent(
                        daysList: daysList,
                        onDayChanged: (day) {
                          selectedDay = day;
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),

                // 24-hour format toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      languages.use24HourFormat,
                      style: context.secondaryTextStyle(size: 14),
                    ),
                    8.width,
                    Observer(builder: (context) {
                      return Transform.scale(
                        scale: 0.8,
                        child: CupertinoSwitch(
                          activeTrackColor: context.primary,
                          value: appStore.is24HourFormat,
                          onChanged: (value) {
                            appStore.set24HourFormat(value);
                          },
                        ),
                      );
                    }),
                  ],
                ).paddingSymmetric(vertical: 16),

                // Time Slots Card
                SlotsComponent(timeSlotList: temp),

                24.height,

                // Disclaimer
                DisclaimerWidget(),
              ],
            ),
          ),
          Observer(builder: (_) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
