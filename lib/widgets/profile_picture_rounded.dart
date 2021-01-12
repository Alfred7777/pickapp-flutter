import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final double width;
  final double height;
  final Border border;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final BoxShape shape;
  final String profilePictureUrl;

  ProfilePicture({
    this.width,
    this.height,
    this.border,
    this.borderRadius,
    this.fit,
    this.shape,
    profilePictureUrl,
  }) : profilePictureUrl = profilePictureUrl ?? '';

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        height: height,
        child: ProfilePictureImage(
          profilePictureUrl: profilePictureUrl,
          border: border,
          borderRadius: borderRadius,
          fit: fit,
          shape: shape,
        ));
  }
}

class ProfilePictureImage extends StatelessWidget {
  final String profilePictureUrl;
  final Border border;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final BoxShape shape;

  ProfilePictureImage({
    profilePictureUrl,
    this.border,
    this.borderRadius,
    this.fit,
    this.shape,
  }) : profilePictureUrl = profilePictureUrl ?? '';

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: profilePictureUrl,
      imageBuilder: (context, imageProvider) => ProfilePictureDecoration(
        imageProvider: imageProvider,
        borderRadius: borderRadius,
        border: border,
        fit: fit,
        shape: shape,
      ),
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          CircularProgressIndicator(
        value: downloadProgress.progress,
        strokeWidth: 1.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          Colors.grey[300].withOpacity(0.4),
        ),
      ),
      errorWidget: (context, url, error) => ProfilePictureDecoration(
        imageProvider: AssetImage(
          'assets/images/profile_placeholder.png',
        ),
        borderRadius: borderRadius,
        border: border,
        fit: fit,
        shape: shape,
      ),
    );
  }
}

class ProfilePictureDecoration extends StatelessWidget {
  final ImageProvider<Object> imageProvider;
  final Border border;
  final BorderRadius borderRadius;
  final BoxFit fit;
  final BoxShape shape;

  ProfilePictureDecoration({
    @required this.imageProvider,
    this.border,
    this.borderRadius,
    this.fit,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: shape,
        image: DecorationImage(
          image: imageProvider,
          fit: fit,
        ),
        borderRadius: borderRadius,
        border: border,
      ),
    );
  }
}
