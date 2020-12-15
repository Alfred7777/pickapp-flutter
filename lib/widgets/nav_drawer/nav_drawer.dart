import 'package:PickApp/map/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:PickApp/widgets/nav_drawer/nav_drawer_item.dart';
import 'package:PickApp/profile/profile_screen.dart';
import 'package:PickApp/repositories/user_repository.dart';

class NavDrawer extends StatelessWidget {
  final User user;

  NavDrawer({@required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Drawer(
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Color(0x883D3A3A), width: 0.6),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          top: 38.0,
                          left: 14.0,
                          bottom: 14.0,
                        ),
                        child: Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                'assets/images/profile_placeholder.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 14.0),
                        child: Text(
                          user.name,
                          style: TextStyle(
                            color: Color(0xFF3D3A3A),
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 14.0),
                        child: Text(
                          '@${user.uniqueUsername}',
                          style: TextStyle(
                            color: Color(0xFF3D3A3A),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            NavDraverItem(
              Icon(
                Icons.person,
                color: Color(0xFF3D3A3A),
                size: 30.0,
              ),
              Text(
                'Profile',
                style: TextStyle(
                  color: Color(0xFF3D3A3A),
                  fontSize: 18,
                ),
              ),
              MaterialPageRoute<void>(builder: (context) => ProfileScreen()),
            ),
            NavDraverItem(
              Icon(
                Icons.settings,
                color: Color(0xFF3D3A3A),
                size: 30.0,
              ),
              Text(
                'Settings',
                style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 18),
              ),
              // redirect to map view, change after according view is ready + add import
              MaterialPageRoute<void>(builder: (context) => MapScreen()),
            ),
            NavDraverItem(
              Icon(
                Icons.exit_to_app,
                color: Color(0xFF3D3A3A),
                size: 30.0,
              ),
              Text(
                'Log Out',
                style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 18),
              ),
              // redirect to map view, change after according view is ready + add import
              MaterialPageRoute<void>(builder: (context) => MapScreen()),
            ),
            Expanded(
              child: Material(
                color: Color(0xFFFFFFFF),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0x883D3A3A), width: 0.6),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 3.0),
                    child: Align(
                      alignment: FractionalOffset.bottomLeft,
                      child: Text(
                        'PickApp © 2020',
                        style: TextStyle(
                          color: Color(0x88827676),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
