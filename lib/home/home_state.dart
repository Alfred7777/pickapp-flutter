import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/userRepository.dart';

class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class InitialHomeState extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final User details;

  const HomeLoaded({@required this.details});

  @override
  List<Object> get props => [details];
}

class HomeError extends HomeState {}
