import 'package:flutter/material.dart';

class SearchPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.search,
          size: 0.10 * screenSize.width,
          color: Colors.grey[200],
        ),
        Text(
          'Type to start searching',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 0.06 * screenSize.width,
          ),
        ),
      ],
    );
  }
}
