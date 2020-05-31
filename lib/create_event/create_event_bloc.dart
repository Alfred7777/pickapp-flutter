import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'create_event_event.dart';
import 'create_event_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';

class CreateEventBloc extends Bloc<CreateEventEvent, CreateEventState>{
  final EventRepository eventRepository;

  CreateEventBloc({
    @required this.eventRepository
  });

  @override
  CreateEventState get initialState => CreateEventInitial();

  @override
  Stream<CreateEventState> mapEventToState(CreateEventEvent event) async* {
    if (event is CreateEventButtonPressed) {
      try {
        var response = await eventRepository.createEvent(
          name: event.eventName,
          description: event.eventDescription,
          disciplineID: event.eventDisciplineID,
          pos: event.eventPos,
          startDate: event.eventStartDate,
          endDate: event.eventEndDate,
        );
        yield CreateEventCreated(message: response);
      } catch (error) {
        yield CreateEventFailure(error: error.toString());
      }
      yield CreateEventInitial();
    }
  }
}