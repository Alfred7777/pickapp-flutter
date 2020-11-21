import 'package:PickApp/widgets/bottom_navbar/bottom_navbar_bloc.dart';
import 'package:PickApp/widgets/bottom_navbar/bottom_navbar_event.dart';
import 'package:PickApp/widgets/bottom_navbar/ui/bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bottom_navbar_state.dart';

class BottomNavbarWidget extends StatefulWidget {
  BottomNavbarWidget();

  @override
  BottomNavbarWidgetState createState() => BottomNavbarWidgetState();
}

class BottomNavbarWidgetState extends State<BottomNavbarWidget> {
  @override
  Widget build(BuildContext context) {
    var _bottomNavbarBloc = BlocProvider.of<BottomNavbarBloc>(context);

    return BlocBuilder<BottomNavbarBloc, BottomNavbarState>(
        bloc: _bottomNavbarBloc,
        builder: (context, state) {
          if (state is InitialBottomNavbarState) {
            _bottomNavbarBloc.add(InitializeBottomNavbar());
            return BottomNavbar(
              currentIndex: 0,
              currentNotificationsCount: state.initialCount,
              bloc: _bottomNavbarBloc,
            );
          }
          if (state is BottomNavbarLoaded) {
            return BottomNavbar(
              currentIndex: state.index,
              currentNotificationsCount: state.currentUnreadNotificationsCount,
              bloc: _bottomNavbarBloc,
            );
          }
          return Container();
        });
  }
}
