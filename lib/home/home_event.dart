import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:phoenix_wings/phoenix_wings.dart';

class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class IndexChanged extends HomeEvent {
  final int newIndex;
  final int unreadNotificationsCount;

  const IndexChanged({
    @required this.newIndex,
    @required this.unreadNotificationsCount,
  });

  @override
  List<Object> get props => [newIndex, unreadNotificationsCount];
}

class ConnectNotificationsSocket extends HomeEvent {
  final PhoenixMessageCallback handleNewNotificationsCount;

  const ConnectNotificationsSocket({
    @required this.handleNewNotificationsCount,
  });

  @override
  List<Object> get props => [handleNewNotificationsCount];
}

class UpdateUnreadNotificationsCount extends HomeEvent {
  final int index;
  final int newUnreadNotificationsCount;

  const UpdateUnreadNotificationsCount({
    @required this.index,
    @required this.newUnreadNotificationsCount,
  });

  @override
  List<Object> get props => [index, newUnreadNotificationsCount];
}
