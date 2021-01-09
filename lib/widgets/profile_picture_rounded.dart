import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final double width;
  final double height;
  final String profilePicturePath;

  ProfilePicture({
    @required this.width,
    @required this.height,
    @required this.profilePicturePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(profilePicturePath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(
          color: Colors.white,
          width: 10.0,
        ),
      ),
    );
  }
}
