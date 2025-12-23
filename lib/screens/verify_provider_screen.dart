import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/document_list_response.dart';
import 'package:handyman_provider_flutter/models/provider_document_list_response.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/zoom_image_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/empty_error_state_widget.dart';
import '../components/pdf_viewer_component.dart';
import '../utils/images.dart';

// Dummy data for testing UI
final List<Documents> dummyDocuments = [
  Documents(id: 1, name: 'Identity Card', status: 1, isRequired: 1),
  Documents(id: 2, name: 'Driver License', status: 1, isRequired: 1),
  Documents(id: 3, name: 'Business License', status: 1, isRequired: 0),
  Documents(id: 4, name: 'Tax Certificate', status: 1, isRequired: 0),
  Documents(id: 5, name: 'Insurance Document', status: 1, isRequired: 1),
  Documents(id: 6, name: 'Professional Certificate', status: 1, isRequired: 0),
];

final List<ProviderDocuments> dummyProviderDocuments = [
  ProviderDocuments(
    id: 1,
    providerId: 1,
    documentId: 1,
    documentName: 'Identity Card',
    isVerified: 1, // Verified
    providerDocument:
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400',
  ),
  ProviderDocuments(
    id: 2,
    providerId: 1,
    documentId: 2,
    documentName: 'Driver License',
    isVerified: 0, // Pending verification
    providerDocument:
        'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=400',
  ),
  ProviderDocuments(
    id: 3,
    providerId: 1,
    documentId: 5,
    documentName: 'Insurance Document',
    isVerified: 1, // Verified
    providerDocument:
        'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=400',
  ),
  ProviderDocuments(
    id: 4,
    providerId: 1,
    documentId: 3,
    documentName: 'Business License (PDF)',
    isVerified: 0, // Pending verification
    providerDocument: 'https://example.com/document.pdf', // PDF example
  ),
];

class VerifyProviderScreen extends StatefulWidget {
  @override
  _VerifyProviderScreenState createState() => _VerifyProviderScreenState();
}

class _VerifyProviderScreenState extends State<VerifyProviderScreen> {
  DocumentListResponse? documentListResponse;
  List<Documents> documents = [];
  FilePickerResult? filePickerResult;
  List<ProviderDocuments> providerDocuments = [];
  List<File>? imageFiles;
  PickedFile? pickedFile;
  List<String> eAttachments = [];
  int? updateDocId;
  List<int>? uploadedDocList = [];
  Documents? selectedDoc;
  int docId = 0;

  bool useDummyData = true; // Toggle for dummy data

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() {
      init();
    });
  }

  void init() async {
    if (useDummyData) {
      // Use dummy data for UI testing
      documents = dummyDocuments;
      providerDocuments = dummyProviderDocuments;
      providerDocuments.forEach((element) {
        uploadedDocList!.add(element.documentId!);
        updateDocId = element.id;
      });
      setState(() {});
    } else {
      appStore.setLoading(true);
      getDocumentList();
      getProviderDocList();
    }
  }

