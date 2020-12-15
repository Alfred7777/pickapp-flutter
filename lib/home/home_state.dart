import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:PickApp/repositories/user_repository.dart';

class HomeState extends Equatable {
  final User details;

  const HomeState({@required this.details});

  @override
  List<Object> get props => [];
}

class InitialHomeState extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  @override
  final User details;

  final int index;

  const HomeLoaded({@required this.details, this.index});

  @override
  List<Object> get props => [details, index];
}

class HomeError extends HomeState {}
