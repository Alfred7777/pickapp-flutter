import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'create_location_event.dart';
import 'create_location_state.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/location_repository.dart';

class CreateLocationBloc
    extends Bloc<CreateLocationEvent, CreateLocationState> {
  final EventRepository eventRepository;
  final LocationRepository locationRepository;

  CreateLocationBloc({
    @required this.eventRepository,
    @required this.locationRepository,
  });

  @override
  CreateLocationState get initialState => CreateLocationInitial();

  @override
  Stream<CreateLocationState> mapEventToState(
      CreateLocationEvent event) async* {
    if (event is FetchDisciplines) {
      try {
        yield CreateLocationLoading();

        var _disciplines = await eventRepository.getDisciplines();

        yield CreateLocationReady(
          disciplines: _disciplines,
          pickedPos: null,
        );
      } catch (exception) {
        yield FetchDisciplinesFailure(error: exception.message);
      }
    }
    if (event is LocationPicked) {
      yield CreateLocationLoading();

      yield CreateLocationReady(
        disciplines: event.disciplines,
        pickedPos: event.pickedPos,
      );
    }
    if (event is CreateLocationButtonPressed) {
      var response = await locationRepository.createLocation(
        name: event.locationName,
        description: event.locationDescription,
        disciplineIDs: event.locationDisciplineIDs,
        pos: event.locationPos,
      );
      if (response == 'Location created') {
        yield CreateLocationCreated(
          pos: event.locationPos,
          message: response,
        );
      } else {
        yield CreateLocationFailure(
          disciplines: event.disciplines,
          pickedPos: event.locationPos,
          error: response,
        );
      }
      yield CreateLocationReady(
        disciplines: event.disciplines,
        pickedPos: event.locationPos,
      );
    }
  }
}