//get Document list
  Future<void> getDocumentList() async {
    await getDocTypeList(DocumentType.provider_document.name).then((res) {
      documents.clear();
      documents.addAll(res.documents!);
      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    });
  }

  //SelectImage
  void getMultipleFile(int? docId, {int? updateId}) async {
    filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf']);

    if (filePickerResult != null) {
      showConfirmDialogCustom(
        context,
        title: languages.confirmationUpload,
        dialogType: DialogType.CONFIRMATION,
        height: 80,
        width: 290,
        shape: appDialogShape(8),
        backgroundColor: context.dialogBackgroundColor,
        titleColor: context.dialogTitleColor,
        primaryColor: context.primary,
        customCenterWidget: Image.asset(
          ic_info,
          color: context.dialogIconColor,
          height: 70,
          width: 70,
          fit: BoxFit.cover,
        ),
        positiveText: languages.lblYes,
        positiveTextColor: context.onPrimary,
        negativeText: languages.lblNo,
        negativeTextColor: context.primary,
        onAccept: (BuildContext context) {
          setState(() {
            imageFiles =
                filePickerResult!.paths.map((path) => File(path!)).toList();
            eAttachments = [];
          });

          ifNotTester(context, () {
            addDocument(docId, updateId: updateId);
          });
        },
      );
    } else {}
  }

  //Add Documents
  void addDocument(int? docId, {int? updateId}) async {
    MultipartRequest multiPartRequest =
        await getMultiPartRequest('provider-document-save');
    multiPartRequest.fields[CommonKeys.id] =
        updateId != null ? updateId.toString() : '';
    multiPartRequest.fields[CommonKeys.providerId] = appStore.userId.toString();
    multiPartRequest.fields[AddDocument.documentId] = docId.toString();
    multiPartRequest.fields[AddDocument.isVerified] = '0';

    if (imageFiles != null) {
      multiPartRequest.files.add(await MultipartFile.fromPath(
          AddDocument.providerDocument, imageFiles!.first.path));
    }
    log(multiPartRequest);

    multiPartRequest.headers.addAll(buildHeaderTokens());
    appStore.setLoading(true);

    sendMultiPartRequest(
      multiPartRequest,
      onSuccess: (data) async {
        appStore.setLoading(false);

        toast(languages.toastSuccess, print: true);
        getProviderDocList();
      },
      onError: (error) {
        toast(error.toString(), print: true);
        appStore.setLoading(false);
      },
    ).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  //Get Uploaded Documents List
  void getProviderDocList() {
    getProviderDoc().then((res) {
      appStore.setLoading(false);
      providerDocuments.clear();
      providerDocuments.addAll(res.providerDocuments!);
      providerDocuments.forEach((element) {
        uploadedDocList!.add(element.documentId!);
        updateDocId = element.id;
      });
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });
  }

  //Delete Documents
  void deleteDoc(int? id) {
    appStore.setLoading(true);
    deleteProviderDoc(id).then((value) {
      toast(value.message, print: true);
      uploadedDocList!.clear();
      getProviderDocList();
      appStore.setLoading(false);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: appBarWidget(
        languages.btnVerifyId,
        textColor: context.onPrimary,
        color: context.primary,
      ),
      body: Stack(
        children: [
          AnimatedScrollView(
            padding: const EdgeInsets.all(16),
            onSwipeRefresh: () async {
              if (!useDummyData) {
                getDocumentList();
              }
              await 300.milliseconds.delay;
            },
            children: [
              // Document Selection Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: boxDecorationDefault(
                  color: context.cardSecondary,
                  borderRadius: radius(12),
                  border: Border.all(color: context.cardSecondaryBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      languages.lblSelectDoc,
                      style: context.boldTextStyle(),
                    ),
                    12.height,
                    Row(
                      children: [
                        if (documents.isNotEmpty)
                          DropdownButtonFormField<Documents>(
                            isExpanded: true,
                            decoration: inputDecoration(
                              context,
                              hintText: languages.lblSelectDoc,
                              fillColor: context.profileInputFillColor,
                            ),
                            initialValue: selectedDoc,
                            dropdownColor: context.cardSecondary,
                            items: documents.map((Documents e) {
                              return DropdownMenuItem<Documents>(
                                value: e,
                                child: Text(
                                  e.name!,
                                  style: context.primaryTextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (Documents? value) async {
                              selectedDoc = value;
                              docId = value!.id!;
                              setState(() {});
                            },
                          ).expand(),
                        if (docId != 0 &&
                            rolesAndPermissionStore.providerDocumentAdd) ...[
                          12.width,
                          AppButton(
                            onTap: () {
                              getMultipleFile(docId);
                            },
                            color: context.primaryLiteColor
                                .withValues(alpha: 0.15),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shapeBorder: RoundedRectangleBorder(
                              borderRadius: radius(8),
                              side: BorderSide(
                                  color: context.primaryLiteColor
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add,
                                    color: context.primaryLiteColor, size: 20),
                                6.width,
                                Text(
                                  languages.lblAddDoc,
                                  style: context.boldTextStyle(
                                      color: context.primaryLiteColor,
                                      size: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              24.height,

              // Uploaded Documents Section
              if (providerDocuments.isNotEmpty) ...[
                Text(
                  languages.lblDocuments,
                  style: context.boldTextStyle(size: 16),
                ),
                16.height,
              ],

              Observer(builder: (context) {
                return AnimatedListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: providerDocuments.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final doc = providerDocuments[index];
                    final isPdf = doc.providerDocument!.contains('.pdf');
                    final isVerified = doc.isVerified == 1;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: boxDecorationDefault(
                        color: context.cardSecondary,
                        borderRadius: radius(12),
                        border: Border.all(
                          color: isVerified
                              ? context.primaryLiteColor.withValues(alpha: 0.5)
                              : context.cardSecondaryBorder,
                          width: isVerified ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: radius(10),
                        child: GestureDetector(
                          onTap: () {
                            if (!isPdf) {
                              ZoomImageScreen(
                                index: 0,
                                galleryImages: [
                                  doc.providerDocument.validate()
                                ],
                              ).launch(context);
                            }
                          },
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              // Document Image/Preview
                              CachedImageWidget(
                                url: isPdf
                                    ? img_files
                                    : doc.providerDocument.validate(),
                                height: 180,
                                width: context.width(),
                                fit: BoxFit.cover,
                              ),

                              // Gradient Overlay with Info
                              Container(
                                padding: const EdgeInsets.all(12),
                                height: 180,
                                width: context.width(),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: FractionalOffset.topCenter,
                                    end: FractionalOffset.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Document Name
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc.documentName.validate(),
                                              style: context.boldTextStyle(
                                                  size: 14,
                                                  color: context.onPrimary),
                                            ),
                                            4.height,
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isVerified
                                                    ? Colors.green
                                                    : Colors.orange,
                                                borderRadius: radius(4),
                                              ),
                                              child: Text(
                                                isVerified
                                                    ? languages.verified
                                                    : languages.pending,
                                                style: context.boldTextStyle(
                                                    size: 10,
                                                    color: context.onPrimary),
                                              ),
                                            ),
                                          ],
                                        ).expand(),

                                        // Action Buttons
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // View PDF Button
                                            if (isPdf)
                                              _buildActionButton(
                                                context: context,
                                                icon: Icons.picture_as_pdf,
                                                color: Colors.red,
                                                onTap: () {
                                                  PdfViewerComponent(
                                                    pdfFile: doc
                                                        .providerDocument
                                                        .validate(),
                                                    isFile: false,
                                                  ).launch(context);
                                                },
                                              ),

                                            // Edit Button (only if not verified)
                                            if (!isVerified &&
                                                rolesAndPermissionStore
                                                    .providerDocumentEdit) ...[
                                              8.width,
                                              _buildActionButton(
                                                context: context,
                                                icon: AntDesign.edit,
                                                color: context.primary,
                                                onTap: () {
                                                  getMultipleFile(
                                                    doc.documentId,
                                                    updateId: doc.id.validate(),
                                                  );
                                                },
                                              ),
                                            ],

                                            // Delete Button (only if not verified)
                                            if (!isVerified &&
                                                rolesAndPermissionStore
                                                    .providerDocumentDelete) ...[
                                              8.width,
                                              _buildActionButton(
                                                context: context,
                                                icon: Icons.delete_outline,
                                                color: Colors.red,
                                                onTap: () {
                                                  showConfirmDialogCustom(
                                                    context,
                                                    dialogType:
                                                        DialogType.DELETE,
                                                    title: languages
                                                        .lblDoYouWantToDelete,
                                                    height: 80,
                                                    width: 290,
                                                    shape: appDialogShape(8),
                                                    backgroundColor: context
                                                        .dialogBackgroundColor,
                                                    titleColor: context
                                                        .dialogTitleColor,
                                                    primaryColor: context.error,
                                                    customCenterWidget:
                                                        Image.asset(
                                                      ic_warning,
                                                      color: context
                                                          .dialogIconColor,
                                                      height: 70,
                                                      width: 70,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    positiveText:
                                                        languages.lblDelete,
                                                    positiveTextColor:
                                                        context.onPrimary,
                                                    negativeText:
                                                        languages.lblNo,
                                                    negativeTextColor:
                                                        context.primary,
                                                    onAccept: (_) {
                                                      ifNotTester(context, () {
                                                        deleteDoc(doc.id);
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            ],

                                            // Verified Badge
                                            if (isVerified) ...[
                                              8.width,
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color:
                                                      context.primaryLiteColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  Icons.check,
                                                  color: context.onPrimary,
                                                  size: 18,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                  emptyWidget: !appStore.isLoading
                      ? NoDataWidget(
                          title: languages.noDocumentFound,
                          subTitle: languages.noDocumentSubTitle,
                          imageWidget: const EmptyStateWidget(),
                        )
                      : null,
                );
              }),
            ],
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: radius(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
