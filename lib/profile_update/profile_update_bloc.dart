import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'profile_update_event.dart';
import 'profile_update_state.dart';
import 'package:PickApp/repositories/user_repository.dart';

class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  final UserRepository userRepository;
  final String userID;

  ProfileUpdateBloc({
    @required this.userRepository,
    @required this.userID,
  });

  @override
  ProfileUpdateState get initialState => ProfileUpdateUninitialized(
        userID: userID,
      );

  @override
  Stream<ProfileUpdateState> mapEventToState(ProfileUpdateEvent event) async* {
    if (event is FetchInitialDetails) {
      try {
        yield ProfileUpdateLoading();
        var _initialDetails = await userRepository.getProfileDetails(
          userID,
        );

        yield ProfileUpdateReady(
          initialDetails: _initialDetails,
        );
      } catch (exception) {
        yield ProfileUpdateFailure(error: exception.message);
      }
    }
    if (event is UpdateProfileButtonPressed) {
      try {
        var response = await userRepository.updateProfile(
          event.name == event.initialDetails.name ? null : event.name,
          event.bio == event.initialDetails.bio ? null : event.bio,
        );
        yield ProfileUpdateSuccess(message: response);
      } catch (exception) {
        yield ProfileUpdateFailure(error: exception.message);
      }
      yield ProfileUpdateReady(
        initialDetails: event.initialDetails,
      );
    }
  }
}
