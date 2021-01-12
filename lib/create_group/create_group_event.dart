import 'package:PickApp/repositories/event_repository.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class CreateGroupEvent extends Equatable {
  const CreateGroupEvent();

  @override
  List<Object> get props => [];
}

class FetchDisciplines extends CreateGroupEvent {}

class CreateGroupButtonPressed extends CreateGroupEvent {
  final List<Discipline> disciplines;

  final String groupName;
  final String groupDescription;
  final String groupDisciplineID;

  const CreateGroupButtonPressed({
    @required this.disciplines,
    @required this.groupName,
    @required this.groupDescription,
    @required this.groupDisciplineID,
  });

  @override
  List<Object> get props => [
        disciplines,
        groupName,
        groupDescription,
        groupDisciplineID,
      ];
}
