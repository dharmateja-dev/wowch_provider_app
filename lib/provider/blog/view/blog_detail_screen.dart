import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:handyman_provider_flutter/provider/blog/blog_repository.dart';
import 'package:handyman_provider_flutter/provider/blog/model/blog_detail_response.dart';
import 'package:handyman_provider_flutter/provider/blog/model/blog_response_model.dart';
import 'package:handyman_provider_flutter/provider/blog/view/add_blog_screen.dart';
import 'package:handyman_provider_flutter/provider/blog/view/blog_list_screen.dart';
import 'package:handyman_provider_flutter/utils/common.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:handyman_provider_flutter/utils/model_keys.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/back_widget.dart';
import '../../../components/cached_image_widget.dart';
import '../../../components/empty_error_state_widget.dart';
import '../../../main.dart';
import '../../services/shimmer/service_detail_shimmer.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  BlogDetailScreen({required this.blogId});

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  Future<BlogDetailResponse>? future;
  BlogData? currentBlog;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (DEMO_MODE_ENABLED) {
      // Find demo blog by ID
      final demoBlog = demoBlogList.firstWhere(
        (blog) => blog.id == widget.blogId,
        orElse: () => demoBlogList.first,
      );
      currentBlog = demoBlog;
      future = Future.value(BlogDetailResponse(blogDetail: demoBlog));
    } else {
      future = getBlogDetailAPI({AddBlogKey.blogId: widget.blogId.validate()});
      future?.then((response) {
        currentBlog = response.blogDetail;
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.primary,
        leading: BackWidget(color: context.onPrimary),
        title: Text(
          languages.blogs,
          style: context.boldTextStyle(color: context.onPrimary, size: 18),
        ),
        centerTitle: true,
        actions: [
          if (appStore.isLoggedIn && rolesAndPermissionStore.blogEdit)
            IconButton(
              icon: Icon(Icons.edit, color: context.onPrimary),
              tooltip: languages.lblEdit,
              onPressed: () {
                ifNotTester(context, () async {
                  if (currentBlog != null) {
                    bool? res = await AddBlogScreen(data: currentBlog).launch(
                        context,
                        pageRouteAnimation: PageRouteAnimation.Fade);
                    if (res ?? false) {
                      init(); // Refresh the blog details
                    }
                  }
                });
              },
            ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: context.primary,
        ),
      ),
      body: FutureBuilder<BlogDetailResponse>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ServiceDetailShimmer();
          }

          if (snap.hasError) {
            return NoDataWidget(
              title: snap.error.toString(),
              imageWidget: const ErrorStateWidget(),
              retryText: languages.reload,
              onRetry: () {
                init();
              },
            );
          }

          if (!snap.hasData || snap.data?.blogDetail == null) {
            return NoDataWidget(
              title: languages.noDataFound,
              imageWidget: const EmptyStateWidget(),
            );
          }

          final blog = snap.data!.blogDetail!;

          return AnimatedScrollView(
            listAnimationType: ListAnimationType.FadeIn,
            fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Image
              if (blog.attachment.validate().isNotEmpty)
                CachedImageWidget(
                  url: blog.attachment!.first.url.validate(),
                  height: 250,
                  width: context.width(),
                  fit: BoxFit.cover,
                )
              else if (blog.imageAttachments.validate().isNotEmpty)
                CachedImageWidget(
                  url: blog.imageAttachments!.first.validate(),
                  height: 250,
                  width: context.width(),
                  fit: BoxFit.cover,
                ),

              // Content Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardSecondary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,

                    // Blog Title
                    Text(
                      blog.title.validate(),
                      style: context.boldTextStyle(size: 22),
                    ),

                    20.height,

                    // Author Section
                    Row(
                      children: [
                        // Author Avatar
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.primary.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: CachedImageWidget(
                            url: blog.authorImage.validate(),
                            height: 40,
                            width: 40,
                            circle: true,
                            fit: BoxFit.cover,
                          ),
                        ),
                        12.width,

                        // Author Name & Date
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              blog.authorName.validate().isNotEmpty
                                  ? blog.authorName.validate()
                                  : 'Anonymous',
                              style: context.boldTextStyle(
                                size: 14,
                                color: context.primary,
                              ),
                            ),
                            4.height,
                            if (blog.publishDate.validate().isNotEmpty)
                              Text(
                                formatBookingDate(blog.publishDate.validate(),
                                    format: 'MMMM d, yyyy'),
                                style: context.secondaryTextStyle(
                                  size: 12,
                                  color: context.textGrey,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    24.height,

                    // Blog Content
                    Html(
                      data: blog.description.validate(),
                      style: {
                        "body": Style(
                          fontSize: FontSize(14),
                          lineHeight: const LineHeight(1.6),
                          color: context.onSurface,
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                        ),
                        "p": Style(
                          fontSize: FontSize(14),
                          lineHeight: const LineHeight(1.6),
                          color: context.onSurface,
                          margin: Margins.only(bottom: 12),
                        ),
                        "h1": Style(
                          fontSize: FontSize(20),
                          fontWeight: FontWeight.bold,
                          color: context.onSurface,
                          margin: Margins.only(top: 16, bottom: 8),
                        ),
                        "h2": Style(
                          fontSize: FontSize(18),
                          fontWeight: FontWeight.bold,
                          color: context.onSurface,
                          margin: Margins.only(top: 14, bottom: 6),
                        ),
                        "h3": Style(
                          fontSize: FontSize(16),
                          fontWeight: FontWeight.bold,
                          color: context.onSurface,
                          margin: Margins.only(top: 12, bottom: 4),
                        ),
                        "ul": Style(
                          margin: Margins.only(left: 16, bottom: 12),
                        ),
                        "li": Style(
                          fontSize: FontSize(14),
                          lineHeight: const LineHeight(1.6),
                          color: context.onSurface,
                          margin: Margins.only(bottom: 4),
                        ),
                        "span": Style(
                          color: context.onSurface,
                        ),
                      },
                    ),

                    32.height,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
