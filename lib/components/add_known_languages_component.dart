import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/common.dart';

class AddKnownLanguagesComponent extends StatefulWidget {
  const AddKnownLanguagesComponent({Key? key}) : super(key: key);

  @override
  State<AddKnownLanguagesComponent> createState() =>
      _AddKnownLanguagesComponentState();
}

class _AddKnownLanguagesComponentState
    extends State<AddKnownLanguagesComponent> {
  TextEditingController knownLangCont = TextEditingController();

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: context.width(),
            decoration: boxDecorationWithRoundedCorners(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              backgroundColor: context.primary,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(languages.addKnownLanguage,
                        style: boldTextStyle(color: context.onPrimary))
                    .expand(),
                CloseButton(color: context.onPrimary),
              ],
            ),
          ),
          AppTextField(
            textFieldType: TextFieldType.NAME,
            controller: knownLangCont,
            decoration: inputDecoration(context,
                hintText: languages.knownLanguages,
                fillColor: context.profileInputFillColor),
          ).paddingAll(16),
          AppButton(
            text: languages.btnSave,
            color: context.primary,
            textStyle: boldTextStyle(color: context.onPrimary),
            width: context.width() - context.navigationBarHeight,
            onTap: () {
              if (knownLangCont.text.isNotEmpty) {
                finish(context, knownLangCont.text);
              } else {
                toast(languages.pleaseAddKnownLanguage);
              }
            },
          ).paddingAll(16),
        ],
      ),
    ).paddingAll(0);
  }
}
