import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/location_repository.dart';

class LocationDetailsState extends Equatable {
  const LocationDetailsState();

  @override
  List<Object> get props => [];
}

class LocationDetailsUninitialized extends LocationDetailsState {
  final String locationID;

  const LocationDetailsUninitialized({@required this.locationID});
}

class LocationDetailsReady extends LocationDetailsState {
  final String locationID;
  final Location locationDetails;
  final List<Event> eventList;

  const LocationDetailsReady({
    @required this.locationID,
    @required this.locationDetails,
    @required this.eventList,
  });
}

class LocationDetailsFailure extends LocationDetailsState {
  final String error;

  const LocationDetailsFailure({@required this.error});
}
