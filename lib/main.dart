import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:PickApp/authentication/authentication_bloc.dart';
import 'package:PickApp/authentication/authentication_state.dart';
import 'package:PickApp/authentication/authentication_event.dart';
import 'package:PickApp/login/login_page.dart';
import 'package:PickApp/repositories/userRepository.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/map/map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final userRepository = UserRepository();
  runApp(
    BlocProvider<AuthenticationBloc>(
        create: (context) {
          return AuthenticationBloc(userRepository: userRepository)
            ..add(AppStarted());
        },
        child: MyApp(userRepository: userRepository)),
  );
}

class MyApp extends StatelessWidget {
  final UserRepository userRepository;

  MyApp({Key key, @required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        title: 'PickApp',
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
          if (state is AuthenticationUninitialized) {
            return LoadingScreen();
          } else if (state is AuthenticationAuthenticated) {
            return MapSample();
          } else if (state is AuthenticationUnauthenticated) {
            return LoginPage(userRepository: userRepository);
          } else {
            return LoadingScreen();
          }
        }));
  }
}
