import 'package:flutter/material.dart';

BottomNavigationBar bottomNavbar(int index) {
  return BottomNavigationBar(
    currentIndex: index,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.blueAccent,
    unselectedItemColor: Colors.black,
    showUnselectedLabels: true,
    unselectedLabelStyle: TextStyle(
      color: Colors.black,
      decorationColor: Colors.black,
    ),
    // this will be set when a new tab is tapped
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
        icon: Icon(Icons.notifications),
        label: 'Alerts',
      ),
    ],
  );
}
