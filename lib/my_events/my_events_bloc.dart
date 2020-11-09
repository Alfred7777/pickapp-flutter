import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'my_events_event.dart';
import 'my_events_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';

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
      try {
        var _myActiveEvents = await eventRepository.getMyEvents('active');
        var _myPastEvents = await eventRepository.getMyEvents('past');

        yield MyEventsReady(
          myActiveEvents: _myActiveEvents,
          myPastEvents: _myPastEvents,
        );
      } catch (error) {
        yield MyEventsFailure(error: error.message);
        await Future.delayed(const Duration(seconds : 1));
        yield MyEventsUninitialized();
      }
    }
  }
}
