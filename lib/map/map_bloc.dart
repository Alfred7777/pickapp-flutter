import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final EventRepository eventRepository;

  MapBloc({@required this.eventRepository}) : assert(eventRepository != null);

  @override
  MapState get initialState => MapUninitialized();

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is FetchLocations) {
      var locations = await eventRepository.getMap();

      yield MapReady(locations: locations);
      return;
    }
  }
}
