import 'package:flutter/material.dart';
import 'notifications_icon.dart';

class BottomNavbar extends StatelessWidget {
  final Function onIndexChanged;
  final int currentIndex;
  final int currentNotificationsCount;

  BottomNavbar({
    @required this.onIndexChanged,
    @required this.currentIndex,
    this.currentNotificationsCount,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.black,
      showUnselectedLabels: true,
      selectedFontSize: 13,
      unselectedLabelStyle: TextStyle(
        fontSize: 13,
        color: Colors.black,
        decorationColor: Colors.black,
      ),
      onTap: (index) => onIndexChanged(index),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'My events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Groups',
        ),
        BottomNavigationBarItem(
          icon: NotificationsIcon(
            notificationsCount: currentNotificationsCount,
          ),
          label: 'Alerts',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
