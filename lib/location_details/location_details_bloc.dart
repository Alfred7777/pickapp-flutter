import 'package:PickApp/repositories/location_repository.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'location_details_event.dart';
import 'location_details_state.dart';

class LocationDetailsBloc
    extends Bloc<LocationDetailsEvent, LocationDetailsState> {
  final LocationRepository locationRepository;
  final String locationID;

  LocationDetailsBloc({
    @required this.locationRepository,
    @required this.locationID,
  });

  @override
  LocationDetailsState get initialState =>
      LocationDetailsUninitialized(locationID: locationID);

  @override
  Stream<LocationDetailsState> mapEventToState(
      LocationDetailsEvent event) async* {
    if (event is FetchLocationDetails) {
      try {
        var _locationDetails = await locationRepository.getLocationDetails(
          event.locationID,
        );
        var _eventList = await locationRepository.getEventList(
          event.locationID,
        );

        yield LocationDetailsReady(
          locationID: event.locationID,
          locationDetails: _locationDetails,
          eventList: _eventList,
        );
      } catch (exception) {
        print(exception.toString());
        yield LocationDetailsFailure(error: exception.message);
      }
    }
    if (event is LocationDetailsFetchFailure) {
      yield LocationDetailsUninitialized(locationID: event.locationID);
    }
  }
}
