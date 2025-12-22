import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/main.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/flutter_image_stack.dart';
import '../../utils/constant.dart';

class HandymanRecentlyOnlineComponent extends StatelessWidget {
  final List<String> images;

  const HandymanRecentlyOnlineComponent({Key? key, required this.images})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox();

    final validImages = images
        .where((element) => element.validate().startsWith('http'))
        .toList();

    if (validImages.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(languages.lblRecentlyOnlineHandyman,
              style: context.boldTextStyle(size: LABEL_TEXT_SIZE)),
          8.height,
          FlutterImageStack(
            imageList: validImages,
            totalCount: validImages.length,
            showTotalCount: false,
            itemRadius: 40,
            itemBorderWidth: 2,
            itemBorderColor: context.primary,
          ),
        ],
      ),
    );
  }
}
