import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

class HtmlWidget extends StatelessWidget {
  final String? postContent;
  final Color? color;
  final String? title;

  HtmlWidget({this.postContent, this.color, this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        title.validate(),
        elevation: 0,
        backWidget: BackWidget(),
        color: context.primary,
        textColor: context.onPrimary,
      ),
      backgroundColor: context.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Html(
          data: postContent!,
          style: {
            "body": Style(
              fontSize: FontSize(16.0),
              color: context.icon,
            ),
            "p": Style(backgroundColor: context.scaffoldBackgroundColor),
          },
        ),
      ),
    );
  }
}
