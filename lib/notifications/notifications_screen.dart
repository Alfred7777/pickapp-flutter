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
    return (screenSize.height / (0.16 * screenSize.width)).ceil() + 1;
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
              appBar: mainScreenTopBar(context),
              body: SafeArea(
                child: RefreshIndicator(
                  onRefresh: _refreshView,
                  child: state.notifications.isEmpty
                      ? EmptyListPlaceholder()
                      : NotificationsList(
                          notifications: state.notifications,
                          nextToken: state.nextToken,
                          scrollController: _scrollController,
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

  const NotificationsList({
    @required this.notifications,
    @required this.nextToken,
    @required this.scrollController,
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
        );
      },
    );
  }
}

class NotificationBar extends StatelessWidget {
  final nr.Notification notification;

  const NotificationBar({
    @required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      height: 0.16 * screenSize.width,
      width: screenSize.width,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.black45, width: 0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 0.04 * screenSize.width,
            ),
            child: Text(
              notification.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 0.036 * screenSize.width,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 0.04 * screenSize.width,
            ),
            child: Text(
              notification.description,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 0.032 * screenSize.width,
              ),
            ),
          ),
        ],
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
