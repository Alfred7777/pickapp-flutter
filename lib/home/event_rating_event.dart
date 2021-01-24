import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/user_repository.dart';

class EventRatingEvent extends Equatable {
  const EventRatingEvent();

  @override
  List<Object> get props => [];
}

class ConnectToEventRatingSocket extends EventRatingEvent {}

class ShowEventRating extends EventRatingEvent {
  final List<User> participants;
  final Event event;

  const ShowEventRating({
    @required this.participants,
    @required this.event,
  });

  @override
  List<Object> get props => [participants, event];
}

class UserRatingChanged extends EventRatingEvent {
  final Map<User, bool> usersRating;
  final List<User> participants;
  final Event event;

  const UserRatingChanged({
    @required this.usersRating,
    @required this.participants,
    @required this.event,
  });

  @override
  List<Object> get props => [
        usersRating,
        participants,
        event,
      ];
}

class SubmitUserRating extends EventRatingEvent {
  final Map<User, bool> usersRating;
  final Event event;

  const SubmitUserRating({
    @required this.usersRating,
    @required this.event,
  });

  @override
  List<Object> get props => [usersRating, event];
}
