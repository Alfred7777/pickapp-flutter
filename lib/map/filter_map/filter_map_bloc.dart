import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/event_repository.dart';

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
      mapBloc.add(
        FilterMap(
          disciplineIDs: event.disciplineIDs,
          filterByDate: event.filterByDate,
          fromDate: event.fromDate,
          toDate: event.toDate,
          visibility: event.visibility,
        ),
      );
    }
    if (event is RevokeFilter) {
      mapBloc.add(FetchMap());
    }
  }
}
