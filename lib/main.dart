import 'package:PickApp/home/home_screen.dart';
import 'package:PickApp/push_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:PickApp/authentication/authentication_bloc.dart';
import 'package:PickApp/authentication/authentication_state.dart';
import 'package:PickApp/authentication/authentication_event.dart';
import 'package:PickApp/login/login_screen.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  final userRepository = UserRepository();

  runApp(BlocProvider<AuthenticationBloc>(
    create: (context) {
      return AuthenticationBloc()..add(AppStarted());
    },
    child: MyApp(userRepository: userRepository),
  ));
}

class MyApp extends StatefulWidget {
  final UserRepository userRepository;

  MyApp({Key key, @required this.userRepository}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState(userRepository: userRepository);
}

class _MyAppState extends State<MyApp> {
  final UserRepository userRepository;

  _MyAppState({@required this.userRepository});

  @override
  void initState() {
    super.initState();
    PushNotifications.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.green,
        ),
        title: 'PickApp',
        navigatorKey: navigatorKey,
        home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            if (state is AuthenticationUninitialized) {
              return LoadingScreen();
            } else if (state is AuthenticationAuthenticated) {
              return HomeScreen();
            } else if (state is AuthenticationUnauthenticated) {
              return LoginScreen(userRepository: userRepository);
            } else {
              return LoadingScreen();
            }
          },
        ),
      ),
    );
  }
}
