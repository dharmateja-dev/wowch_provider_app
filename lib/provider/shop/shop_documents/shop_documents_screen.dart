import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/empty_error_state_widget.dart';
import 'package:handyman_provider_flutter/components/pdf_viewer_component.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/document_list_response.dart';
import 'package:handyman_provider_flutter/models/provider_document_list_response.dart';
import 'package:handyman_provider_flutter/models/shop_model.dart';
import 'package:handyman_provider_flutter/networks/network_utils.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/shop/shop_list_screen.dart';
import 'package:handyman_provider_flutter/screens/zoom_image_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

// Dummy data for testing UI
final List<ShopModel> dummyShops = [
  ShopModel(id: 1, name: 'Downtown Service Center'),
  ShopModel(id: 2, name: 'Uptown Repair Shop'),
  ShopModel(id: 3, name: 'Central Plaza Store'),
];

final List<Documents> dummyDocuments = [
  Documents(id: 1, name: 'Shop License', status: 1, isRequired: 1),
  Documents(id: 2, name: 'Business Registration', status: 1, isRequired: 1),
  Documents(id: 3, name: 'Tax Certificate', status: 1, isRequired: 0),
  Documents(id: 4, name: 'Insurance Document', status: 1, isRequired: 1),
  Documents(
      id: 5, name: 'Health & Safety Certificate', status: 1, isRequired: 0),
];

final List<ProviderDocuments> dummyShopDocuments = [
  ProviderDocuments(
    id: 1,
    providerId: 1,
    documentId: 1,
    documentName: 'Shop License',
    isVerified: 1,
    shopId: 1,
    shopName: 'Downtown Service Center',
    shopDocument:
        'https://images.unsplash.com/photo-1554224155-6726b3ff858f?w=400',
  ),
  ProviderDocuments(
    id: 2,
    providerId: 1,
    documentId: 2,
    documentName: 'Business Registration',
    isVerified: 0,
    shopId: 1,
    shopName: 'Downtown Service Center',
    shopDocument:
        'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=400',
  ),
  ProviderDocuments(
    id: 3,
    providerId: 1,
    documentId: 4,
    documentName: 'Insurance Document (PDF)',
    isVerified: 1,
    shopId: 2,
    shopName: 'Uptown Repair Shop',
    shopDocument: 'https://example.com/insurance.pdf',
  ),
  ProviderDocuments(
    id: 4,
    providerId: 1,
    documentId: 1,
    documentName: 'Shop License',
    isVerified: 0,
    shopId: 2,
    shopName: 'Uptown Repair Shop',
    shopDocument:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
  ),
];

class ShopDocumentsScreen extends StatefulWidget {
  @override
  _ShopDocumentsScreenState createState() => _ShopDocumentsScreenState();
}

class _ShopDocumentsScreenState extends State<ShopDocumentsScreen> {
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
  int page = 1;
  bool isLastPage = false;

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
      providerDocuments = dummyShopDocuments;
      providerDocuments.forEach((element) {
        uploadedDocList!.add(element.documentId!);
        updateDocId = element.id;
      });
      setState(() {});
    } else {
      appStore.setLoading(true);
      Future.wait([
        getDocumentList(),
        getProviderDocList(),
      ]).whenComplete(() => appStore.setLoading(false)).catchError((e) {
        toast(e.toString());
        throw e;
      });
    }
  }

