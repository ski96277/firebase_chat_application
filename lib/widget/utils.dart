import 'package:flutter/material.dart';

class AppUtils{
  ///show snack bar
  static void showSnakeBar({
    required BuildContext context,
    String title = "",
    required String msg,
    backgroundColors = Colors.white,
    Color textColors = Colors.black,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        msg,
        style: TextStyle(color: textColors),
      ),
      backgroundColor: backgroundColors,
    ));
  }
}