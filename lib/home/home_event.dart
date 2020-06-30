import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchProfile extends HomeEvent {
  final String userID;

  const FetchProfile({@required this.userID});

  @override
  List<Object> get props => [userID];
}