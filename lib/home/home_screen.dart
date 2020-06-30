import 'package:PickApp/map/map_screen.dart';
import 'package:PickApp/my_events/my_events_screen.dart';
import 'package:flutter/material.dart';
import 'package:PickApp/repositories/userRepository.dart';
import 'package:PickApp/widgets/nav_drawer/nav_drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final userRepository = UserRepository();
  HomeBloc _homeBloc;

  final _screenOptions = [
    MapScreen(),
    MyEventsScreen(),
    MapScreen(), //change after groups screen is ready
    MapScreen(), //change after alerts screen is ready
  ];

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc(userRepository: userRepository);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
          return _buildHomeScreen(context, state.details);
        }
        if (state is HomeError) {
          return Center(
            child: Text('Error :('),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildHomeScreen(BuildContext context, User loggedUser) {
    return Scaffold(
      body: _screenOptions.elementAt(_selectedIndex),
      drawer: NavDrawer(
        user: loggedUser,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        selectedFontSize: 13,
        unselectedItemColor: Colors.black,
        unselectedFontSize: 13,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            title: Text('Map'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            title: Text('My events'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people), 
            title: Text('Groups'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications), 
            title: Text('Alerts'),
          ),
        ],
      ),
    );
  }
}
