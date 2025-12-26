import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_pagination/firebase_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/chat_message_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/firebase_services/notification_service.dart';
import 'package:handyman_provider_flutter/screens/chat/components/chat_item_widget.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/cached_image_widget.dart';
import '../../networks/firebase_services/chat_messages_service.dart';
import '../../utils/getImage.dart';
import 'components/send_file_screen.dart';

class UserChatScreen extends StatefulWidget {
  final UserData receiverUser;
  final bool isChattingAllow;

  UserChatScreen({required this.receiverUser, this.isChattingAllow = false});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen>
    with WidgetsBindingObserver {
  TextEditingController messageCont = TextEditingController();

  FocusNode messageFocus = FocusNode();

  UserData senderUser = UserData();

  StreamSubscription? _streamSubscription;

  int isReceiverOnline = 0;

  bool get isReceiverUserOnline => isReceiverOnline == 1;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    WidgetsBinding.instance.addObserver(this);

    if (widget.receiverUser.uid.validate().isEmpty) {
      await userService
          .getUser(email: widget.receiverUser.email.validate())
          .then((value) {
        widget.receiverUser.uid = value.uid;
      }).catchError((e) {
        log(e.toString());
      });
    }

    senderUser =
        await userService.getUser(email: appStore.userEmail.validate());

    setState(() {});

    if (await userService.isReceiverInContacts(
        senderUserId: appStore.uid.validate(),
        receiverUserId: widget.receiverUser.uid.validate())) {
      await chatServices
          .setUnReadStatusToTrue(
              senderId: appStore.uid.validate(),
              receiverId: widget.receiverUser.uid.validate())
          .catchError((e) {
        toast(e.toString());
      });

      log("receiver ID ${widget.receiverUser.uid}");
      chatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 1);
      //
      _streamSubscription = chatServices
          .isReceiverOnline(
              senderId: appStore.uid.validate(),
              receiverUserId: widget.receiverUser.uid.validate())
          .listen((event) {
        isReceiverOnline = event.isOnline.validate();
        log("=======*=======*=======*=======*=======* Provider $isReceiverOnline =======*=======*=======*=======*=======");
      });
    }
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
          onFieldSubmitted: (s) {
            sendMessages();
          },
          focus: messageFocus,
          cursorHeight: 20,
          maxLines: 5,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.multiline,
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: ic_attachments.iconImage(
                    size: 22, color: context.onSurface, context: context),
                onPressed: () {
                  if (!appStore.isLoading) {
                    _handleDocumentClick();
                  }
                },
              ),
              IconButton(
                icon: ic_cam_attachments.iconImage(
                    size: 24, color: context.onSurface, context: context),
                onPressed: () {
                  if (!appStore.isLoading) {
                    _handleCameraClick();
                  }
                },
              ),
            ],
          ),
          decoration: inputDecoration(context,
              hintText: languages.lblMessage,
              showBorder: false,
              fillColor: context.cardSecondary,
              hintTextColor: context.textGrey),
        ).expand(),
        8.width,
        Container(
          height: 45,
          width: 45,
          decoration: boxDecorationDefault(
              borderRadius: radius(80), color: context.primary),
          child: IconButton(
            icon: ic_plain.iconImage(
                context: context, size: 24, color: context.onPrimary),
            onPressed: () {
              sendMessages();
            },
          ),
        )
      ],
    );
  }

  //endregion

  //region Methods
  Future<void> sendMessages({
    bool isFile = false,
    List<String> attachmentfiles = const [],
  }) async {
    if (appStore.isLoading) return;

    // If Message TextField is Empty.
    if (messageCont.text.trim().isEmpty && !isFile) {
      messageFocus.requestFocus();
      return;
    } else if (isFile && attachmentfiles.isEmpty) {
      return;
    }

    // Making Request for sending data to firebase
    ChatMessageModel data = ChatMessageModel();

    data.receiverId = widget.receiverUser.uid;
    data.senderId = appStore.uid;
    data.message = messageCont.text;
    data.isMessageRead = isReceiverOnline == 1;
    data.createdAt = DateTime.now().millisecondsSinceEpoch;
    data.createdAtTime = Timestamp.now();
    data.updatedAtTime = Timestamp.now();
    data.messageType = isFile ? MessageType.Files.name : MessageType.TEXT.name;
    data.attachmentfiles = attachmentfiles;
    // log('ChatMessageModel Data : ${data.toJson()}');

    messageCont.clear();

    if (!(await userService.isReceiverInContacts(
        senderUserId: appStore.uid.validate(),
        receiverUserId: widget.receiverUser.uid.validate()))) {
      log("========Adding To Contacts=========");
      await chatServices.addToContacts(
        senderId: data.senderId,
        receiverId: data.receiverId,
        receiverName: widget.receiverUser.displayName.validate(),
        senderName: senderUser.displayName.validate(),
      );
      _streamSubscription = chatServices
          .isReceiverOnline(
              senderId: appStore.uid.validate(),
              receiverUserId: widget.receiverUser.uid.validate())
          .listen((event) {
        isReceiverOnline = event.isOnline.validate();
        log("=======*=======*=======*=======*=======* User $isReceiverOnline =======*=======*=======*=======*=======");
      });
    }

    await chatServices.addMessage(data).then((value) async {
      log("--Message Successfully Added--");

      if (isReceiverOnline != 1) {
        /// Send Notification
        NotificationService()
            .sendPushNotifications(
          appStore.userFullName,
          data.message.validate(),
          image: data.attachmentfiles == null || data.attachmentfiles!.isEmpty
              ? null
              : data.attachmentfiles!.first,
          receiverUser: widget.receiverUser,
          senderUserData: senderUser,
        )
            .catchError((e) {
          log("Notification Error ${e.toString()}");
        });
      }

      /// Save receiverId to Sender Doc.
      userService
          .saveToContacts(
              senderId: appStore.uid,
              receiverId: widget.receiverUser.uid.validate())
          .then((value) => log("---ReceiverId to Sender Doc.---"))
          .catchError((e) {
        log(e.toString());
      });

      /// Save senderId to Receiver Doc.
      userService
          .saveToContacts(
              senderId: widget.receiverUser.uid.validate(),
              receiverId: appStore.uid)
          .then((value) => log("---SenderId to Receiver Doc.---"))
          .catchError((e) {
        log(e.toString());
      });

      /// ENd
    }).catchError((e) {
      log(e.toString());
    });
  }

  //endregion

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.detached) {
      chatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 0);
    }

    if (state == AppLifecycleState.paused) {
      chatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 0);
    }
    if (state == AppLifecycleState.resumed) {
      chatServices.setOnlineCount(
          senderId: widget.receiverUser.uid.validate(),
          receiverId: appStore.uid.validate(),
          status: 1);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    chatServices.setOnlineCount(
        senderId: widget.receiverUser.uid.validate(),
        receiverId: appStore.uid.validate(),
        status: 0);

    _streamSubscription?.cancel();

    setStatusBarColor(transparentColor,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.dark);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: context.scaffold,
        appBar: AppBar(
          backgroundColor: context.primary,
          centerTitle: true,
          title: Text(
            widget.receiverUser.firstName.validate() +
                " " +
                widget.receiverUser.lastName.validate(),
            style: context.boldTextStyle(
                color: context.onPrimary, size: APP_BAR_TEXT_SIZE),
          ),
          leadingWidth: context.width(),
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: context.primary,
              statusBarBrightness: context.statusBarBrightness,
              statusBarIconBrightness: context.statusBarBrightness),
          leading: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                padding: EdgeInsets.symmetric(horizontal: 8),
                onPressed: () {
                  finish(context);
                },
                icon: Icon(Icons.arrow_back_ios, color: context.onPrimary),
              ),
              CachedImageWidget(
                  url: widget.receiverUser.profileImage.validate(),
                  height: 36,
                  circle: true,
                  fit: BoxFit.cover),
              12.width,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.receiverUser.firstName.validate() + " " + widget.receiverUser.lastName.validate()}",
                    style: context.boldTextStyle(
                        color: context.onPrimary, size: APP_BAR_TEXT_SIZE),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ).expand(),
              40.width,
            ],
          ),
          actions: [
            PopupMenuButton(
              onSelected: (index) {
                if (index == 0) {
                  showConfirmDialogCustom(
                    height: 80,
                    width: 290,
                    context,
                    dialogType: DialogType.CONFIRMATION,
                    primaryColor: context.primary,
                    title: languages.clearChatMessage,
                    positiveText: languages.lblYes,
                    negativeText: languages.lblNo,
                    titleColor: context.dialogTitleColor,
                    backgroundColor: context.dialogBackgroundColor,
                    negativeTextColor: context.dialogCancelColor,
                    positiveTextColor: context.onPrimary,
                    shape: appDialogShape(8),
                    customCenterWidget: Image.asset(
                      ic_warning,
                      color: context.dialogIconColor,
                      height: 80,
                      width: 80,
                    ),
                    onAccept: (c) async {
                      appStore.setLoading(true);
                      await chatServices
                          .clearAllMessages(
                              senderId: appStore.uid,
                              receiverId: widget.receiverUser.uid.validate())
                          .then((value) {
                        toast(languages.chatCleared);
                        hideKeyboard(context);
                      }).catchError((e) {
                        toast(e);
                      });
                      appStore.setLoading(false);
                    },
                  );
                }
              },
              icon: Icon(Icons.more_vert_sharp, color: context.onPrimary),
              color: context.cardSecondary,
              itemBuilder: (context) {
                List<PopupMenuItem> list = [];
                list.add(
                  PopupMenuItem(
                    value: 0,
                    child: Text(languages.clearChat,
                        style: context.primaryTextStyle()),
                  ),
                );
                return list;
              },
            )
          ],
        ),
        body: SizedBox(
          height: context.height(),
          width: context.width(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                margin:
                    EdgeInsets.only(bottom: widget.isChattingAllow ? 0 : 80),
                child: FirestorePagination(
                  reverse: true,
                  isLive: true,
                  padding:
                      EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                  physics: BouncingScrollPhysics(),
                  query: chatServices.chatMessagesWithPagination(
                      senderId: appStore.uid.validate(),
                      receiverUserId: widget.receiverUser.uid.validate()),
                  initialLoader: LoaderWidget(),
                  limit: PER_PAGE_CHAT_LIST_COUNT,
                  onEmpty: Center(
                    child: Text(
                      languages.noConversation,
                      style: context.primaryTextStyle(),
                    ),
                  ),
                  shrinkWrap: true,
                  viewType: ViewType.list,
                  itemBuilder: (context, snap, index) {
                    ChatMessageModel data = ChatMessageModel.fromJson(
                        snap[index].data() as Map<String, dynamic>);
                    data.isMe = data.senderId == appStore.uid;
                    data.chatDocumentReference = snap[index].reference;

                    return ChatItemWidget(chatItemData: data);
                  },
                ),
              ),
              if (!widget.isChattingAllow)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: _buildChatFieldWidget(),
                ),
              Observer(
                  builder: (context) =>
                      LoaderWidget().visible(appStore.isLoading)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDocumentClick() async {
    appStore.setLoading(true);
    await pickFiles(
      allowedExtensions: chatFilesAllowedExtensions,
      maxFileSizeMB: max_acceptable_file_size,
      type: FileType.custom,
    ).then((pickedfiles) async {
      await handleUploadAndSendFiles(pickedfiles);
    }).catchError((e) {
      toast(e);
      log('ChatServices().uploadFiles Err: ${e}');
      return;
    }).whenComplete(() => appStore.setLoading(false));
  }

  Future<void> _handleCameraClick() async {
    GetImage(ImageSource.camera, path: (path, name, xFile) async {
      log('Path camera : ${path.toString()} name $name');
      await handleUploadAndSendFiles([File(xFile.path)]);
      setState(() {});
    });
  }

  Future<void> handleUploadAndSendFiles(List<File> pickedfiles) async {
    if (pickedfiles.isEmpty) return;
    await SendFilePreviewScreen(pickedfiles: pickedfiles)
        .launch(context)
        .then((value) async {
      if (value[MessageType.Files.name] is List<File>) {
        pickedfiles = value[MessageType.Files.name];
      }

      if (value[MessageType.TEXT.name] is String) {
        messageCont.text = value[MessageType.TEXT.name];
      }

      if (messageCont.text.trim().isNotEmpty || pickedfiles.isNotEmpty) {
        appStore.setLoading(true);
        await ChatServices()
            .uploadFiles(pickedfiles)
            .then((attachedfiles) async {
          if (attachedfiles.isEmpty) return;
          log('ATTACHEDFILES: ${attachedfiles}');
          await sendMessages(isFile: true, attachmentfiles: attachedfiles)
              .whenComplete(() => appStore.setLoading(false));
        }).catchError((e) {
          toast(e);
          log('ChatServices().uploadFiles Err: ${e}');
          return;
        }).whenComplete(() => appStore.setLoading(false));
      }
    });
  }
}
