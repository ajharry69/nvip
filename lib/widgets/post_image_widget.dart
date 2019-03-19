import 'package:flutter/material.dart';

class CustomFadeInImageView extends StatefulWidget {
  final String imageUrl;

  const CustomFadeInImageView({Key key, this.imageUrl}) : super(key: key);

  @override
  _CustomFadeInImageViewState createState() =>
      _CustomFadeInImageViewState(imageUrl);
}

class _CustomFadeInImageViewState extends State<CustomFadeInImageView> {
  final String imageUrl;
  final defaultImage = "images/no_image.png";
  final imageHeight = 194.0;

  _CustomFadeInImageViewState(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return imageUrl != null && imageUrl != ""
        ? FadeInImage.assetNetwork(
            placeholder: defaultImage,
            image: imageUrl,
            width: double.maxFinite,
            height: imageHeight,
            fit: BoxFit.fill,
          )
        : Image.asset(
            defaultImage,
            width: double.maxFinite,
            height: imageHeight,
            fit: BoxFit.fill,
          );
  }
}
