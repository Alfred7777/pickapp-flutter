import 'package:flutter/material.dart';

AppBar topBar(BuildContext context) {
  return AppBar(
      backgroundColor: Color.fromRGBO(30, 152, 43, 100),
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
