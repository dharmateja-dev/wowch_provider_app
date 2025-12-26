import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class UserDemoModeScreen extends StatefulWidget {
  final Function(String email, String password) onChanged;

  UserDemoModeScreen({required this.onChanged});

  @override
  _UserDemoModeScreenState createState() => _UserDemoModeScreenState();
}

class _UserDemoModeScreenState extends State<UserDemoModeScreen> {
  List<String> demoLoginName = ["Demo Provider", "Demo Handyman", "Reset"];

  int btnIndex = 0;

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
    return FutureBuilder<String>(
      future: getPackageName(),
      builder: (context, snap) {
        if (snap.hasData) {
          return Column(
            children: [
              32.height,
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                children: List.generate(
                  demoLoginName.length,
                  (index) {
                    // Unselected: bg=#F2F4F5, border=#D6D6D6
                    // Selected: bg=transparent, border=primary, text=primary
                    final isSelected = btnIndex == index;
                    return OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        backgroundColor: isSelected
                            ? Colors.transparent
                            : const Color(0xFFF2F4F5),
                        side: BorderSide(
                            color: isSelected
                                ? context.primary
                                : const Color(0xFFD6D6D6),
                            width: 1),
                      ),
                      onPressed: () {
                        btnIndex = index;
                        setState(() {});

                        if (index == 0) {
                          widget.onChanged
                              .call(DEFAULT_PROVIDER_EMAIL, DEFAULT_PASS);
                        }
                        if (index == 1) {
                          widget.onChanged
                              .call(DEFAULT_HANDYMAN_EMAIL, DEFAULT_PASS);
                        }
                        if (index == 2) {
                          widget.onChanged.call('', '');
                        }
                      },
                      child: Text(demoLoginName[index],
                          style: context.boldTextStyle(
                              color: isSelected
                                  ? context.primary
                                  : const Color(0xFF121212),
                              size: 12),
                          textAlign: TextAlign.center),
                    ).withWidth(context.width() / 2 - 24);
                  },
                ),
              ),
            ],
          );
        }
        return const Offstage();
      },
    );
  }
}
