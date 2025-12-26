import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:handyman_provider_flutter/components/app_widgets.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/empty_error_state_widget.dart';
import '../../components/cached_image_widget.dart';
import '../../components/selected_item_widget.dart';
import '../../models/service_model.dart';
import '../../networks/rest_apis.dart';
import '../../utils/constant.dart';
import '../../utils/demo_data.dart';
import '../../utils/demo_mode.dart';

class FilterServiceListComponent extends StatefulWidget {
  @override
  State<FilterServiceListComponent> createState() =>
      _FilterServiceListComponentState();
}

class _FilterServiceListComponentState
    extends State<FilterServiceListComponent> {
  Future<List<ServiceData>>? future;

  List<ServiceData> servicesList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    // Demo Mode: Use demo service data
    if (DEMO_MODE_ENABLED) {
      servicesList = List<ServiceData>.from(demoServices);

      // Restore selection state from filterStore
      for (var service in servicesList) {
        service.isSelected = filterStore.serviceId.contains(service.id);
      }

      future = Future.value(servicesList);
      isLastPage = true;
      setState(() {});
      return;
    }

    future = getSearchList(
      status: SERVICE_APPROVE,
      page,
      providerId: appStore.userType == USER_TYPE_HANDYMAN
          ? appStore.providerId
          : appStore.userId,
      services: servicesList,
      lastPageCallback: (b) {
        isLastPage = b;
      },
    ).then((list) {
      servicesList = list.validate();
      servicesList.forEach((element) {
        if (filterStore.serviceId.contains(element.id)) {
          element.isSelected = true;
        }
      });
      return servicesList;
    });
  }

  void setPageToOne() {
    page = 1;
    appStore.setLoading(true);

    init();
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SnapHelperWidget<List<ServiceData>>(
          initialData: cachedServiceData,
          future: future,
          loadingWidget: LoaderWidget(),
          errorBuilder: (error) {
            return NoDataWidget(
              title: error,
              imageWidget: const ErrorStateWidget(),
              retryText: languages.reload,
              onRetry: () {
                setPageToOne();
              },
            );
          },
          onSuccess: (list) {
            return AnimatedListView(
              slideConfiguration: sliderConfigurationGlobal,
              itemCount: list.length,
              listAnimationType: ListAnimationType.FadeIn,
              fadeInConfiguration: FadeInConfiguration(duration: 2.seconds),
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 16, bottom: 80),
              emptyWidget: NoDataWidget(
                title: languages.noServiceFound,
                subTitle: languages.noServiceSubTitle,
                imageWidget: const EmptyStateWidget(),
              ),
              onSwipeRefresh: () async {
                page = 1;

                init();
                setState(() {});

                return await 2.seconds.delay;
              },
              onNextPage: () {
                if (!isLastPage) {
                  page++;
                  init();
                  setState(() {});
                }
              },
              itemBuilder: (context, index) {
                ServiceData data = list[index];

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(),
                    backgroundColor: context.secondaryContainer,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: data.imageAttachments != null &&
                                  data.imageAttachments!.isNotEmpty
                              ? CachedImageWidget(
                                  url: data.imageAttachments!.first.validate(),
                                  fit: BoxFit.cover,
                                  width: 50,
                                  height: 50,
                                  usePlaceholderIfUrlEmpty: true,
                                )
                              : Container(
                                  color: context.primary.withValues(alpha: 0.1),
                                  child: Icon(
                                    Icons.home_repair_service_outlined,
                                    size: 20,
                                    color: context.primary,
                                  ),
                                ),
                        ),
                      ),
                      16.width,
                      Text(data.name.validate(), style: context.boldTextStyle())
                          .expand(),
                      4.width,
                      SelectedItemWidget(
                          isSelected: data.isSelected.validate()),
                    ],
                  ),
                ).onTap(() {
                  if (data.isSelected.validate()) {
                    data.isSelected = false;
                  } else {
                    data.isSelected = true;
                  }

                  filterStore.serviceId = [];

                  servicesList.forEach((element) {
                    if (element.isSelected.validate()) {
                      filterStore.addToServiceList(
                          serId: element.id.validate());
                    }
                  });

                  setState(() {});
                },
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent);
              },
            );
          },
        ),
        Observer(
            builder: (_) =>
                LoaderWidget().visible(appStore.isLoading && page != 1)),
      ],
    );
  }
}
