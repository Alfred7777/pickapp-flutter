import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class FilterMapEvent extends Equatable {
  const FilterMapEvent();

  @override
  List<Object> get props => [];
}

class FetchDisciplines extends FilterMapEvent {}

class ApplyFilter extends FilterMapEvent {
  final String disciplineId;

  const ApplyFilter({@required this.disciplineId});

  @override
  List<Object> get props => [disciplineId];
}

class RevokeFilter extends FilterMapEvent {}