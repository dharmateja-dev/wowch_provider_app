import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_screen.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_data.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

/// Demo Chat Item Widget - for displaying chat list items in demo mode
/// This widget doesn't use Firebase streams and shows static demo data
class DemoChatItemWidget extends StatelessWidget {
  final UserData contact;

  const DemoChatItemWidget({required this.contact, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String lastMessage =
        DemoChatData.lastMessages[contact.uid.validate()] ?? 'Hi';
    final bool isRead = contact.id.validate() % 2 == 0;

    return InkWell(
      onTap: () {
        UserChatScreen(receiverUser: contact).launch(
          context,
          pageRouteAnimation: PageRouteAnimation.Fade,
          duration: 300.milliseconds,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        color: context.cardSecondary,
        child: Row(
          children: [
            // Profile Image
            if (contact.profileImage.validate().isEmpty)
              Container(
                height: 45,
                width: 45,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  contact.firstName.validate().substring(0, 1).toUpperCase(),
                  style:
                      context.boldTextStyle(color: context.primary, size: 18),
                ).center().fit(),
              )
            else
              CachedImageWidget(
                url: contact.profileImage.validate(),
                height: 45,
                width: 45,
                circle: true,
                fit: BoxFit.cover,
              ),
            16.width,

            // Name and Last Message
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${contact.firstName.validate()} ${contact.lastName.validate()}",
                      style: context.boldTextStyle(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).expand(),
                  ],
                ),
                4.height,
                Row(
                  children: [
                    // Read/Unread indicator
                    Icon(
                      isRead ? Icons.done_all : Icons.done,
                      size: 14,
                      color: isRead ? Colors.blue : textSecondaryColorGlobal,
                    ),
                    4.width,
                    Text(
                      lastMessage,
                      style: context.primaryTextStyle(size: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ).expand(),
                    Text(
                      DemoChatData.lastMessageTime,
                      style: context.primaryTextStyle(size: 12),
                    ),
                  ],
                ),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
