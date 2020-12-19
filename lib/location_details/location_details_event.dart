import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class LocationDetailsEvent extends Equatable {
  const LocationDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchLocationDetails extends LocationDetailsEvent {
  final String locationID;

  FetchLocationDetails({@required this.locationID});

  @override
  List<Object> get props => [locationID];
}

class LocationDetailsFetchFailure extends LocationDetailsEvent {
  final String locationID;

  LocationDetailsFetchFailure({@required this.locationID});

  @override
  List<Object> get props => [locationID];
}
