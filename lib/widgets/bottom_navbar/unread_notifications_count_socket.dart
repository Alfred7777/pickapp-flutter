import 'package:PickApp/widgets/bottom_navbar/bottom_navbar_bloc.dart';
import 'package:PickApp/widgets/bottom_navbar/bottom_navbar_event.dart';
import 'package:meta/meta.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

class UnreadNotificationsCountSocket {
  final String authToken;
  final BottomNavbarBloc bottomNavbarBloc;

  final String socketUrl = 'ws://pickapp.projektstudencki.pl/socket/websocket';
  final String topic = 'unread_notifications_count';
  final String incomingEventName = 'new_count';

  UnreadNotificationsCountSocket(
      {@required this.authToken, @required this.bottomNavbarBloc});

  Future<void> connect() async {
    final socket = PhoenixSocket(socketUrl,
        socketOptions: PhoenixSocketOptions(params: {'auth_token': authToken}));
    await socket.connect();

    final channel = socket.channel(topic, {});
    channel.on(incomingEventName, handleNewNotificationsCount);
    channel.join();
  }

  PhoenixMessageCallback handleNewNotificationsCount(
      Map payload, String _ref, String _joinRef) {
    var newCount = payload['count'];
    bottomNavbarBloc
        .add(NotificationsCountUpdated(newUnreadNotificationsCount: newCount));
  }
}
