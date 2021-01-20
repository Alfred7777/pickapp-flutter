import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class FetchMap extends MapEvent {}

class FilterMap extends MapEvent {
  final List<String> disciplineIDs;
  final bool filterByDate;
  final DateTime fromDate;
  final DateTime toDate;
  final String visibility;

  const FilterMap({
    @required this.disciplineIDs,
    @required this.filterByDate,
    @required this.fromDate,
    @required this.toDate,
    @required this.visibility,
  });

  @override
  List<Object> get props => [
        disciplineIDs,
        filterByDate,
        fromDate,
        toDate,
        visibility,
      ];
}
