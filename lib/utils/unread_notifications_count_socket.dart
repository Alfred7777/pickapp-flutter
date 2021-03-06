import 'package:meta/meta.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

class UnreadNotificationsCountSocket {
  final String authToken;
  final PhoenixMessageCallback handleNewNotificationsCount;

  final String socketUrl = 'ws://18.197.42.194:4000/socket/websocket';
  final String topic = 'unread_notifications_count';
  final String incomingEventName = 'new_count';

  UnreadNotificationsCountSocket({
    @required this.authToken,
    @required this.handleNewNotificationsCount,
  });

  Future<void> connect() async {
    final socket = PhoenixSocket(
      socketUrl,
      socketOptions: PhoenixSocketOptions(
        params: {'auth_token': authToken},
      ),
    );
    await socket.connect();

    final channel = socket.channel(topic, {});
    channel.on(incomingEventName, handleNewNotificationsCount);
    channel.join();
  }

  // ignore: missing_return
  // PhoenixMessageCallback handleNewNotificationsCount(
  //     Map payload, String _ref, String _joinRef) {
  //   var newCount = payload['count'];
  //   bottomNavbarBloc.add(
  //     NotificationsCountUpdated(newUnreadNotificationsCount: newCount),
  //   );
  // }
}