//get Document list
  Future<void> getDocumentList() async {
    await getDocTypeList(
      DocumentType.shop_document.name,
    ).then((res) {
      documents.addAll(res.documents!);
    }).catchError((e) {
      toast(e.toString());
      throw e;
    }).whenComplete(() => appStore.setLoading(false));
  }

  //SelectImage
  void getMultipleFile(int? docId, {int? updateId}) async {
    if (selectedShop == null && updateId == null) {
      toast(languages.lblSelectShops);
      return;
    }
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
    }
  }

  String? shopIdValue;

  //Add Documents
  void addDocument(int? docId, {int? updateId}) async {
    MultipartRequest multiPartRequest =
        await getMultiPartRequest('shop-document-save');
    if (updateId != null) {
      final doc = providerDocuments.firstWhere((e) => e.id == updateId);
      shopIdValue = doc.shopId.toString();
    } else {
      shopIdValue = selectedShop!.id.toString();
    }
    multiPartRequest.fields[CommonKeys.id] =
        updateId != null ? updateId.toString() : '';
    multiPartRequest.fields[CommonKeys.shopId] = shopIdValue.validate();
    multiPartRequest.fields[AddDocument.documentId] = docId.toString();
    multiPartRequest.fields[AddDocument.isVerified] = '0';

    if (imageFiles != null) {
      multiPartRequest.files.add(await MultipartFile.fromPath(
          AddDocument.shopDocument, imageFiles!.first.path));
    }
    log(multiPartRequest);

    multiPartRequest.headers.addAll(buildHeaderTokens());
    appStore.setLoading(true);

    await sendMultiPartRequest(
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
  Future<void> getProviderDocList() async {
    await getShopDoc(
      page: page,
      documents: providerDocuments,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    ).then((res) {
      appStore.setLoading(false);
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
    deleteShopDoc(id).then((value) {
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

  ShopModel? selectedShop;

  List<Documents> get _availableDocumentsForSelectedShop {
    if (selectedShop == null) return documents;
    final Set<int> uploadedForThisShop = providerDocuments
        .where((e) => e.shopId == selectedShop!.id)
        .map((e) => e.documentId)
        .whereType<int>()
        .toSet();
    return documents.where((d) => !uploadedForThisShop.contains(d.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: appBarWidget(
        languages.lblShopDocument,
        textColor: context.onPrimary,
        color: context.primary,
        backWidget: BackWidget(),
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
              // Shop Selection Card
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
                    // Shop Selection
                    Text(
                      languages.lblSelectShops,
                      style: context.boldTextStyle(),
                    ),
                    8.height,
                    AppTextField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: selectedShop != null
                            ? selectedShop!.name.validate()
                            : "",
                      ),
                      textFieldType: TextFieldType.OTHER,
                      decoration: inputDecoration(
                        context,
                        hintText: languages.lblSelectShops,
                        fillColor: context.profileInputFillColor,
                      ),
                      onTap: () async {
                        if (useDummyData) {
                          // Show dummy shop selection
                          _showDummyShopSelection();
                        } else {
                          final shopId =
                              await ShopListScreen(fromShopDocument: true)
                                  .launch(context);
                          if (shopId != null) {
                            selectedShop = shopId;
                            if (selectedDoc != null) {
                              final stillAvailable =
                                  _availableDocumentsForSelectedShop
                                      .any((d) => d.id == selectedDoc!.id);
                              if (!stillAvailable) {
                                selectedDoc = null;
                                docId = 0;
                              }
                            }
                            setState(() {});
                          }
                        }
                      },
                    ),

                    16.height,

                    // Document Type Selection
                    Text(
                      languages.lblSelectDoc,
                      style: context.boldTextStyle(),
                    ),
                    8.height,
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

                    if (selectedShop != null &&
                        _availableDocumentsForSelectedShop.isEmpty) ...[
                      12.height,
                      Text(
                        languages.noDocumentFound,
                        style: context.secondaryTextStyle(),
                      ),
                    ],
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

              // Documents List
              AnimatedListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: providerDocuments.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final doc = providerDocuments[index];
                  final isPdf = doc.shopDocument != null &&
                      doc.shopDocument!.contains('.pdf');
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
                      borderRadius: radius(12),
                      child: GestureDetector(
                        onTap: () {
                          if (doc.shopDocument != null && !isPdf) {
                            ZoomImageScreen(
                              index: 0,
                              galleryImages: [doc.shopDocument.validate()],
                            ).launch(context);
                          }
                        },
                        child: Stack(
                          children: [
                            // Document Image/Preview
                            CachedImageWidget(
                              url: isPdf
                                  ? img_files
                                  : doc.shopDocument.validate(),
                              height: 200,
                              width: context.width(),
                              fit: BoxFit.cover,
                            ),

                            // Top Gradient with Shop Name
                            Container(
                              height: 200,
                              width: context.width(),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.center,
                                  colors: [
                                    context.primary.withValues(alpha: 0.8),
                                    context.primary.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              alignment: Alignment.topLeft,
                              child: Text(
                                doc.shopName.validate(),
                                style: context.boldTextStyle(
                                    size: 14, color: context.onPrimary),
                              ),
                            ),

                            // Bottom Gradient with Document Info
                            Container(
                              height: 200,
                              width: context.width(),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                                    context.primary.withValues(alpha: 0.9),
                                    context.primary.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                children: [
                                  // Document Name & Status
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.documentName.validate(),
                                        style: context.boldTextStyle(
                                            size: 14, color: context.onPrimary),
                                      ),
                                      4.height,
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isVerified
                                              ? context.primaryLiteColor
                                              : context.iconMuted,
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
                                          color: context.error,
                                          onTap: () {
                                            PdfViewerComponent(
                                              pdfFile:
                                                  doc.shopDocument.validate(),
                                              isFile: false,
                                            ).launch(context);
                                          },
                                        ),

                                      // Edit Button
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

                                      // Delete Button
                                      if (!isVerified &&
                                          rolesAndPermissionStore
                                              .providerDocumentDelete) ...[
                                        8.width,
                                        _buildActionButton(
                                          context: context,
                                          icon: Icons.delete_outline,
                                          color: context.error,
                                          onTap: () {
                                            showConfirmDialogCustom(
                                              context,
                                              dialogType: DialogType.DELETE,
                                              title: languages
                                                  .lblDoYouWantToDelete,
                                              height: 80,
                                              width: 290,
                                              shape: appDialogShape(8),
                                              backgroundColor:
                                                  context.dialogBackgroundColor,
                                              titleColor:
                                                  context.dialogTitleColor,
                                              primaryColor: context.error,
                                              customCenterWidget: Image.asset(
                                                ic_warning,
                                                color: context.dialogIconColor,
                                                height: 70,
                                                width: 70,
                                                fit: BoxFit.cover,
                                              ),
                                              positiveText: languages.lblDelete,
                                              positiveTextColor:
                                                  context.onPrimary,
                                              negativeText: languages.lblNo,
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
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: context.primaryLiteColor,
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
              ),
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
          color: context.cardSecondary.withValues(alpha: 0.9),
          borderRadius: radius(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  void _showDummyShopSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.bottomSheetBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: boxDecorationDefault(
                    borderRadius: radius(60),
                    color: context.iconMuted,
                  ),
                ),
              ),
              16.height,
              Text(
                languages.lblSelectShops,
                style: context.boldTextStyle(size: 18),
              ),
              16.height,
              ...dummyShops.map((shop) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: boxDecorationDefault(
                    color: context.cardSecondary,
                    borderRadius: radius(8),
                    border: Border.all(color: context.cardSecondaryBorder),
                  ),
                  child: ListTile(
                    title: Text(
                      shop.name.validate(),
                      style: context.primaryTextStyle(),
                    ),
                    trailing:
                        Icon(Icons.chevron_right, color: context.iconMuted),
                    onTap: () {
                      selectedShop = shop;
                      if (selectedDoc != null) {
                        final stillAvailable =
                            _availableDocumentsForSelectedShop
                                .any((d) => d.id == selectedDoc!.id);
                        if (!stillAvailable) {
                          selectedDoc = null;
                          docId = 0;
                        }
                      }
                      setState(() {});
                      Navigator.pop(ctx);
                    },
                  ),
                );
              }),
              16.height,
            ],
          ),
        );
      },
    );
  }
}
