import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class ThemeSelectionDaiLog extends StatefulWidget {
  final BuildContext buildContext;

  ThemeSelectionDaiLog(this.buildContext);

  @override
  ThemeSelectionDaiLogState createState() => ThemeSelectionDaiLogState();
}

class ThemeSelectionDaiLogState extends State<ThemeSelectionDaiLog> {
  List<String> themeModeList = [];
  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // Load current theme mode from storage
    currentIndex =
        getIntAsync(THEME_MODE_INDEX, defaultValue: THEME_MODE_SYSTEM);

    afterBuildCreated(() {
      // Populate theme mode list with localized strings
      themeModeList = [
        languages.lightMode,
        languages.darkMode,
        languages.systemDefault
      ];
      // Refresh UI after loading
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              backgroundColor: context.primary,
            ),
            padding:
                const EdgeInsets.only(left: 24, right: 8, bottom: 8, top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(languages.chooseTheme,
                    style: context.boldTextStyle(
                        color: context.onPrimary, size: 16)),
                IconButton(
                  onPressed: () {
                    finish(context);
                  },
                  icon: Icon(Icons.close, size: 24, color: context.onPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AnimatedListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            itemCount: themeModeList.length,
            itemBuilder: (BuildContext context, int index) {
              return RadioListTile(
                value: index,
                groupValue: currentIndex,
                activeColor: context.primary,
                controlAffinity: ListTileControlAffinity.trailing,
                title: Text(themeModeList[index],
                    style: context.primaryTextStyle()),
                onChanged: (dynamic val) async {
                  currentIndex = val;

                  // Use MobX action to set theme mode - handles persistence and theme application
                  await appStore.setThemeModeIndex(val);

                  // Update toast colors based on theme
                  if (val == THEME_MODE_DARK) {
                    defaultToastBackgroundColor = context.onPrimary;
                    defaultToastTextColor = Colors.black;
                  } else {
                    defaultToastBackgroundColor = Colors.black;
                    defaultToastTextColor = context.onPrimary;
                  }

                  setState(() {});
                  finish(context);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
