import 'package:PickApp/event_update/bloc/event_update_state.dart';
import 'package:PickApp/event_update/bloc/event_update_event.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class EventUpdateBloc extends Bloc<EventUpdateEvent, EventUpdateState> {
  final String initialEventName;
  final String initialEventDisciplineID;
  final String initialEventDescription;
  final DateTime initialEventStartDate;
  final DateTime initialEventEndDate;
  final bool initialAllowInvitations;
  final bool initialRequireParticipationAcceptation;
  final EventRepository eventRepository;

  EventUpdateBloc({
    @required this.initialEventName,
    @required this.initialEventDisciplineID,
    @required this.initialEventDescription,
    @required this.initialEventStartDate,
    @required this.initialEventEndDate,
    @required this.initialAllowInvitations,
    @required this.initialRequireParticipationAcceptation,
    @required this.eventRepository,
  });

  @override
  EventUpdateState get initialState => EventUpdateInitial(
        eventName: initialEventName,
        eventDisciplineID: initialEventDisciplineID,
        eventDescription: initialEventDescription,
        eventStartDate: initialEventStartDate,
        eventEndDate: initialEventEndDate,
        allowInvitations: initialAllowInvitations,
        requireParticipationAcceptation: initialRequireParticipationAcceptation,
      );

  @override
  Stream<EventUpdateState> mapEventToState(event) async* {
    if (event is EventUpdateFirstStepFinished) {
      yield EventUpdateFirstStepSet(
        eventName: event.eventName,
        eventDisciplineID: event.eventDisciplineID,
        eventPrivacy: event.eventPrivacy,
      );
    }
    if (event is UpdateEventButtonPressed) {
      // There is probably better way of doing that, but for now i do not have
      // any other idea.
      event.eventName =
          event.eventName == initialEventName ? null : event.eventName;

      event.eventDescription = event.eventDescription == initialEventDescription
          ? null
          : event.eventDescription;

      event.eventDisciplineID =
          event.eventDisciplineID == initialEventDisciplineID
              ? null
              : event.eventDisciplineID;

      event.eventStartDate = event.eventStartDate == initialEventStartDate
          ? null
          : event.eventStartDate;

      event.eventEndDate =
          event.eventEndDate == initialEventEndDate ? null : event.eventEndDate;

      event.allowInvitations = event.allowInvitations == initialAllowInvitations
          ? null
          : event.allowInvitations;

      event.requireParticipationAcceptation =
          event.requireParticipationAcceptation ==
                  initialRequireParticipationAcceptation
              ? null
              : event.requireParticipationAcceptation;

      try {
        var response = await eventRepository.updateEvent(
          name: event.eventName,
          description: event.eventDescription,
          disciplineID: event.eventDisciplineID,
          eventID: event.eventID,
          startDate: event.eventStartDate,
          endDate: event.eventEndDate,
          allowInvitations: event.allowInvitations,
          requireParticipationAcceptation:
              event.requireParticipationAcceptation,
        );

        yield EventUpdateSuccess(message: response);
      } catch (error) {
        yield EventUpdateFailure(error: error.message);
      }
      yield EventUpdateLoading();
    }
  }
}
