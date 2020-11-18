import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String text;
  final double fontSize;
  const Header({this.text, this.fontSize});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
      height: 0.08 * screenSize.height,
      width: screenSize.width,
      child: Padding(
        padding: EdgeInsets.only(
          left: 0.04 * screenSize.width,
          top: 0.014 * screenSize.height,
          bottom: 0.018 * screenSize.height,
        ),
        child: Text(
          '${text}',
          style: TextStyle(
            color: Color(0xFF3D3A3A),
            fontSize: fontSize * screenSize.height,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
