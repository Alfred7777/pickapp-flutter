import 'package:flutter/material.dart';
import 'package:PickApp/map/map.dart';
import 'package:PickApp/widgets/nav_drawer/nav_drawer_item.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Drawer(
        child: Column(
          children: <Widget> [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0x883D3A3A),
                    width: 0.6
                  )
                )
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        height: 24,
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(14.0),
                        child: Image.network(
                          'https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png',
                          width: 64.0,
                          height: 64.0
                        )
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 14.0),
                        child: Text(
                          'Szymon Kuleczka',
                          style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 22)
                        )
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 14.0),
                        child: Text(
                          '@c00ler',
                          style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 14)
                        )
                      )
                    ],
                  )
                ],
              )
            ),
            NavDraverItem(
              Icon(
                Icons.person,
                color: Color(0xFF3D3A3A),
                size: 30.0
              ), 
              Text(
                'Profile',
                style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 18)
              ), 
              // redirect to map view, change after according view is ready + add import
              MaterialPageRoute<void>(builder: (context) => MapSample())
            ),
            NavDraverItem(
              Icon(
                Icons.settings,
                color: Color(0xFF3D3A3A),
                size: 30.0
              ), 
              Text(
                'Settings',
                style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 18)
              ), 
              // redirect to map view, change after according view is ready + add import
              MaterialPageRoute<void>(builder: (context) => MapSample())
            ),
            NavDraverItem(
              Icon(
                Icons.exit_to_app,
                color: Color(0xFF3D3A3A),
                size: 30.0
              ), 
              Text(
                'Log Out',
                style: TextStyle(color: Color(0xFF3D3A3A), fontSize: 18)
              ), 
              // redirect to map view, change after according view is ready + add import
              MaterialPageRoute<void>(builder: (context) => MapSample())
            ),
            Expanded(
              child: Material(
                color: Color(0xFFFFFFFF),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0x883D3A3A),
                        width: 0.6
                      )
                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.0, bottom: 3.0),
                    child: Align(
                      alignment: FractionalOffset.bottomLeft,
                      child: Text(
                        'PickApp © 2020',
                        style: TextStyle(color: Color(0x88827676), fontSize: 12)
                      ),
                    )
                  )
                )
              )
            )
          ]
        )
      )
    );
  }
}
