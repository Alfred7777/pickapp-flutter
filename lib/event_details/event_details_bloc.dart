import 'package:PickApp/repositories/eventRepository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'event_details_event.dart';
import 'event_details_state.dart';

class EventDetailsBloc extends Bloc<EventDetailsEvent, EventDetailsState> {
  final EventRepository eventRepository;
  final String eventID;

  EventDetailsBloc({
    @required this.eventRepository,
    @required this.eventID,
  });

  @override
  EventDetailsState get initialState => EventDetailsUninitialized(eventID: eventID);

  @override
  Stream<EventDetailsState> mapEventToState(EventDetailsEvent event) async* {
    if (event is FetchEventDetails) {
      var eventDetails = await eventRepository.getEventDetails(event.eventID);
      var participantsList = await eventRepository.getParticipants(event.eventID);

      if (eventDetails['is_participant']) {
        yield EventDetailsJoined(
          eventID: event.eventID,
          eventDetails: eventDetails,
          participantsList: participantsList,
        );
      } else {
        yield EventDetailsReady(
          eventID: event.eventID,
          eventDetails: eventDetails,
          participantsList: participantsList,
        );
      }
    }
    if (event is JoinEvent) {
      await eventRepository.joinEvent(event.eventID);
      var eventDetails = await eventRepository.getEventDetails(event.eventID);
      var participantsList = await eventRepository.getParticipants(event.eventID);

      if (eventDetails['is_participant']) {
        yield EventDetailsJoined(
          eventID: event.eventID,
          eventDetails: eventDetails,
          participantsList: participantsList,
        );
      } else {
        yield EventDetailsReady(
          eventID: event.eventID,
          eventDetails: eventDetails,
          participantsList: participantsList,
        );
      }
    }
  }
}