import 'package:PickApp/map/filter_map/filter_map_screen.dart';
import 'package:PickApp/map/map_bloc.dart';
import 'package:flutter/material.dart';

AppBar mapScreenTopBar(BuildContext context, MapBloc mapBloc) {
  return AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.menu),
      iconSize: 34.0,
      color: Color(0xFF000000),
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
    centerTitle: true,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.search, color: Color(0xFF000000), size: 32.0),
        ButtonTheme(
          minWidth: 170,
          height: 28,
          child: FlatButton(
            onPressed: () {},
            color: Color(0x55C4C4C4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: null,
          ),
        ),
      ],
    ),
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.filter_list),
        iconSize: 34.0,
        color: Color(0xFF000000),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return FilterMapScreen(mapBloc: mapBloc);
            },
          );
        },
      )
    ],
  );
}

AppBar mainScreenTopBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.green,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.menu),
      iconSize: 34.0,
      color: Colors.white,
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
    ),
    centerTitle: true,
    title: Text(
      'PickApp',
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

AppBar sideScreenTopBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.green,
    elevation: 0,
    leading: IconButton(
      iconSize: 34.0,
      icon: Icon(
        Icons.arrow_back,
        color: Colors.white,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    ),
    centerTitle: true,
    title: Text(
      'PickApp',
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
