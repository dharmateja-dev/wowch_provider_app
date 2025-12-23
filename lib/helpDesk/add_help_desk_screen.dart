import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/app_widgets.dart';
import '../components/base_scaffold_widget.dart';
import '../components/chat_gpt_loder.dart';
import '../components/custom_image_picker.dart';
import '../utils/common.dart';
import '../utils/images.dart';
import '../utils/model_keys.dart';
import 'help_desk_repository.dart';

class AddHelpDeskScreen extends StatefulWidget {
  final Function(bool) callback;

  AddHelpDeskScreen({required this.callback});

  @override
  _AddHelpDeskScreenState createState() => _AddHelpDeskScreenState();
}

class _AddHelpDeskScreenState extends State<AddHelpDeskScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UniqueKey uniqueKey = UniqueKey();

  List<File> imageFiles = [];

  TextEditingController subjectCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();

  FocusNode subjectFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();

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

  //region Add Help Desk
  Future<void> checkValidation() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      final Map<String, dynamic> req = {
        HelpDeskKey.subject: subjectCont.text,
        HelpDeskKey.description: descriptionCont.text,
      };

      log("Save Help Desk Query Request: $req");
      saveHelpDeskMultiPart(
              value: req,
              imageFile: imageFiles
                  .where((element) => !element.path.contains('http'))
                  .toList())
          .then((value) {
        widget.callback.call(true);
      }).catchError((e) {
        toast(e.toString());
      });
    }
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      scaffoldBackgroundColor: context.scaffoldSecondary,
      appBarTitle: languages.helpDesk,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subject Field
                        Text(
                          languages.subject,
                          style: context.boldTextStyle(),
                        ),
                        8.height,
                        AppTextField(
                          controller: subjectCont,
                          focus: subjectFocus,
                          nextFocus: descriptionFocus,
                          textFieldType: TextFieldType.NAME,
                          decoration: inputDecoration(
                            context,
                            hintText: languages.eGDamagedFurniture,
                            fillColor: context.profileInputFillColor,
                          ),
                          maxLength: 120,
                          buildCounter: (context,
                                  {required currentLength,
                                  required isFocused,
                                  maxLength}) =>
                              null,
                          suffix: ic_document
                              .iconImage(context: context, size: 10)
                              .paddingAll(14),
                        ),

                        16.height,

                        // Description Field
                        Text(
                          languages.hintDescription,
                          style: context.boldTextStyle(),
                        ),
                        8.height,
                        AppTextField(
                          textFieldType: TextFieldType.MULTILINE,
                          controller: descriptionCont,
                          focus: descriptionFocus,
                          maxLines: 10,
                          minLines: 3,
                          enableChatGPT: appConfigurationStore.chatGPTStatus,
                          promptFieldInputDecorationChatGPT:
                              inputDecoration(context).copyWith(
                            hintText: languages.writeHere,
                            fillColor: context.profileInputFillColor,
                            filled: true,
                            hintStyle: context.primaryTextStyle(),
                          ),
                          testWithoutKeyChatGPT:
                              appConfigurationStore.testWithoutKey,
                          loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                          decoration: inputDecoration(
                            context,
                            hintText: languages.eGDuringTheService,
                            fillColor: context.profileInputFillColor,
                          ),
                        ),

                        16.height,

                        // Attachment Label
                        Text(
                          languages.lblImage,
                          style: context.boldTextStyle(),
                        ),
                        8.height,

                        // Image Picker with increased height
                        CustomImagePicker(
                          key: uniqueKey,
                          height: 170,
                          isMultipleImages: false,
                          onRemoveClick: (value) {
                            showConfirmDialogCustom(
                              context,
                              dialogType: DialogType.DELETE,
                              title: languages.lblDoYouWantToDelete,
                              height: 80,
                              width: 290,
                              shape: appDialogShape(8),
                              backgroundColor: context.dialogBackgroundColor,
                              titleColor: context.dialogTitleColor,
                              primaryColor: context.error,
                              customCenterWidget: Image.asset(
                                ic_warning,
                                color: context.dialogIconColor,
                                height: 70,
                                width: 70,
                                fit: BoxFit.cover,
                              ),
                              positiveText: languages.lblDelete,
                              positiveTextColor: context.onPrimary,
                              negativeText: languages.lblCancel,
                              negativeTextColor: context.primary,
                              onAccept: (p0) {
                                imageFiles.removeWhere(
                                    (element) => element.path == value);
                                setState(() {});
                              },
                            );
                          },
                          onFileSelected: (List<File> files) async {
                            imageFiles = files;
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Submit Button
              Observer(
                builder: (_) => AppButton(
                  margin:
                      const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                  text: languages.lblSubmit,
                  height: 40,
                  color: appStore.isLoading
                      ? context.primary.withValues(alpha: 0.5)
                      : context.primary,
                  textStyle: context.boldTextStyle(color: context.onPrimary),
                  width: context.width() - context.navigationBarHeight,
                  onTap: appStore.isLoading
                      ? () {}
                      : () {
                          checkValidation();
                        },
                ),
              ),
            ],
          ),
          Observer(
              builder: (_) =>
                  LoaderWidget().center().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
