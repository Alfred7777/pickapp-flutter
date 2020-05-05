import 'package:flutter/material.dart';
import 'package:flutterplayground/profile/profile_screen.dart';

class NavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: Drawer(
            child: Column(children: <Widget>[
          Container(
              height: 180,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom:
                          BorderSide(color: Color(0x883D3A3A), width: 0.6))),
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
                              height: 64.0))
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text('Szymon Kuleczka',
                              style: TextStyle(
                                  color: Color(0xFF3D3A3A), fontSize: 22)))
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.only(left: 14.0),
                          child: Text('@c00ler',
                              style: TextStyle(
                                  color: Color(0xFF3D3A3A), fontSize: 14)))
                    ],
                  )
                ],
              )),
          Material(
              color: Color(0xFFFFFFFF),
              child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    // navigation to profile screen, uncomment after profile screen is ready + add import
                    Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                            builder: (context) => ProfileScreen()));
                  },
                  child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color(0x883D3A3A), width: 0.6))),
                      child: Row(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 14.0),
                              child: Icon(Icons.person,
                                  color: Color(0xFF3D3A3A), size: 30.0)),
                          Padding(
                              padding: EdgeInsets.only(left: 12.0),
                              child: Text('Profile',
                                  style: TextStyle(
                                      color: Color(0xFF3D3A3A), fontSize: 18)))
                        ],
                      )))),
          Material(
              color: Color(0xFFFFFFFF),
              child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color(0x883D3A3A), width: 0.6))),
                      child: Row(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 14.0),
                              child: Icon(Icons.settings,
                                  color: Color(0xFF3D3A3A), size: 30.0)),
                          Padding(
                              padding: EdgeInsets.only(left: 12.0),
                              child: Text('Settings',
                                  style: TextStyle(
                                      color: Color(0xFF3D3A3A), fontSize: 18)))
                        ],
                      )))),
          Material(
              color: Color(0xFFFFFFFF),
              child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color(0x883D3A3A), width: 0.6))),
                      child: Row(
                        children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(left: 14.0),
                              child: Icon(Icons.exit_to_app,
                                  color: Color(0xFF3D3A3A), size: 30.0)),
                          Padding(
                              padding: EdgeInsets.only(left: 12.0),
                              child: Text('Log Out',
                                  style: TextStyle(
                                      color: Color(0xFF3D3A3A), fontSize: 18)))
                        ],
                      )))),
          Expanded(
              child: Material(
                  color: Color(0xFFFFFFFF),
                  child: Container(
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color(0x883D3A3A), width: 0.6))),
                      child: Padding(
                          padding: EdgeInsets.only(left: 4.0, bottom: 3.0),
                          child: Align(
                            alignment: FractionalOffset.bottomLeft,
                            child: Text('PickApp © 2020',
                                style: TextStyle(
                                    color: Color(0x88827676), fontSize: 12)),
                          )))))
        ])));
  }
}
