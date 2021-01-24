import 'package:PickApp/home/event_rating_bloc.dart';
import 'package:PickApp/home/event_rating_event.dart';
import 'package:PickApp/home/event_rating_scrollable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phoenix_wings/phoenix_wings.dart';
import 'event_rating_state.dart';
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
    return BlocProvider<EventRatingBloc>(
      create: (BuildContext context) => EventRatingBloc(),
      child: BlocListener<EventRatingBloc, EventRatingState>(
        listener: (context, state) {
          var eventRatingBloc = BlocProvider.of<EventRatingBloc>(context);

          if (state is EventRatingUnconnected) {
            BlocProvider.of<EventRatingBloc>(context)
                .add(ConnectToEventRatingSocket());
          }
          if (state is EventRatingInitialized) {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  var screenSize = MediaQuery.of(context).size;
                  return Padding(
                    padding: EdgeInsets.only(
                      top: 0.12 * screenSize.height,
                      bottom: 0.02 * screenSize.height,
                      left: 0.02 * screenSize.width,
                      right: 0.02 * screenSize.width,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32.0),
                      child: Material(
                        color: Colors.grey[100],
                        child: EventRatingScrollable(
                          event: state.event,
                          participants: state.participants,
                          usersRating: state.usersRating,
                          eventRatingBloc: eventRatingBloc,
                        ),
                      ),
                    ),
                  );
                });
          }
          if (state is EventRatingFinished) {
            Navigator.pop(context);
          }
          if (state is EventRatingFailure) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<HomeBloc, HomeState>(
          condition: (prevState, currState) => currState is! HomeLoading,
          builder: (context, state) {
            if (state is HomeInitial) {
              BlocProvider.of<HomeBloc>(context).add(
                ConnectNotificationsSocket(
                  handleNewNotificationsCount: _handleNewNotificationsCount,
                ),
              );
              BlocProvider.of<EventRatingBloc>(context)
                  .add(ConnectToEventRatingSocket());
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
        ),
      ),
    );
  }
}
