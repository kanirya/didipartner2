import 'package:flutter/material.dart';

import '../../utils/constant/contants.dart';

class LinearIndicator extends StatefulWidget {
  const LinearIndicator({super.key});

  @override
  State<LinearIndicator> createState() => _LinearIndicatorState();
}

class _LinearIndicatorState extends State<LinearIndicator> {
  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      color: AppColors.darkGray,
      borderRadius: BorderRadius.circular(3),
      backgroundColor: AppColors.lightGreen,
    );
  }
}
