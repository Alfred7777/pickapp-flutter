import 'package:PickApp/home/event_rating_bloc.dart';
import 'package:PickApp/home/event_rating_event.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:meta/meta.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

class EventRatingSocket {
  final String authToken;
  final EventRatingBloc eventRatingBloc;

  final String socketUrl = 'ws://18.197.42.194:4000/socket/websocket';
  final String topic = 'event_rating';
  final String incomingEventName = 'initialize_rating';

  EventRatingSocket({
    @required this.authToken,
    @required this.eventRatingBloc,
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
    channel.on(incomingEventName, handleRatingInitialized);
    channel.join();
  }

  // ignore: missing_return
  PhoenixMessageCallback handleRatingInitialized(
      Map payload, String _ref, String _joinRef) {
    var participants = (payload['participants_profiles'] as List<dynamic>)
        .map(constructUser)
        .toList();
    var event = Event.fromJson(payload['event']);

    eventRatingBloc.add(
      ShowEventRating(participants: participants, event: event),
    );
  }

  User constructUser(params) {
    return User.fromJson(params);
  }
}
