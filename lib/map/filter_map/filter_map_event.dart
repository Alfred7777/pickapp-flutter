import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class FilterMapEvent extends Equatable {
  const FilterMapEvent();

  @override
  List<Object> get props => [];
}

class FetchDisciplines extends FilterMapEvent {}

class ApplyFilter extends FilterMapEvent {
  final List<String> disciplineIDs;
  final bool filterByDate;
  final DateTime fromDate;
  final DateTime toDate;
  final String visibility;

  const ApplyFilter({
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

class RevokeFilter extends FilterMapEvent {}
