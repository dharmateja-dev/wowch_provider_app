import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';

class SelectedItemWidget extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onChanged;

  const SelectedItemWidget({
    super.key,
    required this.isSelected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: 20,
      child: Checkbox(
        value: isSelected,
        onChanged: onChanged != null ? (_) => onChanged!() : null,
        activeColor: context.primary,
        checkColor: context.onPrimary,
        side: BorderSide(color: context.primary, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      ),
    );
  }
}
