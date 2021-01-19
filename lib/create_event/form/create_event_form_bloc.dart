import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'create_event_form_event.dart';
import 'create_event_form_state.dart';
import 'package:PickApp/repositories/event_repository.dart';

class CreateEventFormBloc
    extends Bloc<CreateEventFormEvent, CreateEventFormState> {
  final EventRepository eventRepository;

  CreateEventFormBloc({@required this.eventRepository});

  @override
  CreateEventFormState get initialState => CreateEventFormInitial();

  @override
  Stream<CreateEventFormState> mapEventToState(
      CreateEventFormEvent event) async* {
    if (event is FetchDisciplines) {
      try {
        yield CreateEventFormLoading();

        var _disciplines = await eventRepository.getDisciplines();

        yield CreateEventFormReady(
          disciplines: _disciplines,
        );
      } catch (exception) {
        yield FetchDisciplinesFailure(error: exception.message);
      }
    }
    if (event is CreateEventButtonPressed) {
      var response = await eventRepository.createEvent(
        name: event.eventName,
        description: event.eventDescription,
        disciplineID: event.eventDisciplineID,
        pos: event.eventPos,
        locationID: event.locationID,
        startDate: event.eventStartDate,
        endDate: event.eventEndDate,
        allowInvitations: event.allowInvitations,
        requireParticipationAcceptation: event.requireParticipationAcceptation,
        recurrenceIntervalInSeconds: event.recurrenceIntervalInSeconds,
      );
      if (response == 'Event successfully created.') {
        yield CreateEventFormCreated(
          pos: event.eventPos,
          message: response,
        );
      } else {
        yield CreateEventFormFailure(
          error: response,
        );
      }
      yield CreateEventFormReady(
        disciplines: event.disciplines,
      );
    }
  }
}
