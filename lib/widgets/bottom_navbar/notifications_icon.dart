import 'package:flutter/material.dart';

class NotificationsIcon extends StatelessWidget {
  final int notificationsCount;

  NotificationsIcon({@required this.notificationsCount});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: notificationsCount == 0
          ? _buildIconWithoutLabel()
          : _buildIconWithLabel(notificationsCount),
    );
  }

  List<Widget> _buildIconWithoutLabel() {
    return [Icon(Icons.notifications)];
  }

  List<Widget> _buildIconWithLabel(int notificationsCount) {
    return [
      Icon(Icons.notifications),
      Positioned(
        right: 0,
        child: Container(
          padding: EdgeInsets.all(1),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(6),
          ),
          constraints: BoxConstraints(
            minWidth: 12,
            minHeight: 12,
          ),
          child: Text(
            notificationsCount.toString(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ];
  }
}
