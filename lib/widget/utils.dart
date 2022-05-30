import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  static Future<File> getImageFromGallery() async {

    File _image;
    XFile? pickedFile = (await ImagePicker().pickImage(source: ImageSource.gallery,preferredCameraDevice: CameraDevice.rear,imageQuality: 10)) ;
    _image = File(pickedFile!.path);
    print('_image:: $_image');
    return _image;
  }
  static Future<File> getImageFromCamera() async {
    File _image;
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.camera,imageQuality: 10);
    _image = File(pickedFile!.path);

    return _image;
  }

}