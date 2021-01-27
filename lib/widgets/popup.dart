import 'package:flutter/material.dart';

class Popup {
  static void show(BuildContext context, Widget view) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          var screenSize = MediaQuery.of(context).size;
          return Padding(
            padding: EdgeInsets.only(
              top: 0.12 * screenSize.height,
              bottom: 0.02 * screenSize.height,
              left: 0.02 * screenSize.width,
              right: 0.02 * screenSize.width,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32.0),
              child: Material(
                color: Colors.grey[100],
                child: view,
              ),
            ),
          );
        });
  }
}
