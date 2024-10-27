import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'constant/contants.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content,style: AppTextStyles.bodyTextStyle.copyWith(color: Colors.white),),
    ),
  );
}


void showCustomFlushBar({
  required BuildContext context,
  required String title,
  required String message,
  Duration duration = const Duration(seconds: 3),
  Color backgroundColor = Colors.green,
  IconData icon = Icons.check_circle,
  Color iconColor = Colors.white,
}) {
  Flushbar(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    padding: EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(16),
    backgroundColor: backgroundColor,
    duration: duration,
    boxShadows: [
      BoxShadow(
        color: Colors.black26,
        offset: Offset(0, 4),
        blurRadius: 10,
      ),
    ],
    flushbarPosition: FlushbarPosition.BOTTOM,
    flushbarStyle: FlushbarStyle.FLOATING,
    icon: Icon(
      icon,
      size: 28.0,
      color: iconColor,
    ),
    titleText: Text(
      title,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    messageText: Text(
      message,
      style: TextStyle(
        fontSize: 16.0,
        color: Colors.white70,
      ),
    ),
  )..show(context);
}

