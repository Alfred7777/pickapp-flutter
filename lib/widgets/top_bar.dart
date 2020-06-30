import 'package:flutter/material.dart';

AppBar topBar(BuildContext context) {
  return AppBar(
      backgroundColor: Colors.green,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ));
}
