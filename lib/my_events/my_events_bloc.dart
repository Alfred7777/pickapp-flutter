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
      var _myEvents = await eventRepository.getMyEvents();

      yield MyEventsReady(myEvents: _myEvents);
    }
  }
}
