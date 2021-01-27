import 'package:PickApp/home/event_rating_event.dart';
import 'package:PickApp/home/event_rating_state.dart';
import 'package:PickApp/repositories/authentication_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'event_rating_socket.dart';

class EventRatingBloc extends Bloc<EventRatingEvent, EventRatingState> {
  @override
  EventRatingState get initialState => EventRatingUnconnected();

  @override
  Stream<EventRatingState> mapEventToState(EventRatingEvent event) async* {
    if (event is ConnectToEventRatingSocket) {
      var authToken = await (AuthenticationRepository.getAuthToken());
      var eventRatingSocket = EventRatingSocket(
        authToken: authToken,
        eventRatingBloc: this,
      );

      await eventRatingSocket.connect();

      yield EventRatingUninitialized();
    }
    if (event is ShowEventRating) {
      yield EventRatingInitialized(
        event: event.event,
        participants: event.participants,
        usersRating: {},
      );
    }
    if (event is SubmitUserRating) {
      try {
        await UserRepository.submitRatings(event.usersRating, event.event.id);
        yield EventRatingFinished();
      } catch (exception) {
        yield EventRatingFailure(error: exception.message);
      }
    }
  }
}
