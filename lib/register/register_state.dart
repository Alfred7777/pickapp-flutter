import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final String message;

  const RegisterSuccess({@required this.message});

  @override
  List<Object> get props => [message];
}

class RegisterFailure extends RegisterState {
  final String error;

  const RegisterFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
