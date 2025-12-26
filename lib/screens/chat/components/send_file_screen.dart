import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/back_widget.dart';
import '../../../components/cached_image_widget.dart';
import '../../../components/common_file_placeholders.dart';
import '../../../utils/common.dart';
import '../../../utils/constant.dart';
import '../../../utils/images.dart';

class SendFilePreviewScreen extends StatefulWidget {
  final List<File> pickedfiles;

  const SendFilePreviewScreen({super.key, required this.pickedfiles});

  @override
  State<SendFilePreviewScreen> createState() => _SendFilePreviewScreenState();
}

class _SendFilePreviewScreenState extends State<SendFilePreviewScreen> {
  int currentPosition = 0;
  PageController pageController = PageController();
  TextEditingController messageCont = TextEditingController();
  FocusNode messageFocus = FocusNode();
  List<File> files = [];

  @override
  void initState() {
    super.initState();
    files = widget.pickedfiles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        backWidget: BackWidget(color: context.onPrimary),
        color: context.primary,
        systemUiOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: context.primary,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light),
        titleWidget: Text(
          languages.sendMessage,
          style: context.boldTextStyle(
              color: context.onPrimary, size: APP_BAR_TEXT_SIZE),
        ),
      ),
      body: SizedBox(
        height: context.height(),
        width: context.width(),
        child: Column(
          children: [
            32.height,
            PageView.builder(
              itemCount: files.length,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    files[index]
                            .path
                            .contains(RegExp(r'\.jpeg|\.jpg|\.gif|\.png|\.bmp'))
                        ? CachedImageWidget(
                            url: files[index].path,
                            width: context.width(),
                            height: context.height(),
                            fit: BoxFit.cover,
                            radius: 8,
                          )
                        : Container(
                            padding: EdgeInsets.all(4),
                            decoration: boxDecorationRoundedWithShadow(
                                defaultRadius.toInt(),
                                backgroundColor: context.primaryContainer),
                            child: CommonPdfPlaceHolder(
                              text: "${files[index].path.getChatFileName}",
                              fileExt: files[index].path.getFileExtension,
                            ),
                          ),
                    if (files.length > 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        height: 40,
                        width: 40,
                        child: Container(
                          decoration: boxDecorationRoundedWithShadow(100,
                              backgroundColor: context.card),
                          child: ic_delete
                              .iconImage(
                                  context: context,
                                  size: 16,
                                  color: context.error)
                              .paddingAll(8)
                              .onTap(() {
                            showConfirmDialogCustom(
                              context,
                              title: languages.removeThisFile,
                              subTitle:
                                  languages.areYouSureWantToRemoveThisFile,
                              positiveText: languages.lblYes,
                              negativeText: languages.lblNo,
                              dialogType: DialogType.DELETE,
                              onAccept: (p0) async {
                                files.removeAt(index);
                                log('removeAt FILES: ${files.map((e) => e.path)}');
                              },
                            );
                            return;
                          }),
                        ),
                      ),
                  ],
                );
              },
              controller: pageController,
              scrollDirection: Axis.horizontal,
              onPageChanged: (num) {
                currentPosition = num + 1;
                setState(() {});
              },
            ).expand(),
            32.height,
            _buildChatFieldWidget(),
            32.height,
            Row(
              children: [
                AppButton(
                  textColor: context.onPrimary,
                  text: languages.lblSubmit,
                  color: context.primary,
                  onTap: () {
                    finish(context, {
                      MessageType.TEXT.name: messageCont.text,
                      MessageType.Files.name: files
                    });
                  },
                ).expand(),
              ],
            ),
            16.height,
          ],
        ).paddingSymmetric(horizontal: 16),
      ),
    );
  }

  //region Widget
  Widget _buildChatFieldWidget() {
    return Row(
      children: [
        AppTextField(
          textFieldType: TextFieldType.OTHER,
          controller: messageCont,
          textStyle: context.primaryTextStyle(),
          minLines: 1,
          // onFieldSubmitted: (s) {},
          focus: messageFocus,
          cursorHeight: 20,
          maxLines: 5,
          cursorColor: context.onSurface,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          decoration: inputDecoration(context).copyWith(
              hintText: languages.lblMessage,
              hintStyle: context.primaryTextStyle()),
        ).expand(),
      ],
    );
  }
}
