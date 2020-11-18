import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class CreateEventEvent extends Equatable {
  const CreateEventEvent();

  @override
  List<Object> get props => [];
}

class CreateEventButtonPressed extends CreateEventEvent {
  final String eventName;
  final String eventDescription;
  final String eventDisciplineID;
  final LatLng eventPos;
  final DateTime eventStartDate;
  final DateTime eventEndDate;
  final bool allowInvitations;
  final bool requireParticipationAcceptation;

  const CreateEventButtonPressed({
    @required this.eventName,
    @required this.eventDescription,
    @required this.eventDisciplineID,
    @required this.eventPos,
    @required this.eventStartDate,
    @required this.eventEndDate,
    @required this.allowInvitations,
    @required this.requireParticipationAcceptation,
  });

  @override
  List<Object> get props => [
        eventName,
        eventDescription,
        eventDisciplineID,
        eventPos,
        eventStartDate,
        eventEndDate,
        allowInvitations,
        requireParticipationAcceptation,
      ];
}
