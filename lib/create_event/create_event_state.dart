import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

class CreateEventState extends Equatable {
  const CreateEventState();

  @override
  List<Object> get props => [];
}

class CreateEventInitial extends CreateEventState {}

class CreateEventLoading extends CreateEventState {}

class CreateEventCreated extends CreateEventState {
  final String message;

  const CreateEventCreated({@required this.message});

  @override
  List<Object> get props => [message];
}

class CreateEventFailure extends CreateEventState {
  final String error;

  const CreateEventFailure({@required this.error});

  @override
  List<Object> get props => [error];
}