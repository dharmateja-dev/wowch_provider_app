import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

const ARTICLE_LINE_HEIGHT = 1.5;

class HTMLFormatComponent extends StatelessWidget {
  final String? postContent;
  final Color? color;
  final double fontSize;

  HTMLFormatComponent({this.postContent, this.color, this.fontSize = 14.0});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: postContent.validate(),
      onAnchorTap: (s, _, __) {
        //
      },
      /*onImageTap: (s, _, __, ___) {
        ImageScreen(imageURl: s.validate());
      },*/
      style: {
        "table": Style(
            backgroundColor: color ?? context.onPrimary,
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        "tr": Style(
            border: Border(bottom: BorderSide(color: context.onPrimary)),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        "th": Style(
            padding: HtmlPaddings.zero,
            backgroundColor: context.onPrimary,
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT)),
        "td": Style(
            padding: HtmlPaddings.zero,
            alignment: Alignment.center,
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT)),
        'embed': Style(
            color: color ?? transparentColor,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'strong': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'a': Style(
          color: color ?? context.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: FontSize(fontSize),
          lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
          padding: HtmlPaddings.zero,
          textDecoration: TextDecoration.none,
        ),
        'div': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'figure': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            padding: HtmlPaddings.zero,
            margin: Margins.zero,
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT)),
        'h1': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'h2': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'h3': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'h4': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'h5': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'h6': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'p': Style(
          color: context.onPrimary,
          fontSize: FontSize(16),
          textAlign: TextAlign.justify,
          lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
          padding: HtmlPaddings.zero,
        ),
        'ol': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'ul': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'strike': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'u': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'b': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'i': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'hr': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'header': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'code': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'data': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'body': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'big': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'blockquote': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            lineHeight: const LineHeight(ARTICLE_LINE_HEIGHT),
            padding: HtmlPaddings.zero),
        'audio': Style(
            color: context.onPrimary,
            fontSize: FontSize(fontSize),
            padding: HtmlPaddings.zero),
        'img': Style(
            width: Width(context.width()),
            padding: HtmlPaddings.only(bottom: 8),
            fontSize: FontSize(fontSize)),
        'li': Style(
          color: context.onPrimary,
          fontSize: FontSize(fontSize),
          listStyleType: ListStyleType.disc,
          listStylePosition: ListStylePosition.outside,
        ),
      },
    );
  }
}
