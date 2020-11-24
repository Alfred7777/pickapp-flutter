import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class BottomNavbarState extends Equatable {
  final int index = 0;

  const BottomNavbarState();

  @override
  List<Object> get props => [index];
}

class InitialBottomNavbarState extends BottomNavbarState {
  final int initialCount = 0;

  const InitialBottomNavbarState();

  @override
  List<Object> get props => [initialCount];
}

class BottomNavbarLoaded extends BottomNavbarState {
  @override
  final int index;

  final int currentUnreadNotificationsCount;

  const BottomNavbarLoaded({
    @required this.index,
    @required this.currentUnreadNotificationsCount,
  });

  @override
  List<Object> get props => [index, currentUnreadNotificationsCount];
}
