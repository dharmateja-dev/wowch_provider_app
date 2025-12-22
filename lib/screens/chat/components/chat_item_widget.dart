import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/chat_message_model.dart';
import 'package:handyman_provider_flutter/screens/zoom_image_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/cached_image_widget.dart';
import '../../../components/common_file_placeholders.dart';

class ChatItemWidget extends StatefulWidget {
  final ChatMessageModel chatItemData;

  ChatItemWidget({required this.chatItemData});

  @override
  _ChatItemWidgetState createState() => _ChatItemWidgetState();
}

class _ChatItemWidgetState extends State<ChatItemWidget> {
  void initState() {
    super.initState();
    init();
  }

  init() async {}

  void deleteMessage() async {
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primary,
      title: languages.lblConfirmationForDeleteMsg,
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
      onAccept: (c) {
        hideKeyboard(context);
        chatServices
            .deleteSingleMessage(
                senderId: appStore.uid,
                receiverId: widget.chatItemData.receiverId!,
                documentId: widget.chatItemData.uid.validate())
            .then((value) {
          chatServices
              .deleteFiles(widget.chatItemData.attachmentfiles.validate());
        }).catchError((e) {
          log(e.toString());
        });
      },
    );
  }

  void copyMessage() {
    widget.chatItemData.message.validate().copyToClipboard();
    toast(languages.copied);
  }

  @override
  Widget build(BuildContext context) {
    String time = '';

    try {
      DateTime messageDate;

      if (widget.chatItemData.createdAtTime != null) {
        messageDate = widget.chatItemData.createdAtTime!.toDate();
      } else if (widget.chatItemData.createdAt != null) {
        messageDate = DateTime.fromMicrosecondsSinceEpoch(
            widget.chatItemData.createdAt! * 1000);
      } else {
        messageDate = DateTime.now();
      }

      DateTime now = DateTime.now();
      bool isToday = messageDate.day == now.day &&
          messageDate.month == now.month &&
          messageDate.year == now.year;

      if (isToday) {
        // Today: Show time only (e.g., "5:30 PM")
        int hour = messageDate.hour;
        String period = hour >= 12 ? 'PM' : 'AM';
        hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        String minute = messageDate.minute.toString().padLeft(2, '0');
        time = '$hour:$minute $period';
      } else {
        // Previous days: Show full date (e.g., "November 24, 2025")
        List<String> months = [
          'January',
          'February',
          'March',
          'April',
          'May',
          'June',
          'July',
          'August',
          'September',
          'October',
          'November',
          'December'
        ];
        time =
            '${months[messageDate.month - 1]} ${messageDate.day}, ${messageDate.year}';
      }
    } catch (e) {
      time = '';
    }

    // Helper to get text color based on sender
    Color getMessageTextColor() {
      return widget.chatItemData.isMe.validate()
          ? context.chatSentTextColor
          : context.chatReceivedTextColor;
    }

    // Helper to get secondary text color based on sender
    Color getSecondaryTextColor() {
      return widget.chatItemData.isMe.validate()
          ? context.chatSentSecondaryText
          : context.chatReceivedSecondaryText;
    }

    Widget chatItem(String messageTypes) {
      return messageTypes == MessageType.TEXT.name
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: widget.chatItemData.isMe!
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatItemData.message!,
                  style: context.primaryTextStyle(),
                  maxLines: null,
                ),
                1.height,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: context.primaryTextStyle(
                        color: getSecondaryTextColor(),
                        size: 11,
                      ),
                    ),
                    4.width,
                    widget.chatItemData.isMe.validate()
                        ? !widget.chatItemData.isMessageRead.validate()
                            ? Icon(Icons.done,
                                size: 14, color: context.chatTickColor)
                            : Icon(Icons.done_all,
                                size: 14, color: context.chatTickColor)
                        : const Offstage(),
                  ],
                ),
              ],
            )
          : messageTypes == MessageType.Files.name
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: widget.chatItemData.isMe!
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    ...filesComponent(),
                    Text(
                      widget.chatItemData.message!,
                      style: context.primaryTextStyle(
                          color: getMessageTextColor()),
                      maxLines: null,
                    ).paddingTop(2).visible(
                        widget.chatItemData.message!.trim().isNotEmpty),
                    1.height,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: context.primaryTextStyle(
                              color: getSecondaryTextColor(), size: 11),
                        ),
                        4.width,
                        widget.chatItemData.isMe.validate()
                            ? !widget.chatItemData.isMessageRead.validate()
                                ? Icon(Icons.done,
                                    size: 14, color: context.chatTickColor)
                                : Icon(Icons.done_all,
                                    size: 14, color: context.chatTickColor)
                            : Offstage(),
                      ],
                    ),
                  ],
                )
              : Offstage();
    }

    EdgeInsetsGeometry customPadding(String? messageTypes) {
      switch (messageTypes) {
        case TEXT:
          return EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        default:
          return EdgeInsets.symmetric(horizontal: 4, vertical: 4);
      }
    }

    return GestureDetector(
      onLongPress: () async {
        if (widget.chatItemData.messageType != MessageType.TEXT &&
            !widget.chatItemData.isMe.validate()) return;
        int? res = await showInDialog(
          context,
          contentPadding: EdgeInsets.zero,
          builder: (_) {
            return Container(
              width: context.width(),
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.chatItemData.messageType == MessageType.TEXT.name)
                    SettingItemWidget(
                      title: languages.copyMessage,
                      onTap: () {
                        finish(context, 1);
                      },
                    ),
                  if (widget.chatItemData.isMe.validate())
                    SettingItemWidget(
                      title: languages.deleteMessage,
                      onTap: () {
                        finish(context, 2);
                      },
                    ),
                ],
              ),
            );
          },
        );

        if (res == 1) {
          copyMessage();
        } else if (res == 2) {
          deleteMessage();
        }
      },
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.chatItemData.isMe.validate()
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisAlignment: widget.chatItemData.isMe!
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Container(
              margin: widget.chatItemData.isMe.validate()
                  ? EdgeInsets.only(
                      top: 0.0,
                      bottom: 0.0,
                      left: isRTL ? 0 : context.width() * 0.25,
                      right: 8)
                  : EdgeInsets.only(
                      top: 2.0,
                      bottom: 2.0,
                      left: 8,
                      right: isRTL ? 0 : context.width() * 0.25),
              padding: customPadding(widget.chatItemData.messageType),
              decoration: BoxDecoration(
                // Sent message: no border, use chatSentBubble
                // Received message: has border, use chatReceivedBubble
                color: widget.chatItemData.isMe.validate()
                    ? context.chatSentBubble
                    : context.chatReceivedBubble,
                border: widget.chatItemData.isMe.validate()
                    ? null
                    : Border.all(
                        color: context.chatReceivedBubbleBorder, width: 1),
                borderRadius: widget.chatItemData.isMe.validate()
                    ? radiusOnly(
                        bottomLeft: 12,
                        topLeft: 12,
                        bottomRight: 0,
                        topRight: 12)
                    : radiusOnly(
                        bottomLeft: 0,
                        topLeft: 12,
                        bottomRight: 12,
                        topRight: 12),
              ),
              child: chatItem(widget.chatItemData.messageType ?? ""),
            ),
          ],
        ),
        margin: EdgeInsets.only(top: 2, bottom: 2),
      ),
    );
  }

  List<Widget> filesComponent() {
    return widget.chatItemData.attachmentfiles.validate().isNotEmpty
        ? [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    widget.chatItemData.attachmentfiles.validate().map((file) {
                  return GestureDetector(
                    onTap: () {
                      if (file.contains(
                          RegExp(r'\.jpeg|\.jpg|\.gif|\.png|\.bmp'))) {
                        ZoomImageScreen(index: 0, galleryImages: [file])
                            .launch(context);
                      } else {
                        viewFiles(file);
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: LoaderWidget(),
                        ),
                        file.contains(RegExp(r'\.jpeg|\.jpg|\.gif|\.png|\.bmp'))
                            ? CachedImageWidget(
                                url: file,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                radius: 8,
                              )
                            : Container(
                                padding: EdgeInsets.all(4),
                                decoration: boxDecorationRoundedWithShadow(
                                    defaultRadius.toInt(),
                                    backgroundColor:
                                        widget.chatItemData.isMe.validate()
                                            ? context.chatReceivedBubble
                                            : context.primaryContainer),
                                child: CommonPdfPlaceHolder(
                                  text: "${file.getChatFileName}",
                                  fileExt: file.getFileExtension,
                                ),
                              ),
                      ],
                    ).paddingRight(8),
                  );
                }).toList(),
              ),
            ),
          ]
        : [];
  }
}
