import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/notificationRepository.dart';

class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object> get props => [];
}

class NotificationsUninitialized extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsReady extends NotificationsState {
  final String nextToken;
  final List<Notification> notifications;

  const NotificationsReady({
    @required this.nextToken,
    @required this.notifications,
  });

  @override
  List<Object> get props => [nextToken, notifications];
}

class FetchNotificationsFailure extends NotificationsState {
  final String error;

  const FetchNotificationsFailure({@required this.error});

  @override
  List<Object> get props => [error];
}
