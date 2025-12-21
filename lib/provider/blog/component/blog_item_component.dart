import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/components/cached_image_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/provider/blog/blog_repository.dart';
import 'package:handyman_provider_flutter/provider/blog/model/blog_response_model.dart';
import 'package:handyman_provider_flutter/provider/blog/view/blog_detail_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

class BlogItemComponent extends StatefulWidget {
  final BlogData? blogData;
  final VoidCallback? callBack;

  BlogItemComponent({this.blogData, this.callBack});

  @override
  State<BlogItemComponent> createState() => _BlogItemComponentState();
}

class _BlogItemComponentState extends State<BlogItemComponent> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Future<void> deleteBlog(int? id) async {
    appStore.setLoading(true);

    await deleteBlogAPI(id).then((value) {
      appStore.setLoading(false);

      widget.callBack?.call();
      toast(value.message);

      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: boxDecorationWithRoundedCorners(
        borderRadius: radius(12),
        backgroundColor: context.cardSecondary,
        border: Border.all(color: context.cardSecondaryBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blog Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedImageWidget(
              url: widget.blogData!.imageAttachments.validate().isNotEmpty
                  ? widget.blogData!.imageAttachments!.first.validate()
                  : '',
              fit: BoxFit.cover,
              height: 80,
              width: 80,
            ),
          ),
          12.width,

          // Blog Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title
                Text(
                  widget.blogData!.title.validate(),
                  style: context.boldTextStyle(size: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                6.height,

                // Description
                Text(
                  parseHtmlString(widget.blogData!.description.validate()),
                  style: context.secondaryTextStyle(
                    size: 12,
                    color: context.textGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).onTap(
      () {
        BlogDetailScreen(blogId: widget.blogData!.id.validate())
            .launch(context);
      },
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
