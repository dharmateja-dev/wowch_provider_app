import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/base_scaffold_widget.dart';
import 'package:handyman_provider_flutter/components/selected_item_widget.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/app_widgets.dart';
import '../components/empty_error_state_widget.dart';
import '../components/pdf_viewer_component.dart';
import '../main.dart';
import '../models/document_list_response.dart';
import '../networks/rest_apis.dart';
import '../utils/common.dart';
import '../utils/images.dart';
import 'sign_in_screen.dart';

class UploadDocumentsScreen extends StatefulWidget {
  final Map<String, dynamic> formRequest;

  const UploadDocumentsScreen({super.key, required this.formRequest});

  @override
  State<UploadDocumentsScreen> createState() => _UploadDocumentsScreenState();
}

class _UploadDocumentsScreenState extends State<UploadDocumentsScreen> {
  bool isAcceptedTc = false;
  ValueNotifier valueNotifier = ValueNotifier(true);
  Future<DocumentListResponse>? future;
  FilePickerResult? filePickerResult;
  File? imageFile;
  List<Documents> uploadDocResp = [];

  int page = 1;
  bool isLastPage = false;

  initState() {
    super.initState();
    init();
  }

//get Document list
  Future<void> init() async {
    future = getDocTypeList(DocumentType.provider_document.name).then((value) {
      return value;
    }).catchError((e) {
      // Return demo data when API fails (for UI testing/reskinning)
      log('API failed, using demo data: $e');
      return DocumentListResponse(
        documents: _getDemoDocuments(),
      );
    });
  }

  // Demo documents for UI testing when API is not available
  List<Documents> _getDemoDocuments() {
    return [
      Documents(
        id: 1,
        name: 'Driver License',
        isRequired: 1,
      ),
      Documents(
        id: 2,
        name: 'Aadhar Card',
        isRequired: 1,
      ),
      Documents(
        id: 3,
        name: 'Pan Card',
        isRequired: 0,
      ),
      Documents(
        id: 4,
        name: 'Voting Card',
        isRequired: 0,
      ),
    ];
  }

  void getMultipleFile({int? updateId, Function(String)? setImage}) async {
    filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf']);

    if (filePickerResult != null) {
      showConfirmDialogCustom(
        context,
        height: 80,
        width: 290,
        shape: appDialogShape(16),
        title: languages.confirmationUpload,
        titleColor: context.dialogTitleColor,
        backgroundColor: context.dialogBackgroundColor,
        primaryColor: context.primary,
        customCenterWidget: Image.asset(
          ic_warning,
          color: context.dialogIconColor,
          height: 70,
          width: 70,
          fit: BoxFit.cover,
        ),
        positiveText: languages.lblYes,
        positiveTextColor: context.onPrimary,
        negativeText: languages.lblNo,
        negativeTextColor: context.dialogCancelColor,
        dialogType: DialogType.CONFIRMATION,
        onAccept: (BuildContext context) {
          ifNotTester(context, () {
            setState(() {
              imageFile = File(filePickerResult!.paths.first!);
              setImage?.call(imageFile!.path);
            });
          });
        },
      );
    } else {}
  }

