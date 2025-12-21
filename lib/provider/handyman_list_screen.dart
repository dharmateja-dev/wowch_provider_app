import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/handyman_add_update_screen.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/models/user_data.dart';
import 'package:handyman_provider_flutter/networks/rest_apis.dart';
import 'package:handyman_provider_flutter/provider/components/handyman_widget.dart';
import 'package:handyman_provider_flutter/provider/shimmer/handyman_list_shimmer.dart';
import 'package:handyman_provider_flutter/utils/colors.dart';
import 'package:handyman_provider_flutter/utils/constant.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/demo_mode.dart';
import 'package:nb_utils/nb_utils.dart';

import '../components/app_widgets.dart';
import '../components/empty_error_state_widget.dart';

/// Demo handyman data for UI testing
List<UserData> get demoHandymanList => [
      UserData(
        id: 1,
        firstName: 'Mike',
        lastName: 'Johnson',
        username: 'mike.johnson',
        displayName: 'Mike Johnson',
        email: 'mike.johnson@example.com',
        contactNumber: '1-234567890',
        profileImage:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        status: 1,
        isHandymanAvailable: true,
        designation: 'Senior Plumber',
        description:
            'Experienced plumber with over 10 years of expertise in residential and commercial plumbing.',
        handymanRating: 4.8,
        cityName: 'New York',
        address: '123 Main Street, New York, NY 10001',
        userType: USER_TYPE_HANDYMAN,
        createdAt: '2024-01-15T10:30:00.000Z',
      )..isActive = true,
      UserData(
        id: 2,
        firstName: 'David',
        lastName: 'Williams',
        username: 'david.williams',
        displayName: 'David Williams',
        email: 'david.williams@example.com',
        contactNumber: '1-234567891',
        profileImage:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
        status: 1,
        isHandymanAvailable: true,
        designation: 'Electrician',
        description:
            'Certified electrician specializing in home electrical repairs and installations.',
        handymanRating: 4.7,
        cityName: 'Los Angeles',
        address: '456 Oak Avenue, Los Angeles, CA 90001',
        userType: USER_TYPE_HANDYMAN,
        createdAt: '2024-02-20T14:45:00.000Z',
      )..isActive = true,
      UserData(
        id: 3,
        firstName: 'Robert',
        lastName: 'Brown',
        username: 'robert.brown',
        displayName: 'Robert Brown',
        email: 'robert.brown@example.com',
        contactNumber: '1-234567892',
        profileImage:
            'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
        status: 0,
        isHandymanAvailable: false,
        designation: 'HVAC Technician',
        description:
            'Expert in heating, ventilation, and air conditioning systems.',
        handymanRating: 4.5,
        cityName: 'Chicago',
        address: '789 Pine Road, Chicago, IL 60601',
        userType: USER_TYPE_HANDYMAN,
        createdAt: '2024-03-10T09:15:00.000Z',
      )..isActive = false,
      UserData(
        id: 4,
        firstName: 'James',
        lastName: 'Davis',
        username: 'james.davis',
        displayName: 'James Davis',
        email: 'james.davis@example.com',
        contactNumber: '1-234567893',
        profileImage:
            'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400',
        status: 1,
        isHandymanAvailable: true,
        designation: 'Carpenter',
        description:
            'Skilled carpenter offering custom furniture and woodworking services.',
        handymanRating: 4.9,
        cityName: 'Houston',
        address: '321 Elm Street, Houston, TX 77001',
        userType: USER_TYPE_HANDYMAN,
        createdAt: '2024-04-05T11:00:00.000Z',
      )..isActive = true,
      UserData(
        id: 5,
        firstName: 'Michael',
        lastName: 'Garcia',
        username: 'michael.garcia',
        displayName: 'Michael Garcia',
        email: 'michael.garcia@example.com',
        contactNumber: '1-234567894',
        profileImage:
            'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
        status: 1,
        isHandymanAvailable: true,
        designation: 'Painter',
        description:
            'Professional painter specializing in interior and exterior painting.',
        handymanRating: 4.6,
        cityName: 'Phoenix',
        address: '654 Maple Drive, Phoenix, AZ 85001',
        userType: USER_TYPE_HANDYMAN,
        createdAt: '2024-05-18T16:30:00.000Z',
      )..isActive = true,
      UserData(
        id: 6,
        firstName: 'William',
        lastName: 'Martinez',
        username: 'william.martinez',
        displayName: 'William Martinez',
        email: 'william.martinez@example.com',
        contactNumber: '1-234567895',
        profileImage:
            'https://images.unsplash.com/photo-1463453091185-61582044d556?w=400',
        status: 1,
        isHandymanAvailable: true,
        designation: 'General Handyman',
        description:
            'Versatile handyman capable of handling various home repair tasks.',
        handymanRating: 4.4,
        cityName: 'Philadelphia',
        address: '987 Cedar Lane, Philadelphia, PA 19101',
        userType: USER_TYPE_HANDYMAN,
        createdAt: '2024-06-25T08:45:00.000Z',
      )..isActive = true,
    ];

