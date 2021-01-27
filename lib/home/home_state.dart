import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeReady extends HomeState {
  final int index;
  final int unreadNotificationsCount;

  const HomeReady({
    @required this.index,
    @required this.unreadNotificationsCount,
  });

  @override
  List<Object> get props => [index, unreadNotificationsCount];
}

class HomeFailure extends HomeState {}