  //Register API Fun
  Future<void> registerFun() async {
    if (!isAcceptedTc) {
      toast(languages.lblTermCondition);
      return;
    }
    log("Document List: ${uploadDocResp.where((element) => element.filePath?.isEmpty ?? true).toList()}");
    if (uploadDocResp.isEmpty ||
        (uploadDocResp
            .where((element) => (element.isRequired == 1 &&
                (element.filePath?.isEmpty ?? true)))
            .isNotEmpty)) {
      toast(languages.pleaseUploadAllRequired);
      return;
    }
    appStore.setLoading(true);
    List<Documents> list = uploadDocResp
        .where((element) => element.filePath?.isNotEmpty ?? false)
        .toList();
    for (int i = 0; i < list.length; i++) {
      widget.formRequest['document_id[$i]'] = list[i].id;
    }
    log("Request ---> ${widget.formRequest}");
    await registerUser(widget.formRequest, imageFile: list).then((value) {
      appStore.setLoading(false);
      toast(value.message.validate());
      push(SignInScreen(),
          isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
    }).catchError((error) {
      appStore.setLoading(false);
      final String err = error.toString().toLowerCase();
      if (err.contains('413') ||
          err.contains('payload too large') ||
          err.contains('request entity too large') ||
          err.contains('file too large') ||
          err.contains('size')) {
        toast(languages.pleaseUploadAllRequired.isEmpty
            ? 'File size is too large. Please upload a smaller file.'
            : 'File size is too large. Please upload a smaller file.');
      } else {
        toast(error.toString());
      }
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  // Termas of service and Provacy policy text
  Widget buildTcAcceptWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ValueListenableBuilder(
          valueListenable: valueNotifier,
          builder: (context, value, child) => SelectedItemWidget(
            isSelected: isAcceptedTc,
            onChanged: () {
              isAcceptedTc = !isAcceptedTc;
              valueNotifier.notifyListeners();
            },
          ),
        ),
        12.width,
        RichTextWidget(
          list: [
            TextSpan(
                text: '${languages.lblIAgree} ',
                style: context.boldTextStyle()),
            TextSpan(
              text: languages.lblTermsOfService,
              style: context.boldTextStyle(color: context.primary),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  checkIfLink(context, appConfigurationStore.termConditions,
                      title: languages.lblTermsAndConditions);
                },
            ),
            TextSpan(text: ' & ', style: context.boldTextStyle()),
            TextSpan(
              text: languages.lblPrivacyPolicy,
              style: context.boldTextStyle(color: context.primary),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  checkIfLink(context, appConfigurationStore.privacyPolicy,
                      title: languages.lblPrivacyPolicy);
                },
            ),
          ],
        ).flexible(flex: 2),
      ],
    ).paddingAll(16);
  }

  @override
  void dispose() {
    uploadDocResp.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBarTitle: languages.uploadDocuments,
      body: Stack(
        children: [
          Column(
            children: [
              AnimatedScrollView(
                padding: EdgeInsets.all(16),
                onSwipeRefresh: () async {
                  init();
                  setState(() {});
                  return await 2.seconds.delay;
                },
                // onNextPage: () {
                //   if(isLa)
                // },
                children: [
                  Text(languages.uploadRequiredDocuments,
                      style: context.boldTextStyle(size: 14)),
                  8.height,
                  RichText(
                    text: TextSpan(
                      style: context.primaryTextStyle(size: 12),
                      children: [
                        TextSpan(
                          text: languages.pleaseUploadTheFollowing,
                        ),
                        TextSpan(
                          text: '*',
                          style: context.primaryTextStyle(size: 12).copyWith(
                              color: context.error,
                              fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${languages.requiredDocumentsMustBe}',
                        ),
                      ],
                    ),
                  ),
                  35.height,
                  SnapHelperWidget<DocumentListResponse>(
                    future: future,
                    loadingWidget: Center(child: LoaderWidget())
                        .paddingTop(context.height() * 0.2),
                    onSuccess: (list) {
                      uploadDocResp = list.documents ?? [];
                      return AnimatedWrap(
                        itemCount: uploadDocResp.length,
                        listAnimationType: ListAnimationType.FadeIn,
                        fadeInConfiguration:
                            FadeInConfiguration(duration: 2.seconds),
                        itemBuilder: (context, index) {
                          Documents data = uploadDocResp[index];
                          if (uploadDocResp.isEmpty)
                            return NoDataWidget(
                              title: languages.noNotificationTitle,
                              subTitle: languages.noNotificationSubTitle,
                              imageWidget: EmptyStateWidget(),
                            ).center().visible(!appStore.isLoading);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RichText(
                                  text: TextSpan(
                                style: context.boldTextStyle(size: 14),
                                children: [
                                  TextSpan(
                                      text: data.name.validate(),
                                      style: context.boldTextStyle(
                                        size: 14,
                                      )),
                                  if (data.isRequired == 1)
                                    TextSpan(
                                        text: ' *',
                                        style: context.boldTextStyle(
                                            color: context.error, size: 14)),
                                ],
                              )),
                              12.height,
                              GestureDetector(
                                onTap: () {
                                  getMultipleFile(setImage: (imagePath) {
                                    list.documents?[index] = list
                                            .documents?[index]
                                            .copyWith(filePath: imagePath) ??
                                        Documents();
                                  });
                                  setState(() {});
                                },
                                child: Container(
                                  height: 200,
                                  width: context.width(),
                                  decoration: BoxDecoration(
                                    color: context.uploadCardBackground,
                                    borderRadius: radius(defaultRadius),
                                  ),
                                  alignment: Alignment.center,
                                  child: data.filePath?.isNotEmpty ?? false
                                      ? Container(
                                          height: 200,
                                          width: context.width(),
                                          decoration: BoxDecoration(
                                            color: context.uploadCardBackground,
                                            borderRadius: radius(defaultRadius),
                                            image: data.filePath
                                                        ?.contains('.pdf') ??
                                                    false
                                                ? DecorationImage(
                                                    image:
                                                        AssetImage(img_files),
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                      black.withValues(
                                                          alpha: 0.6),
                                                      BlendMode.darken,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : DecorationImage(
                                                    image: FileImage(
                                                        File(data.filePath!)),
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          child: data.filePath
                                                      ?.contains('.pdf') ??
                                                  false
                                              ? Container(
                                                  height: 40,
                                                  width: double.infinity,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10),
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                          bottomLeft:
                                                              radiusCircular(
                                                                  defaultRadius),
                                                          bottomRight:
                                                              radiusCircular(
                                                                  defaultRadius))),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                          "${data.filePath.validate().split("/").last}",
                                                          style: context
                                                              .boldTextStyle(
                                                                  color: context
                                                                      .onPrimary),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis),
                                                      8.height,
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              PdfViewerComponent(
                                                                      pdfFile: data
                                                                          .filePath
                                                                          .validate(),
                                                                      isFile:
                                                                          true)
                                                                  .launch(
                                                                      context);
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          16,
                                                                      vertical:
                                                                          6),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4),
                                                                color: context
                                                                    .primaryColor,
                                                              ),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                  languages
                                                                      .viewPDF,
                                                                  style: context
                                                                      .boldTextStyle(
                                                                          color:
                                                                              context.onPrimary)),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : Offstage(),
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Image.asset(
                                              ic_gallery_add,
                                              height: 58,
                                              color: context.icon,
                                            ),
                                            18.height,
                                            RichText(
                                                text: TextSpan(
                                              style: context.boldTextStyle(
                                                  size: 14),
                                              children: [
                                                TextSpan(
                                                    text: languages
                                                        .dropYourFilesHereOr,
                                                    style:
                                                        context.boldTextStyle(
                                                            size: 14,
                                                            color: context
                                                                .onSurface)),
                                                TextSpan(
                                                    text:
                                                        " ${languages.browse}",
                                                    style:
                                                        context.boldTextStyle(
                                                            size: 14,
                                                            color: context
                                                                .primary)),
                                              ],
                                            )),
                                          ],
                                        ),
                                ),
                              ),
                              16.height
                            ],
                          );
                        },
                      );
                    },
                    errorBuilder: (error) {
                      return NoDataWidget(
                        title: error,
                        imageWidget: ErrorStateWidget(),
                        retryText: languages.reload,
                        onRetry: () {
                          appStore.setLoading(true);
                          init();
                          setState(() {});
                        },
                      );
                    },
                  ),
                ],
              ).expand(),
              buildTcAcceptWidget(),
              Observer(
                builder: (_) => AppButton(
                  margin: const EdgeInsets.only(bottom: 12),
                  text: languages.lblSignup,
                  height: 40,
                  color: appStore.isLoading
                      ? context.primary.withValues(alpha: 0.5)
                      : context.primary,
                  textStyle: boldTextStyle(color: context.onPrimary),
                  width: context.width() - context.navigationBarHeight,
                  onTap: () {
                    if (!appStore.isLoading) {
                      registerFun();
                    }
                  },
                ),
              ).paddingOnly(left: 16.0, right: 16.0)
            ],
          ),
          Observer(
            builder: (_) => LoaderWidget().center().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }

  Future<void> openPdfExternally(String pdfUrl) async {
    final uri = Uri.parse(pdfUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $pdfUrl';
    }
  }
}
