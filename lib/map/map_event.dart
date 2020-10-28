import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class FetchLocations extends MapEvent {}

class FilterMapByDiscipline extends MapEvent {
  final String disciplineId;

  const FilterMapByDiscipline({@required this.disciplineId});

  @override
  List<Object> get props => [disciplineId];
}
