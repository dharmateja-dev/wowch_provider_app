import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/custom_image_picker.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/attachment_model.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/blog/blog_repository.dart';
import 'package:handyman_provider_flutter/provider/blog/model/blog_response_model.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/chat_gpt_loder.dart';
import '../../../models/static_data_model.dart';
import '../../../utils/constant.dart';

class AddBlogScreen extends StatefulWidget {
  final BlogData? data;

  AddBlogScreen({this.data});

  @override
  State<AddBlogScreen> createState() => _AddBlogScreenState();
}

class _AddBlogScreenState extends State<AddBlogScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  UniqueKey uniqueKey = UniqueKey();

  TextEditingController titleCont = TextEditingController();
  TextEditingController descriptionCont = TextEditingController();

  FocusNode titleFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();

  bool isUpdate = false;
  String blogStatus = '';

  List<File> imageFiles = [];
  List<Attachments> tempAttachments = [];

  List<StaticDataModel> statusListStaticData = [
    StaticDataModel(key: ACTIVE, value: languages.active),
    StaticDataModel(key: INACTIVE, value: languages.inactive),
  ];

  StaticDataModel? blogStatusModel;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    isUpdate = widget.data != null;

    if (isUpdate) {
      imageFiles = widget.data!.attachment
          .validate()
          .map((e) => File(e.url.toString()))
          .toList();
      tempAttachments = widget.data!.attachment.validate();
      titleCont.text = widget.data!.title.validate();
      descriptionCont.text = widget.data!.description.validate();
      blogStatus = widget.data!.status.validate() == 1 ? ACTIVE : INACTIVE;
      if (blogStatus == ACTIVE) {
        blogStatusModel = statusListStaticData.first;
      } else {
        blogStatusModel = statusListStaticData[1];
      }
    } else {
      appStore.setLoading(false);
      blogStatus = ACTIVE;
    }
    setState(() {});
  }

  //region Add Blog
  Future<void> checkValidation() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      if (imageFiles.isEmpty) {
        return toast(languages.pleaseSelectImages);
      }

      Map<String, dynamic> req = {
        CommonKeys.id: widget.data != null ? widget.data!.id.validate() : '',
        AddBlogKey.title: titleCont.text.validate(),
        AddBlogKey.description: descriptionCont.text.validate(),
        AddBlogKey.isFeatured: '0',
        AddBlogKey.providerId: appStore.userId.validate(),
        AddBlogKey.authorId: appStore.userId.validate(),
        AddBlogKey.status: blogStatus.validate() == ACTIVE ? '1' : '0',
      };

      addBlogMultiPart(
              value: req,
              imageFile: imageFiles
                  .where((element) => !element.path.contains('http'))
                  .toList())
          .then((value) {
        //
      }).catchError((e) {
        toast(e.toString());
      });
    }
  }

  //endregion

  //region Remove Attachment
  Future<void> removeAttachment({required int id}) async {
    appStore.setLoading(true);

    Map req = {
      CommonKeys.type: BLOG_ATTACHMENT,
      CommonKeys.id: id,
    };

    await deleteImage(req).then((value) {
      tempAttachments.validate().removeWhere((element) => element.id == id);
      setState(() {});

      uniqueKey = UniqueKey();

      appStore.setLoading(false);
      toast(value.message.validate(), print: true);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.primary,
        leading: BackWidget(color: context.onPrimary),
        title: Text(
          isUpdate ? languages.updateBlog : languages.addBlog,
          style: context.boldTextStyle(color: context.onPrimary, size: 18),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker Section
                  Text(languages.lblImage, style: context.boldTextStyle()),
                  8.height,
                  CustomImagePicker(
                    height: 170,
                    key: uniqueKey,
                    onRemoveClick: (value) {
                      if (tempAttachments.validate().isNotEmpty &&
                          imageFiles.isNotEmpty) {
                        showConfirmDialogCustom(
                          context,
                          height: 80,
                          width: 290,
                          shape: appDialogShape(8),
                          title: languages.confirmationRequestTxt,
                          titleColor: context.dialogTitleColor,
                          backgroundColor: context.dialogBackgroundColor,
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
                          negativeTextColor: context.dialogCancelColor,
                          dialogType: DialogType.DELETE,
                          onAccept: (p0) {
                            imageFiles.removeWhere(
                                (element) => element.path == value);
                            removeAttachment(
                                id: tempAttachments
                                    .validate()
                                    .firstWhere(
                                        (element) => element.url == value)
                                    .id
                                    .validate());
                          },
                        );
                      } else {
                        showConfirmDialogCustom(
                          context,
                          height: 80,
                          width: 290,
                          shape: appDialogShape(8),
                          title: languages.confirmationRequestTxt,
                          titleColor: context.dialogTitleColor,
                          backgroundColor: context.dialogBackgroundColor,
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
                          negativeTextColor: context.dialogCancelColor,
                          dialogType: DialogType.DELETE,
                          onAccept: (p0) {
                            imageFiles.removeWhere(
                                (element) => element.path == value);
                            if (isUpdate) {
                              uniqueKey = UniqueKey();
                            }
                            setState(() {});
                          },
                        );
                      }
                    },
                    selectedImages: widget.data != null
                        ? imageFiles
                            .validate()
                            .map((e) => e.path.validate())
                            .toList()
                        : null,
                    onFileSelected: (List<File> files) async {
                      imageFiles = files;
                      setState(() {});
                    },
                  ),

                  16.height,

                  // Title Field
                  Text(languages.lblTitle, style: context.boldTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.NAME,
                    controller: titleCont,
                    focus: titleFocus,
                    nextFocus: descriptionFocus,
                    isValidationRequired: true,
                    errorThisFieldRequired: languages.hintRequired,
                    decoration: inputDecoration(
                      context,
                      hintText: languages.enterBlogTitle,
                      fillColor: context.profileInputFillColor,
                      borderRadius: 8,
                    ),
                  ),

                  16.height,

                  // Description Field
                  Text(languages.hintDescription,
                      style: context.boldTextStyle()),
                  8.height,
                  AppTextField(
                    textFieldType: TextFieldType.MULTILINE,
                    minLines: 5,
                    maxLines: 10,
                    controller: descriptionCont,
                    focus: descriptionFocus,
                    isValidationRequired: true,
                    enableChatGPT: appConfigurationStore.chatGPTStatus,
                    promptFieldInputDecorationChatGPT:
                        inputDecoration(context).copyWith(
                      hintText: languages.writeHere,
                      fillColor: context.profileInputFillColor,
                      filled: true,
                    ),
                    testWithoutKeyChatGPT: appConfigurationStore.testWithoutKey,
                    loaderWidgetForChatGPT: const ChatGPTLoadingWidget(),
                    errorThisFieldRequired: languages.hintRequired,
                    decoration: inputDecoration(
                      context,
                      hintText: languages.hintDescription,
                      fillColor: context.profileInputFillColor,
                      borderRadius: 8,
                    ),
                  ),

                  16.height,

                  // Status Dropdown
                  Text(languages.lblStatus, style: context.boldTextStyle()),
                  8.height,
                  DropdownButtonFormField<StaticDataModel>(
                    isExpanded: true,
                    dropdownColor: context.cardSecondary,
                    initialValue: blogStatusModel != null
                        ? blogStatusModel
                        : statusListStaticData.first,
                    items: statusListStaticData.map((StaticDataModel data) {
                      return DropdownMenuItem<StaticDataModel>(
                        value: data,
                        child: Text(
                          data.value.validate(),
                          style: context.primaryTextStyle(),
                        ),
                      );
                    }).toList(),
                    decoration: inputDecoration(
                      context,
                      fillColor: context.profileInputFillColor,
                      hintText: languages.lblStatus,
                      borderRadius: 8,
                    ),
                    icon: Icon(Icons.keyboard_arrow_down, color: context.icon),
                    onChanged: (StaticDataModel? value) async {
                      blogStatus = value!.key.validate();
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null) return errorThisFieldRequired;
                      return null;
                    },
                  ),

                  100.height,
                ],
              ),
            ),
          ),

          // Save Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: AppButton(
              text: languages.btnSave,
              color: context.primary,
              textStyle: context.boldTextStyle(color: context.onPrimary),
              width: context.width(),
              onTap: () {
                ifNotTester(context, () {
                  checkValidation();
                });
              },
            ),
          ),

          // Loader
          Observer(
            builder: (_) => LoaderWidget().center().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}
