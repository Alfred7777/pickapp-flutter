import 'package:PickApp/profile/profile_event.dart';
import 'package:PickApp/profile/profile_state.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository;

  ProfileBloc({@required this.userRepository}) : assert(userRepository != null);

  @override
  ProfileState get initialState => InitialProfileState();

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    if (event is FetchProfile) {
      yield ProfileLoading();
      var details = await userRepository.getProfileDetails(event.userID);
      yield ProfileLoaded(details: details);
      return;
    }
  }
}
