import 'package:PickApp/map/filter_map/filter_map_scrollable.dart';
import 'package:PickApp/search/search_screen.dart';
import 'package:PickApp/map/map_bloc.dart';
import 'package:flutter/material.dart';

class MapScreenTopBar extends StatelessWidget implements PreferredSizeWidget {
  final MapBloc mapBloc;

  const MapScreenTopBar({
    @required this.mapBloc,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.search, color: Color(0xFF000000), size: 32.0),
          ButtonTheme(
            minWidth: 170,
            height: 28,
            child: FlatButton(
              onPressed: () {
                var route = MaterialPageRoute<void>(
                  builder: (context) => SearchScreen(),
                );
                Navigator.push(context, route);
              },
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
                return FilterMapScrollable(
                  mapBloc: mapBloc,
                );
              },
            );
          },
        )
      ],
    );
  }
}

class MainScreenTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const MainScreenTopBar({
    @required this.title,
    this.actions,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.green,
      elevation: 0,
      actions: actions,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SideScreenTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const SideScreenTopBar({
    @required this.title,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
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
        title,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class SearchTopBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController queryTextController;
  final String searchFieldHint;
  final double elevation;

  const SearchTopBar({
    @required this.queryTextController,
    @required this.searchFieldHint,
    @required this.elevation,
  });

  @override
  Size get preferredSize => Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[100],
      elevation: elevation,
      brightness: Brightness.light,
      iconTheme: IconThemeData(
        color: Colors.grey[500],
        opacity: 1.0,
      ),
      leading: IconButton(
        iconSize: 30.0,
        icon: Icon(
          Icons.arrow_back,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          iconSize: 30.0,
          icon: Icon(
            Icons.clear,
          ),
          onPressed: () => queryTextController.clear(),
        ),
      ],
      title: TextField(
        controller: queryTextController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 18.0,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: searchFieldHint,
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}
