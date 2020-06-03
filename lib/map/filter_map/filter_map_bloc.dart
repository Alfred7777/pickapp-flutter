import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/eventRepository.dart';

import 'filter_map_event.dart';
import 'filter_map_state.dart';

class FilterMapBloc extends Bloc<FilterMapEvent, FilterMapState> {
  final EventRepository eventRepository;
  final MapBloc mapBloc;

  FilterMapBloc({
    @required this.eventRepository,
    @required this.mapBloc,
  }) : assert(eventRepository != null);

  @override
  FilterMapState get initialState => FilterMapUninitialized();

  @override
  Stream<FilterMapState> mapEventToState(FilterMapEvent event) async* {
    if (event is FetchDisciplines) {
      var disciplines = await eventRepository.getDisciplines();

      yield FilterMapReady(disciplines: disciplines);
      return;
    }
    if (event is ApplyFilter) {
      mapBloc.add(FilterMapByDiscipline(disciplineId: event.disciplineId));
    }
    if (event is RevokeFilter) {
      mapBloc.add(FetchLocations());
    }
  }
}
