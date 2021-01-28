import 'package:PickApp/repositories/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  @override
  RegisterState get initialState => RegisterInitial();

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is CreateAccountButtonPressed) {
      yield RegisterLoading();
      try {
        var response = await AuthenticationRepository.registerWithEmail(
          event.email,
          event.password,
        );
        yield RegisterSuccess(
          message: response,
        );
      } catch (exception) {
        yield RegisterFailure(
          error: 'Email was already used.',
        );
      }
    }
  }
}
