import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/components/handyman_add_update_screen.dart';
import 'package:handyman_provider_flutter/components/handyman_name_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/screens/chat/user_chat_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/images.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanWidget extends StatefulWidget {
  final double width;
  final UserData? data;
  final Function? onUpdate;

  HandymanWidget({required this.width, this.data, this.onUpdate});

  @override
  State<HandymanWidget> createState() => _HandymanWidgetState();
}

class _HandymanWidgetState extends State<HandymanWidget> {
  Future<void> changeStatus(int? id, int status) async {
    appStore.setLoading(true);

    Map request = {CommonKeys.id: id, UserKeys.status: status};

    await updateHandymanStatus(request).then((value) {
      appStore.setLoading(false);
      toast(value.message.toString(), print: true);
      widget.onUpdate?.call();
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);

      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: widget.width,
          decoration: boxDecorationWithRoundedCorners(
              borderRadius: radius(),
              backgroundColor: context.cardSecondary,
              border: Border.all(color: context.cardSecondaryBorder)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: radius(),
                  backgroundColor: context.primary.withValues(alpha: 0.2),
                ),
                child: CachedImageWidget(
                  url: widget.data?.profileImage?.isNotEmpty == true
                      ? widget.data!.profileImage.validate()
                      : '',
                  width: context.width(),
                  height: 120,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRectOnly(
                  topRight: defaultRadius.toInt(),
                  topLeft: defaultRadius.toInt(),
                  bottomLeft: defaultRadius.toInt(),
                  bottomRight: defaultRadius.toInt(),
                ),
              ),
              Column(
                children: [
                  HandymanNameWidget(
                    name:
                        '${widget.data!.firstName.validate()} ${widget.data!.lastName.validate()}',
                    isHandymanAvailable: widget.data!.isHandymanAvailable,
                    size: 14,
                  ).center(),
                  12.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.data!.contactNumber.validate().isNotEmpty)
                        TextIcon(
                          onTap: () {
                            launchCall(widget.data!.contactNumber.validate());
                          },
                          prefix: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              backgroundColor:
                                  context.primary.withValues(alpha: 0.1),
                            ),
                            child: Image.asset(
                              calling,
                              color: context.primary,
                              height: 14,
                              width: 14,
                            ),
                          ),
                        ),
                      if (widget.data!.email.validate().isNotEmpty)
                        TextIcon(
                          onTap: () {
                            launchMail(widget.data!.email.validate());
                          },
                          prefix: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              backgroundColor:
                                  context.primary.withValues(alpha: 0.1),
                            ),
                            child: ic_message.iconImage(
                              context: context,
                              size: 14,
                              color: context.primary,
                            ),
                          ),
                        ),
                      if (widget.data!.contactNumber.validate().isNotEmpty)
                        TextIcon(
                          onTap: () async {
                            toast(languages.pleaseWaitWhileWeLoadChatDetails);
                            UserData? user = await userService.getUserNull(
                              email: widget.data!.email.validate(),
                            );
                            if (user != null) {
                              Fluttertoast.cancel();
                              UserChatScreen(receiverUser: user)
                                  .launch(context);
                            } else {
                              Fluttertoast.cancel();
                              toast(
                                "${widget.data!.firstName.validate()} ${languages.isNotAvailableForChat}",
                              );
                            }
                          },
                          prefix: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: boxDecorationWithRoundedCorners(
                              boxShape: BoxShape.circle,
                              backgroundColor:
                                  context.primary.withValues(alpha: 0.1),
                            ),
                            child: Image.asset(
                              textMsg,
                              color: context.primary,
                              height: 14,
                              width: 14,
                            ),
                          ),
                        ),
                    ],
                  ).fit(),
                ],
              ).paddingSymmetric(vertical: 12),
            ],
          ),
        ).onTap(
          () {
            HandymanAddUpdateScreen(
              userType: USER_TYPE_HANDYMAN,
              data: widget.data,
              onUpdate: () {
                widget.onUpdate?.call();
              },
            ).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
          },
          borderRadius: radius(),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.cardSecondary,
              border: Border.all(color: context.cardSecondaryBorder),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.power_settings_new_rounded,
              size: 18,
              color: widget.data!.isActive ? context.primary : context.error,
            ),
          ).onTap(() {
            ifNotTester(context, () {
              if (!widget.data!.isActive) {
                changeStatus(widget.data!.id, 1);
              } else {
                changeStatus(widget.data!.id, 0);
              }
              widget.data!.isActive = !widget.data!.isActive;
            });
            setState(() {});
          }),
        ),
      ],
    );
  }
}
