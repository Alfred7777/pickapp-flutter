import 'package:PickApp/repositories/event_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class CreateGroupState extends Equatable {
  const CreateGroupState();

  @override
  List<Object> get props => [];
}

class CreateGroupInitial extends CreateGroupState {}

class CreateGroupLoading extends CreateGroupState {}

class CreateGroupReady extends CreateGroupState {
  final List<Discipline> disciplines;

  const CreateGroupReady({
    @required this.disciplines,
  });

  @override
  List<Object> get props => [disciplines];
}

class CreateGroupCreated extends CreateGroupState {
  final String message;

  const CreateGroupCreated({
    @required this.message,
  });

  @override
  List<Object> get props => [message];
}

class CreateGroupFailure extends CreateGroupState {
  final List<Discipline> disciplines;
  final String error;

  const CreateGroupFailure({
    @required this.disciplines,
    @required this.error,
  });

  @override
  List<Object> get props => [disciplines, error];
}

class FetchDisciplinesFailure extends CreateGroupState {
  final String error;

  const FetchDisciplinesFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
