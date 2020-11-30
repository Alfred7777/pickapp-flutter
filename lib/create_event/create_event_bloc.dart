import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'create_event_event.dart';
import 'create_event_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState> {
  final EventRepository eventRepository;

  CreateEventBloc({@required this.eventRepository});

  @override
  CreateEventState get initialState => CreateEventInitial();

  @override
  Stream<CreateEventState> mapEventToState(CreateEventEvent event) async* {
    if (event is FetchDisciplines) {
      try {
        yield CreateEventLoading();

        var _disciplines = await eventRepository.getDisciplines();
        var _eventPrivacySettings = eventRepository.getEventPrivacyRules();

        yield CreateEventReady(
          disciplines: _disciplines,
          eventPrivacySettings: _eventPrivacySettings,
          pickedPos: null,
        );
      } catch (exception) {
        yield FetchDisciplinesFailure(error: exception.message);
      }
    }
    if (event is LocationPicked) {
      yield CreateEventLoading();

      yield CreateEventReady(
        disciplines: event.disciplines,
        eventPrivacySettings: event.eventPrivacySettings,
        pickedPos: event.pickedPos,
      );
    }
    if (event is CreateEventButtonPressed) {
      var response = await eventRepository.createEvent(
        name: event.eventName,
        description: event.eventDescription,
        disciplineID: event.eventDisciplineID,
        pos: event.eventPos,
        startDate: event.eventStartDate,
        endDate: event.eventEndDate,
        allowInvitations: event.allowInvitations,
        requireParticipationAcceptation:
            event.requireParticipationAcceptation,
      );
      if (response.containsKey('message')) {
        yield CreateEventCreated(
          pos: event.eventPos,
          message: response['message'],
        );
      } else {
        yield CreateEventFailure(
          disciplines: event.disciplines,
          eventPrivacySettings: event.eventPrivacySettings,
          pickedPos: event.eventPos,
          errors: response,
        );
      }
      yield CreateEventReady(
        disciplines: event.disciplines,
        eventPrivacySettings: event.eventPrivacySettings,
        pickedPos: event.eventPos,
      );
    }
  }
}
