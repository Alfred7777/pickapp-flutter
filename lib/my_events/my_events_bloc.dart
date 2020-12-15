import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'my_events_event.dart';
import 'my_events_state.dart';
import 'package:PickApp/repositories/event_repository.dart';

class MyEventsBloc extends Bloc<MyEventsEvent, MyEventsState> {
  final EventRepository eventRepository;

  MyEventsBloc({
    @required this.eventRepository,
  }) : assert(eventRepository != null);

  @override
  MyEventsState get initialState => MyEventsUninitialized();

  @override
  Stream<MyEventsState> mapEventToState(MyEventsEvent event) async* {
    if (event is FetchMyEvents) {
      yield MyEventsLoading();
      try {
        var _myActiveEvents = await eventRepository.getMyEvents('active');
        var _myPastEvents = await eventRepository.getMyEvents('past');
        var _eventInvitations = await eventRepository.getEventInvitations();

        yield MyEventsReady(
          myActiveEvents: _myActiveEvents,
          myPastEvents: _myPastEvents,
          eventInvitations: _eventInvitations,
        );
      } catch (exception) {
        yield FetchEventsFailure(error: exception.message);
      }
    }
    if (event is AnswerInvitation) {
      try {
        if (event.answer == 'accept') {
          await eventRepository.answerInvitation(event.invitation, 'accept');
        } else {
          await eventRepository.answerInvitation(event.invitation, 'reject');
        }
        yield MyEventsUninitialized();
      } catch (exception) {
        yield AnswerInvitationFailure(
          error: exception.message,
        );
        yield MyEventsReady(
          myActiveEvents: event.myActiveEvents,
          myPastEvents: event.myPastEvents,
          eventInvitations: event.eventInvitations,
        );
      }
    }
  }
}
