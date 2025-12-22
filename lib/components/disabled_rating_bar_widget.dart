import 'package:flutter/material.dart';
import 'package:handyman_provider_flutter/utils/context_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

class DisabledRatingBarWidget extends StatelessWidget {
  final num rating;
  final double? size;

  const DisabledRatingBarWidget({required this.rating, this.size});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RatingBarWidget(
          onRatingChanged: null,
          itemCount: 5,
          size: size ?? 18,
          disable: true,
          activeColor: context.starColor,
          inActiveColor: context.textGrey,
          rating: rating.validate().toDouble(),
        ),
      ],
    );
  }
}
