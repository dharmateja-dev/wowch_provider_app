import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/chat_message_model.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/configs.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class UserItemWidget extends StatefulWidget {
  final String userUid;

  UserItemWidget({required this.userUid});

  @override
  State<UserItemWidget> createState() => _UserItemWidgetState();
}

class _UserItemWidgetState extends State<UserItemWidget> {
  Widget typeWidget(ChatMessageModel message) {
    String? type = message.messageType;
    switch (type) {
      case TEXT:
        return Text(
          "${message.message.validate()}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: secondaryTextStyle(size: 14),
        );
      case IMAGE:
        return Row(
          children: [
            Icon(Icons.photo_sharp, size: 16),
            6.width,
            Text(languages.lblImage, style: secondaryTextStyle(size: 16)),
          ],
        );
      case VIDEO:
        return Row(
          children: [
            Icon(Icons.videocam_outlined, size: 16),
            6.width,
            Text(languages.lblVideo, style: secondaryTextStyle(size: 16)),
          ],
        );
      case AUDIO:
        return Row(
          children: [
            Icon(Icons.audiotrack, size: 16),
            6.width,
            Text(languages.lblAudio, style: secondaryTextStyle(size: 16)),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserData>(
      stream: userService.singleUser(widget.userUid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          // Show a smaller loading/empty state to avoid flickering
          return SizedBox.shrink();
        }
        if (snap.hasError || !snap.hasData || snap.data == null) {
          return SizedBox.shrink();
        }
        UserData data = snap.data!;

        return StreamBuilder<QuerySnapshot>(
          stream: chatServices.fetchLastMessageBetween(
              senderId: appStore.uid.validate(), receiverId: widget.userUid),
          builder: (context, messageSnap) {
            ChatMessageModel? lastMessage;
            String time = '';

            if (messageSnap.hasData && messageSnap.data!.docs.isNotEmpty) {
              lastMessage = ChatMessageModel.fromJson(
                  messageSnap.data!.docs.last.data() as Map<String, dynamic>);

              DateTime date = DateTime.fromMicrosecondsSinceEpoch(
                  lastMessage.createdAt! * 1000);
              if (date.isToday) {
                time = formatDate(lastMessage.createdAt.validate().toString(),
                    format: DATE_FORMAT_3,
                    isFromMicrosecondsSinceEpoch: true,
                    isTime: true);
              } else if (date.isYesterday) {
                time = languages.yesterday;
              } else {
                time = formatDate(
                  lastMessage.createdAt.validate().toString(),
                  format: DATE_FORMAT_1,
                  isFromMicrosecondsSinceEpoch: true,
                );
              }
              lastMessage.isMe = lastMessage.senderId == appStore.uid;
            }

            return InkWell(
              onTap: () {
                UserChatScreen(receiverUser: data).launch(context,
                    pageRouteAnimation: PageRouteAnimation.Fade,
                    duration: 300.milliseconds);
              },
              child: Container(
                padding: EdgeInsets.all(8),
                color: context.cardSecondary,
                child: Row(
                  children: [
                    if (data.profileImage.validate().isEmpty)
                      Container(
                        height: 45,
                        width: 45,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: context.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          data.displayName
                              .validate()[0]
                              .validate()
                              .toUpperCase(),
                          style: context.boldTextStyle(
                              color: context.primary, size: 18),
                        ).center().fit(),
                      )
                    else
                      CachedImageWidget(
                          url: data.profileImage.validate(),
                          height: 45,
                          width: 45,
                          circle: true,
                          fit: BoxFit.cover),
                    16.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data.firstName.validate() +
                                  " " +
                                  data.lastName.validate(),
                              style: context.boldTextStyle(),
                              maxLines: 1,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ).expand(),
                          ],
                        ),
                        4.height,
                        Row(
                          children: [
                            if (lastMessage != null &&
                                lastMessage.isMe.validate())
                              !lastMessage.isMessageRead.validate()
                                  ? Icon(Icons.done,
                                          size: 14,
                                          color: textSecondaryColorGlobal)
                                      .paddingRight(4)
                                  : Icon(Icons.done_all,
                                          size: 14, color: Colors.blue)
                                      .paddingRight(4),
                            if (lastMessage != null)
                              typeWidget(lastMessage).expand(),
                            StreamBuilder<int>(
                              stream: chatServices.getUnReadCount(
                                  senderId: appStore.uid.validate(),
                                  receiverId: data.uid.validate()),
                              builder: (context, snap) {
                                if (snap.hasData && snap.data != 0) {
                                  return Container(
                                    height: 18,
                                    width: 18,
                                    margin: EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        color: context.primary),
                                    child: Text(
                                      snap.data.validate().toString(),
                                      style: context.primaryTextStyle(
                                          color: context.onPrimary, size: 10),
                                      textAlign: TextAlign.center,
                                    ).center(),
                                  );
                                }
                                return Offstage();
                              },
                            ),
                            if (lastMessage != null)
                              Text(
                                time,
                                style: context.primaryTextStyle(size: 12),
                              ),
                          ],
                        ),
                      ],
                    ).expand()
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
