import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'create_event_map_event.dart';
import 'create_event_map_state.dart';
import 'package:PickApp/repositories/map_repository.dart';
import 'package:PickApp/utils/marker_clusters.dart';

class CreateEventMapBloc
    extends Bloc<CreateEventMapEvent, CreateEventMapState> {
  final MapRepository mapRepository;

  CreateEventMapBloc({@required this.mapRepository});

  @override
  CreateEventMapState get initialState => CreateEventMapInitial();

  @override
  Stream<CreateEventMapState> mapEventToState(
      CreateEventMapEvent event) async* {
    if (event is FetchLocations) {
      try {
        yield CreateEventMapLoading();

        var _locations = await mapRepository.getMap();
        var _locationFluster = MarkerClusters.initFluster(_locations);

        yield CreateEventMapReady(
          locations: _locations,
          locationFluster: _locationFluster,
        );
      } catch (exception) {
        yield FetchLocationsFailure(error: exception.message);
      }
    }
    if (event is EventCreated) {
      yield CreateEventMapCreated(
        message: event.message,
        position: event.position,
      );
    }
  }

  @override
  void onTransition(
      Transition<CreateEventMapEvent, CreateEventMapState> transition) {
    print(transition);
    super.onTransition(transition);
  }
}
