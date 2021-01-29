import 'package:PickApp/repositories/event_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'event_update_event.dart';
import 'event_update_state.dart';

class EventUpdateBloc extends Bloc<EventUpdateEvent, EventUpdateState> {
  final EventRepository eventRepository;
  final String eventID;

  EventUpdateBloc({
    @required this.eventRepository,
    @required this.eventID,
  });

  @override
  EventUpdateState get initialState => EventUpdateUninitialized(
        eventID: eventID,
      );

  @override
  Stream<EventUpdateState> mapEventToState(EventUpdateEvent event) async* {
    if (event is FetchInitialDetails) {
      try {
        yield EventUpdateLoading();
        var _disciplines = await eventRepository.getDisciplines();
        var _initialDetails = await eventRepository.getEventDetails(
          event.eventID,
        );

        yield EventUpdateReady(
          initialDetails: _initialDetails,
          disciplines: _disciplines,
        );
      } catch (exception) {
        yield EventUpdateFailure(error: exception.message);
      }
    }
    if (event is UpdateEventButtonPressed) {
      var response = await eventRepository.updateEvent(
        eventID: event.eventID,
        name: event.eventName == event.initialDetails.name
            ? null
            : event.eventName,
        description: event.eventDescription == event.initialDetails.description
            ? null
            : event.eventDescription,
        disciplineID:
            event.eventDisciplineID == event.initialDetails.disciplineID
                ? null
                : event.eventDisciplineID,
        startDate: event.eventStartDate == event.initialDetails.startDate
            ? null
            : event.eventStartDate,
        endDate: event.eventEndDate == event.initialDetails.endDate
            ? null
            : event.eventEndDate,
        allowInvitations: event.eventPrivacyRule ==
                EventPrivacyRule.fromBooleans(
                  event.initialDetails.allowInvitations,
                  event.initialDetails.requireParticipationAcceptation,
                )
            ? null
            : event.eventPrivacyRule.allowInvitations,
        requireParticipationAcceptation: event.eventPrivacyRule ==
                EventPrivacyRule.fromBooleans(
                  event.initialDetails.allowInvitations,
                  event.initialDetails.requireParticipationAcceptation,
                )
            ? null
            : event.eventPrivacyRule.requireParticipationAcceptation,
        recurrenceIntervalInSeconds: event.recurrenceIntervalInSeconds ==
                event.initialDetails.recurrenceIntervalInSeconds
            ? null
            : event.recurrenceIntervalInSeconds,
      );
      if (response == 'Event successfully updated.') {
        yield EventUpdateSuccess(
          message: response,
        );
      } else {
        yield EventUpdateFailure(
          error: response,
        );
      }
      yield EventUpdateReady(
        initialDetails: event.initialDetails,
        disciplines: event.disciplines,
      );
    }
  }
}