class HandymanListScreen extends StatefulWidget {
  @override
  HandymanListScreenState createState() => HandymanListScreenState();
}

class HandymanListScreenState extends State<HandymanListScreen> {
  Future<List<UserData>>? future;

  List<UserData> list = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init({bool isLoading = false, int page = 1}) async {
    if (DEMO_MODE_ENABLED) {
      // Use demo data
      list = demoHandymanList;
      future = Future.value(demoHandymanList);
      isLastPage = true;
    } else {
      future = getHandyman(
        page: page,
        providerId: appStore.userId.toString(),
        list: list,
        lastPageCallback: (b) {
          isLastPage = b;
        },
      );
    }

    if (isLoading) {
      appStore.setLoading(true);
    }
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldSecondary,
      appBar: appBarWidget(
        languages.lblAllHandyman,
        textColor: context.onPrimary,
        center: true,
        color: context.primary,
        actions: [
          IconButton(
            onPressed: () {
              HandymanAddUpdateScreen(
                userType: USER_TYPE_HANDYMAN,
                onUpdate: () {
                  init(isLoading: true);
                },
              ).launch(context);
            },
            icon: Icon(Icons.add, size: 28, color: context.onPrimary),
            tooltip: languages.lblAddHandyman,
          ).visible(rolesAndPermissionStore.handymanAdd),
        ],
      ),
      body: Stack(
        children: [
          SnapHelperWidget<List<UserData>>(
            future: future,
            loadingWidget: HandymanListShimmer(),
            onSuccess: (snap) {
              if (snap.isEmpty)
                return NoDataWidget(
                  title: languages.noHandymanYet,
                  imageWidget: const EmptyStateWidget(),
                );

              return AnimatedScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 60),
                listAnimationType: ListAnimationType.FadeIn,
                fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
                physics: const AlwaysScrollableScrollPhysics(),
                onNextPage: () {
                  if (!isLastPage) {
                    init(isLoading: true, page: page++);
                  }
                },
                onSwipeRefresh: () async {
                  page = 1;

                  init();
                  setState(() {});

                  return await 2.seconds.delay;
                },
                children: [
                  AnimatedWrap(
                    spacing: 16,
                    runSpacing: 16,
                    itemCount: list.length,
                    listAnimationType: ListAnimationType.FadeIn,
                    fadeInConfiguration:
                        FadeInConfiguration(duration: 2.seconds),
                    scaleConfiguration: ScaleConfiguration(
                        duration: 400.milliseconds, delay: 50.milliseconds),
                    itemBuilder: (context, index) {
                      return HandymanWidget(
                        data: list[index],
                        width: context.width() * 0.5 - 26,
                        onUpdate: () async {
                          init(isLoading: true);
                        },
                      );
                    },
                  ),
                ],
              );
            },
            errorBuilder: (error) {
              return NoDataWidget(
                title: error,
                imageWidget: const ErrorStateWidget(),
                retryText: languages.reload,
                onRetry: () {
                  init(isLoading: true);
                },
              );
            },
          ),
          Observer(
              builder: (context) => LoaderWidget().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
