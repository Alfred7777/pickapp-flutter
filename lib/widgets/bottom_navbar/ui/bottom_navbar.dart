import 'package:flutter/material.dart';

import '../bottom_navbar_bloc.dart';
import '../bottom_navbar_event.dart';
import 'notifications_icon.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final int currentNotificationsCount;
  final BottomNavbarBloc bloc;

  BottomNavbar({
    @required this.currentIndex,
    this.currentNotificationsCount,
    @required this.bloc,
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
      onTap: (index) {
        bloc.add(
          IndexChanged(
            index: index,
            currentUnreadNotificationsCount: currentNotificationsCount,
          ),
        );
      },
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
