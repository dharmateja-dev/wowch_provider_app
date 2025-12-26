import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

class BackWidget extends StatelessWidget {
  final Color? color;
  final VoidCallback? onPressed;
  final double? iconSize;
  final Color? iconColor;

  BackWidget({this.color, this.onPressed, this.iconSize, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed?.call();
        } else {
          pop();
        }
      },
      alignment: Alignment.center,
      icon: Icon(Icons.arrow_back_ios,
          color: iconColor ?? context.onPrimary, size: iconSize ?? 20),
    );
  }
}
