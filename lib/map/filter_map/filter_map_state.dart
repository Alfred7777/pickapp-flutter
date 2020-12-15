import 'package:PickApp/repositories/event_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class FilterMapState extends Equatable {
  const FilterMapState();

  @override
  List<Object> get props => [];
}

class FilterMapUninitialized extends FilterMapState {}

class FilterMapReady extends FilterMapState {
  final List<Discipline> disciplines;

  const FilterMapReady({@required this.disciplines});

  @override
  List<Object> get props => [disciplines];
}
