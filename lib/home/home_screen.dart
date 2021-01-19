import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import 'package:PickApp/widgets/bottom_navbar/bottom_navbar.dart';
import 'package:PickApp/widgets/bottom_navbar/bottom_navbar_bloc.dart';
import 'package:PickApp/map/map_screen.dart';
import 'package:PickApp/my_events/my_events_screen.dart';
import 'package:PickApp/my_groups/my_groups_screen.dart';
import 'package:PickApp/notifications/notifications_screen.dart';
import 'package:PickApp/profile/profile_screen.dart';
import 'package:PickApp/repositories/user_repository.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final userRepository = UserRepository();
  HomeBloc _homeBloc;

  final _screenOptions = [
    MapScreen(),
    MyEventsScreen(),
    MyGroupsScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(userRepository: userRepository);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      bloc: _homeBloc,
      builder: (context, state) {
        if (state is InitialHomeState) {
          _homeBloc.add(FetchProfile(userID: null));
        }
        if (state is HomeLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is HomeLoaded) {
          return _buildHomeScreen(
            context,
            state.details,
            state.index,
          );
        }
        if (state is HomeError) {
          return Center(
            child: Text(
              'Something went terribly wrong. Try restarting your application',
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildHomeScreen(BuildContext context, User loggedUser, int index) {
    return Scaffold(
      body: _screenOptions.elementAt(index),
      bottomNavigationBar: BlocProvider(
        create: (context) {
          return BottomNavbarBloc(homeBloc: _homeBloc);
        },
        child: BottomNavbarWidget(),
      ),
    );
  }
}
