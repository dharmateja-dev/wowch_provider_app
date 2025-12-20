import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart'
    show TextStyleExtension;
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/constant.dart';
import 'app_widgets.dart';
import 'back_widget.dart';

class AppScaffold extends StatelessWidget {
  final String? appBarTitle;
  final List<Widget>? actions;

  final Widget body;
  final Color? scaffoldBackgroundColor;
  final Widget? bottomNavigationBar;
  final bool showLoader;
  final Observable<bool>? isLoading;

  const AppScaffold({
    this.appBarTitle,
    required this.body,
    this.actions,
    this.scaffoldBackgroundColor,
    this.bottomNavigationBar,
    this.showLoader = true,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final loading = showLoader && (isLoading?.value ?? false);
    return Scaffold(
      appBar: appBarTitle != null
          ? AppBar(
              title: Text(appBarTitle.validate(),
                  style: context.boldTextStyle(
                      color: context.onPrimary, size: APP_BAR_TEXT_SIZE)),
              elevation: 0.0,
              backgroundColor: context.primary,
              leading: context.canPop ? BackWidget() : null,
              actions: actions,
              centerTitle: true,
            )
          : null,
      backgroundColor: scaffoldBackgroundColor ?? context.scaffold,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: loading,
            child: body,
          ),
          if (loading) LoaderWidget().center(),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
