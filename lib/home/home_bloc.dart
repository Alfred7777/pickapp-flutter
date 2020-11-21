import 'home_event.dart';
import 'home_state.dart';
import 'package:PickApp/repositories/userRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository userRepository;

  HomeBloc({@required this.userRepository}) : assert(userRepository != null);

  @override
  HomeState get initialState => InitialHomeState();

  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is FetchProfile) {
      yield HomeLoading();
      var details = await userRepository.getProfileDetails(event.userID);
      yield HomeLoaded(details: details, index: 0);
      return;
    }
    if (event is NavbarSelectedIndexChanged) {
      var details = state.details;
      yield HomeLoaded(index: event.index, details: details);
    }
  }
}
