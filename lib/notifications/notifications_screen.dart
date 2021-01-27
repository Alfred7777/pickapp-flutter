import 'package:PickApp/event_details/event_details_screen.dart';
import 'package:PickApp/home/home_bloc.dart';
import 'package:PickApp/home/home_event.dart';
import 'package:PickApp/home/home_state.dart';
import 'package:flutter/material.dart';
import 'notifications_bloc.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:PickApp/repositories/notification_repository.dart' as nr;
import 'package:PickApp/widgets/top_bar.dart';

class NotificationsScreen extends StatefulWidget {
  NotificationsScreen();

  @override
  State<NotificationsScreen> createState() => NotificationsScreenState();
}

class NotificationsScreenState extends State<NotificationsScreen> {
  final notificationRepository = nr.NotificationRepository();
  NotificationsBloc _notificationsBloc;
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _notificationsBloc = NotificationsBloc(
      notificationRepository: notificationRepository,
    );
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _notificationsBloc.close();
  }

  int _notificationsLimit() {
    var screenSize = MediaQuery.of(context).size;
    return (screenSize.height / 60).ceil() + 1;
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (_notificationsBloc.state.props.first != null) {
        _notificationsBloc.add(FetchNotifications(
          nextToken: _notificationsBloc.state.props.first,
          notifications: _notificationsBloc.state.props.last,
          limit: _notificationsLimit(),
        ));
      }
    }
  }

  Future<void> _refreshView() async {
    _notificationsBloc.add(FetchNotifications(
      nextToken: null,
      notifications: [],
      limit: _notificationsLimit(),
    ));
  }

  void _markAllAsRead(List<nr.Notification> allNotifications) {
    _notificationsBloc.add(
      MarkAllAsRead(notificationsToMark: allNotifications),
    );
  }

  void _notificationRedirect(String notificationType, String referenceID) {
    var _homeBlocState = BlocProvider.of<HomeBloc>(context).state;
    if (_homeBlocState is HomeReady) {
      if (notificationType == 'event_invitation') {
        BlocProvider.of<HomeBloc>(context).add(
          IndexChanged(
            newIndex: 1,
            unreadNotificationsCount: _homeBlocState.props.last,
          ),
        );
      } else if (notificationType == 'group_invitation') {
        BlocProvider.of<HomeBloc>(context).add(
          IndexChanged(
            newIndex: 2,
            unreadNotificationsCount: _homeBlocState.props.last,
          ),
        );
      } else if (notificationType == 'event') {
        var route = MaterialPageRoute<void>(
          builder: (context) => EventDetailsScreen(
            eventID: referenceID,
            showButtons: true,
          ),
        );
        Navigator.push(context, route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationsBloc, NotificationsState>(
      bloc: _notificationsBloc,
      listener: (context, state) {
        if (state is FetchNotificationsFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        bloc: _notificationsBloc,
        condition: (prevState, currState) => currState is! NotificationsLoading,
        builder: (context, state) {
          if (state is NotificationsUninitialized) {
            _notificationsBloc.add(FetchNotifications(
              nextToken: null,
              notifications: [],
              limit: _notificationsLimit(),
            ));
          }
          if (state is NotificationsReady) {
            return Scaffold(
              appBar: MainScreenTopBar(
                title: 'Notifications',
                actions: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.check_box_sharp,
                      size: 30,
                      color: Colors.white,
                    ),
                    color: Colors.black,
                    onPressed: () => _markAllAsRead(state.notifications),
                  )
                ],
              ),
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshView,
                  child: state.notifications.isEmpty
                      ? EmptyListPlaceholder()
                      : NotificationsList(
                          notifications: state.notifications,
                          nextToken: state.nextToken,
                          scrollController: _scrollController,
                          notificationRedirect: _notificationRedirect,
                        ),
                ),
              ),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class EmptyListPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 0.2 * screenSize.height,
            bottom: 0.04 * screenSize.height,
          ),
          child: Text(
            ':(',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 0.32 * screenSize.width,
              color: Colors.grey[400],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 0.04 * screenSize.width,
          ),
          child: Text(
            'There is nothing here yet. \n We will notify you if something interesting happens!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }
}

class NotificationsList extends StatelessWidget {
  final List<nr.Notification> notifications;
  final String nextToken;
  final ScrollController scrollController;
  final Function notificationRedirect;

  const NotificationsList({
    @required this.notifications,
    @required this.nextToken,
    @required this.scrollController,
    @required this.notificationRedirect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: AlwaysScrollableScrollPhysics(),
      controller: scrollController,
      itemCount: notifications.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == notifications.length) {
          if (nextToken == null) {
            return Material();
          }
          return LoadingBar();
        }
        return NotificationBar(
          notification: notifications[index],
          notificationRedirect: notificationRedirect,
        );
      },
    );
  }
}

class NotificationBar extends StatelessWidget {
  final nr.Notification notification;
  final Function notificationRedirect;

  const NotificationBar({
    @required this.notification,
    @required this.notificationRedirect,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        notificationRedirect(
          notification.type,
          notification.referenceID,
        );
      },
      child: Container(
        height: 60,
        width: screenSize.width,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black45, width: 0.3),
            top: BorderSide(color: Colors.black45, width: 0.3),
          ),
          color: notification.isUnread ? Colors.lightBlue[50] : Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage(
                      'assets/images/icons/notification/${notification.type}.png',
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Text(
                      notification.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: 10,
                    ),
                    child: Text(
                      notification.description,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Padding(
        //       padding: EdgeInsets.only(
        //         left: 0.04 * screenSize.width,
        //       ),
        //       child: Text(
        //         notification.title,
        //         overflow: TextOverflow.ellipsis,
        //         maxLines: 1,
        //         style: TextStyle(
        //           fontWeight: FontWeight.bold,
        //           fontSize: 0.036 * screenSize.width,
        //         ),
        //       ),
        //     ),
        //     Padding(
        //       padding: EdgeInsets.only(
        //         left: 0.04 * screenSize.width,
        //       ),
        //       child: Text(
        //         notification.description,
        //         overflow: TextOverflow.ellipsis,
        //         maxLines: 2,
        //         style: TextStyle(
        //           fontSize: 0.032 * screenSize.width,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}

class LoadingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      height: 0.20 * screenSize.width,
      width: screenSize.width,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 0.02 * screenSize.width,
          horizontal: 0.44 * screenSize.width,
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }
}
