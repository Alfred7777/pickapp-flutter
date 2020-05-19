import 'package:flutter/material.dart';

BottomNavigationBar bottomNavbar(int index) {
  return BottomNavigationBar(
    currentIndex: index,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: Colors.blueAccent,
    unselectedItemColor: Colors.black,
    showUnselectedLabels: true,
    unselectedLabelStyle:
        TextStyle(color: Colors.black, decorationColor: Colors.black),
    // this will be set when a new tab is tapped
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.public),
        title: Text('Map'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.event),
        title: Text('My events'),
      ),
      BottomNavigationBarItem(icon: Icon(Icons.people), title: Text('Groups')),
      BottomNavigationBarItem(
          icon: Icon(Icons.notifications), title: Text('Alerts'))
    ],
  );
}
