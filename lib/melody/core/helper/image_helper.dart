import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ImageHelper {
  static Widget loadFromAsset(
    String imageFilePath, {
    double? width,
    double? height,
    BorderRadius? radius,
    BoxFit? fit,
    Color? tintColor,
    Alignment? alignment,
  }) {
    if (imageFilePath.toLowerCase().endsWith('svg')) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: SvgPicture.asset(
          imageFilePath,
          width: width,
          height: height,
          fit: fit ?? BoxFit.contain,
          color: tintColor,
          alignment: alignment ?? Alignment.center,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: Image.asset(
          imageFilePath,
          width: width,
          height: height,
          fit: fit ?? BoxFit.contain,
          color: tintColor,
          alignment: alignment ?? Alignment.center,
        ),
      );
    }
  }

  static Widget loadFromNetwork(String imageFilePath,
      {double? width,
      double? height,
      BorderRadius? radius,
      BoxFit? fit,
      Color? tintColor,
      Alignment? alignment,
      double? scale}) {
    if (imageFilePath.toLowerCase().endsWith('svg')) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: SvgPicture.asset(
          imageFilePath,
          width: width,
          height: height,
          fit: fit ?? BoxFit.contain,
          color: tintColor,
          alignment: alignment ?? Alignment.center,
        ),
      );
    } else {
      return ClipRRect(
          borderRadius: radius ?? BorderRadius.zero,
          child: CachedNetworkImage(
            imageUrl: imageFilePath,
            width: width,
            height: height,
            fit: fit ?? BoxFit.contain,
            color: tintColor,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(value: downloadProgress.progress)),
                ),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ));
    }
  }
}
