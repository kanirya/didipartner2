
import 'package:flutter/material.dart';

import '../../utils/constant/contants.dart';

class CustomLoadingIndicator extends StatelessWidget {
  // Customizable properties
  final Color color;
  final double height;
  final double width;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double opacity;

  // Constructor with optional customization
  const CustomLoadingIndicator({
    Key? key,
    this.color = AppColors.darkGray,
    this.height = 3.0,
    this.width = double.infinity,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    this.borderRadius = 8.0,
    this.opacity=.4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: LinearProgressIndicator(
          color: color.withOpacity(opacity),
          backgroundColor: color.withOpacity(0.2), // A lighter background shade
        ),
      ),
    );
  }
}



class LoadingContainer extends StatelessWidget {
  const LoadingContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(

      title: CustomLoadingIndicator(
        height: 10,
        padding: EdgeInsets.only(right: 120,left: 20),
      ),
      subtitle:  Column(
        children: [
          const SizedBox(height: 20,),
          CustomLoadingIndicator(
            height: 10,
            padding: EdgeInsets.only(right: 30,left: 20),
          ),
          const SizedBox(height: 12,),
          CustomLoadingIndicator(
            height: 10,
            padding: EdgeInsets.only(right: 160,left: 20),
          ),
          const SizedBox(height: 10,),
          Divider()
        ],
      ),

    );
  }
}
