import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/extensions/string_extension.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../main.dart';
import '../utils/constant.dart';
import '../utils/firebase_messaging_utils.dart';
import '../utils/images.dart';

class SwitchPushNotificationSubscriptionComponent extends StatefulWidget {
  const SwitchPushNotificationSubscriptionComponent({Key? key})
      : super(key: key);

  @override
  State<SwitchPushNotificationSubscriptionComponent> createState() =>
      _SwitchPushNotificationSubscriptionComponentState();
}

class _SwitchPushNotificationSubscriptionComponentState
    extends State<SwitchPushNotificationSubscriptionComponent> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isSubscribed =
      getBoolAsync("IS_SUBSCRIBED_NOTIFICATION", defaultValue: true);

  void init() async {
    await appStore.setPushNotificationSubscriptionStatus(isSubscribed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => SettingItemWidget(
        leading: ic_notification.iconImage(context: context, size: 18),
        title: languages.pushNotification,
        titleTextStyle: context.boldTextStyle(),
        padding: EdgeInsets.all(16),
        decoration: boxDecorationDefault(
          color: context.scaffoldSecondary,
          borderRadius: radius(),
        ),
        trailing: Transform.scale(
          scale: 0.6,
          child: Switch.adaptive(
            value: FirebaseAuth.instance.currentUser != null &&
                getBoolAsync(IS_SUBSCRIBED_NOTIFICATION, defaultValue: true),
            onChanged: (v) async {
              await setValue(IS_SUBSCRIBED_NOTIFICATION, v);
              if (appStore.isLoading) return;
              appStore.setLoading(true);

              if (v) {
                await subscribeToFirebaseTopic();
              } else {
                await unsubscribeFirebaseTopic(appStore.userId);
              }

              appStore.setLoading(false);
              setState(() {});
            },
          ).withHeight(16),
        ),
      ),
    );
  }
}
