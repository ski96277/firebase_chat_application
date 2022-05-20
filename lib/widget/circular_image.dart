import 'package:flutter/material.dart';

class CircularImage extends StatelessWidget {
  late String placeHolder;
  late String imageUrlLink;


  CircularImage({required this.placeHolder, required this.imageUrlLink});

  @override
  Widget build(BuildContext context) {
    return  CircleAvatar(
      radius: 40,
      backgroundColor: Colors.grey,
      child: ClipOval(
        child: FadeInImage.assetNetwork(
          placeholder: placeHolder,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(placeHolder,fit: BoxFit.cover,);
          },

          fit: BoxFit.cover,
          height: 100.0,
          image: imageUrlLink,
        ),
      ),
    );
  }
}
