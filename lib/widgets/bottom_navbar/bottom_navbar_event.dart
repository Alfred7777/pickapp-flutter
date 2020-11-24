import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class BottomNavbarEvent extends Equatable {
  const BottomNavbarEvent();

  @override
  List<Object> get props => [];
}

class InitializeBottomNavbar extends BottomNavbarEvent {}

class NotificationsCountUpdated extends BottomNavbarEvent {
  final int newUnreadNotificationsCount;

  const NotificationsCountUpdated({@required this.newUnreadNotificationsCount});

  @override
  List<Object> get props => [newUnreadNotificationsCount];
}

class IndexChanged extends BottomNavbarEvent {
  final int index;
  final int currentUnreadNotificationsCount;

  const IndexChanged({
    @required this.index,
    @required this.currentUnreadNotificationsCount,
  });

  @override
  List<Object> get props => [index, currentUnreadNotificationsCount];
}
