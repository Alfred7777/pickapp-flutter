import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'package:PickApp/map/map_screen.dart';
import 'package:PickApp/my_events/my_events_screen.dart';
import 'package:PickApp/my_groups/my_groups_screen.dart';
import 'package:PickApp/notifications/notifications_screen.dart';
import 'package:PickApp/profile/profile_screen.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/bottom_navbar/bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _screenOptions = [
    MapScreen(),
    MyEventsScreen(),
    MyGroupsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  // ignore: missing_return
  PhoenixMessageCallback _handleNewNotificationsCount(
    Map payload,
    String _ref,
    String _joinRef,
  ) {
    var _newCount = payload['count'];
    var _index;
    if (BlocProvider.of<HomeBloc>(context).state is HomeReady) {
      _index = BlocProvider.of<HomeBloc>(context).state.props.first;
    } else {
      _index = 0;
    }
    BlocProvider.of<HomeBloc>(context).add(
      UpdateUnreadNotificationsCount(
        newUnreadNotificationsCount: _newCount,
        index: _index,
      ),
    );
  }

  void _onIndexChanged(int index) {
    var _unreadNotificationsCount;
    if (BlocProvider.of<HomeBloc>(context).state is HomeReady) {
      _unreadNotificationsCount =
          BlocProvider.of<HomeBloc>(context).state.props.last;
    } else {
      _unreadNotificationsCount = 0;
    }
    BlocProvider.of<HomeBloc>(context).add(
      IndexChanged(
        newIndex: index,
        unreadNotificationsCount: _unreadNotificationsCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      condition: (prevState, currState) => currState is! HomeLoading,
      builder: (context, state) {
        if (state is HomeInitial) {
          BlocProvider.of<HomeBloc>(context).add(
            ConnectNotificationsSocket(
              handleNewNotificationsCount: _handleNewNotificationsCount,
            ),
          );
        }
        if (state is HomeReady) {
          return Scaffold(
            bottomNavigationBar: BottomNavbar(
              onIndexChanged: _onIndexChanged,
              currentIndex: state.index,
              currentNotificationsCount: state.unreadNotificationsCount,
            ),
            body: _screenOptions.elementAt(state.index),
          );
        }
        if (state is HomeFailure) {
          return Center(
            child: Text(
              'Something went terribly wrong. Try restarting your application',
            ),
          );
        }
        return LoadingScreen();
      },
    );
  }
}
