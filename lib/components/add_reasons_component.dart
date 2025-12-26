import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/common.dart';
import '../utils/configs.dart';

class AddReasonsComponent extends StatefulWidget {
  const AddReasonsComponent({Key? key}) : super(key: key);

  @override
  State<AddReasonsComponent> createState() => _AddReasonsComponentState();
}

class _AddReasonsComponentState extends State<AddReasonsComponent> {
  TextEditingController reasonsCont = TextEditingController();

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
    return Container(
      width: context.width(),
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.width(),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              backgroundColor: primary,
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(languages.addReason,
                        style: context.boldTextStyle(color: white))
                    .expand(),
                CloseButton(color: context.onPrimary),
              ],
            ),
          ),
          AppTextField(
            textFieldType: TextFieldType.NAME,
            controller: reasonsCont,
            decoration:
                inputDecoration(context, hintText: languages.writeReason),
          ).paddingAll(16),
          AppButton(
            text: languages.btnSave,
            color: primary,
            textStyle: context.boldTextStyle(color: white),
            width: context.width() - context.navigationBarHeight,
            onTap: () {
              if (reasonsCont.text.isNotEmpty) {
                finish(context, reasonsCont.text);
              } else {
                toast(languages.pleaseAddReason);
              }
            },
          ).paddingAll(16),
        ],
      ),
    ).paddingAll(0);
  }
}
