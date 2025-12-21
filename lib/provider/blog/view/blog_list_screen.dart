import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/components/back_widget.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/attachment_model.dart';
import 'package:handyman_provider_flutter/provider/blog/blog_repository.dart';
import 'package:handyman_provider_flutter/provider/blog/component/blog_item_component.dart';
import 'package:handyman_provider_flutter/provider/blog/model/blog_response_model.dart';
import 'package:handyman_provider_flutter/provider/blog/shimmer/blog_shimmer.dart';
import 'package:handyman_provider_flutter/provider/blog/view/add_blog_screen.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/empty_error_state_widget.dart';

/// Demo blog data for UI testing
List<BlogData> get demoBlogList => [
      BlogData(
        id: 1,
        title: 'Top 10 Home Maintenance Tips for Winter',
        description: '''
<p>Winter is coming, and it's time to prepare your home for the cold months ahead. Here are our top 10 tips to keep your home warm and safe:</p>

<h3>1. Check Your Heating System</h3>
<p>Before the cold sets in, have your heating system inspected by a professional. This ensures efficient operation and prevents unexpected breakdowns.</p>

<h3>2. Insulate Pipes</h3>
<p>Frozen pipes can burst and cause significant water damage. Insulate pipes in unheated areas like basements, attics, and garages.</p>

<h3>3. Clean Gutters</h3>
<p>Remove leaves and debris from gutters to prevent ice dams that can damage your roof and cause leaks.</p>

<h3>4. Seal Windows and Doors</h3>
<p>Check for drafts around windows and doors. Apply weatherstripping or caulk to seal gaps and improve energy efficiency.</p>

<h3>5. Test Smoke and Carbon Monoxide Detectors</h3>
<p>With increased use of heating systems, the risk of fire and carbon monoxide poisoning increases. Test all detectors and replace batteries.</p>

<p>Stay warm and safe this winter!</p>
''',
        isFeatured: 1,
        totalViews: 1250,
        authorId: 1,
        authorName: 'Admin',
        status: 1,
        publishDate:
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        imageAttachments: [
          'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800'
        ],
        attachment: [
          Attachments(
              id: 1,
              url:
                  'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=800',
              name: 'home_maintenance.jpg'),
        ],
      ),
      BlogData(
        id: 2,
        title: 'How to Choose the Right Plumber for Your Home',
        description: '''
<p>Finding a reliable plumber can be challenging. Here's what you need to know to make the right choice:</p>

<h3>Check Credentials</h3>
<p>Always verify that the plumber is licensed and insured. This protects you from liability in case of accidents.</p>

<h3>Read Reviews</h3>
<p>Look for online reviews and ask for references. A good plumber will have satisfied customers willing to vouch for their work.</p>

<h3>Get Multiple Quotes</h3>
<p>Don't settle for the first quote. Get at least three estimates to ensure you're getting a fair price.</p>

<h3>Ask About Warranties</h3>
<p>A reputable plumber will offer warranties on both parts and labor. This gives you peace of mind.</p>
''',
        isFeatured: 0,
        totalViews: 890,
        authorId: 1,
        authorName: 'Service Expert',
        status: 1,
        publishDate:
            DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
        imageAttachments: [
          'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800'
        ],
        attachment: [
          Attachments(
              id: 2,
              url:
                  'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800',
              name: 'plumber.jpg'),
        ],
      ),
      BlogData(
        id: 3,
        title: 'DIY vs Professional: When to Call an Expert',
        description: '''
<p>Many homeowners wonder whether to tackle repairs themselves or hire a professional. Here's a guide to help you decide:</p>

<h3>DIY Projects</h3>
<ul>
<li>Painting walls</li>
<li>Minor fixture replacements</li>
<li>Simple landscaping</li>
<li>Basic cleaning and maintenance</li>
</ul>

<h3>Call a Professional For</h3>
<ul>
<li>Electrical work</li>
<li>Plumbing issues</li>
<li>Structural repairs</li>
<li>HVAC maintenance</li>
<li>Roof repairs</li>
</ul>

<p>When in doubt, it's always safer to consult a professional!</p>
''',
        isFeatured: 1,
        totalViews: 2100,
        authorId: 2,
        authorName: 'Home Advisor',
        status: 1,
        publishDate:
            DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
        imageAttachments: [
          'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800'
        ],
        attachment: [
          Attachments(
              id: 3,
              url:
                  'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
              name: 'diy_expert.jpg'),
        ],
      ),
    ];

class BlogListScreen extends StatefulWidget {
  const BlogListScreen({Key? key}) : super(key: key);

  @override
  State<BlogListScreen> createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  Future<List<BlogData>>? future;

  List<BlogData> blogList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    if (DEMO_MODE_ENABLED) {
      // Use demo data in demo mode
      future = Future.value(demoBlogList);
    } else {
      future = getBlogListAPI(
        blogData: blogList,
        page: page,
        lastPageCallback: (b) {
          isLastPage = b;
        },
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: appBarWidget(
        languages.blogs,
        color: context.primary,
        textColor: context.onPrimary,
        backWidget: BackWidget(
          color: context.onPrimary,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, size: 28, color: context.onPrimary),
            tooltip: languages.addBlog,
            onPressed: () async {
              bool? res;

              res = await AddBlogScreen()
                  .launch(context, pageRouteAnimation: PageRouteAnimation.Fade);

              if (res ?? false) {
                appStore.setLoading(true);
                page = 1;
                init();
                setState(() {});
              }
            },
          ).visible(appStore.isLoggedIn && rolesAndPermissionStore.blogAdd),
        ],
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<BlogData>>(
            future: future,
            loadingWidget: BlogShimmer(),
            onSuccess: (list) {
              return AnimatedListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                shrinkWrap: true,
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                itemCount: list.length,
                emptyWidget: NoDataWidget(
                  title: languages.noBlogsFound,
                  imageWidget: const EmptyStateWidget(),
                ),
                onNextPage: () {
                  if (!isLastPage) {
                    page++;
                    appStore.setLoading(true);

                    init();
                    setState(() {});
                  }
                },
                disposeScrollController: false,
                itemBuilder: (BuildContext context, index) {
                  BlogData data = list[index];

                  return BlogItemComponent(
                    blogData: data,
                    callBack: () {
                      page = 1;
                      init();
                      setState(() {});
                    },
                  );
                },
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: const ErrorStateWidget(),
                retryText: languages.reload,
                onRetry: () {
                  page = 1;
                  appStore.setLoading(true);

                  init();
                  setState(() {});
                },
              );
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading))
        ],
      ),
    );
  }
}
