import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:handyman_provider_flutter/utils/text_styles.dart';
import 'package:nb_utils/nb_utils.dart';

/// Custom Language List Widget with theme-aware checkboxes
class CustomLanguageListWidget extends StatefulWidget {
  final ScrollPhysics? scrollPhysics;
  final void Function(LanguageDataModel)? onLanguageChange;

  const CustomLanguageListWidget({
    this.onLanguageChange,
    this.scrollPhysics,
    super.key,
  });

  @override
  CustomLanguageListWidgetState createState() =>
      CustomLanguageListWidgetState();
}

class CustomLanguageListWidgetState extends State<CustomLanguageListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: localeLanguageList.length,
      shrinkWrap: true,
      physics: widget.scrollPhysics,
      padding: EdgeInsets.symmetric(horizontal: 16),
      separatorBuilder: (_, __) => 20.height,
      itemBuilder: (_, index) {
        LanguageDataModel data = localeLanguageList[index];
        bool isSelected = getStringAsync(SELECTED_LANGUAGE_CODE) ==
            data.languageCode.validate();

        return Row(
          children: [
            // Flag image
            if (data.flag != null) ...[
              _buildImageWidget(data.flag!),
              12.width,
            ],
            // Language name and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name.validate(),
                    style: context.boldTextStyle(size: 14),
                  ),
                  if (data.subTitle != null && data.subTitle!.isNotEmpty) ...[
                    4.height,
                    Text(
                      data.subTitle!,
                      style: context.secondaryTextStyle(size: 12),
                    ),
                  ],
                ],
              ),
            ),
            // Checkbox
            Checkbox(
              value: isSelected,
              onChanged: (_) => _onLanguageSelected(data),
              activeColor: context.primary,
              checkColor: context.onPrimary,
              side: BorderSide(color: context.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
          ],
        ).onTap(() => _onLanguageSelected(data), borderRadius: radius(8));
      },
    );
  }

  Widget _buildImageWidget(String imagePath) {
    if (imagePath.startsWith('http')) {
      return ClipRRect(
        borderRadius: radius(4),
        child:
            Image.network(imagePath, width: 28, height: 20, fit: BoxFit.cover),
      );
    } else {
      return ClipRRect(
        borderRadius: radius(4),
        child: Image.asset(imagePath, width: 28, height: 20, fit: BoxFit.cover),
      );
    }
  }

  Future<void> _onLanguageSelected(LanguageDataModel data) async {
    await setValue(SELECTED_LANGUAGE_CODE, data.languageCode);
    selectedLanguageDataModel = data;
    setState(() {});
    widget.onLanguageChange?.call(data);
  }
}
