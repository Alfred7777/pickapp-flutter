import 'package:PickApp/profile/profile_bloc.dart';
import 'package:PickApp/profile/profile_event.dart';
import 'package:PickApp/profile/profile_state.dart';
import 'package:PickApp/repositories/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks.dart';

void main() {
  var _userRepositoryMock = MockUserRepository();
  var _userId = 'de9ac1c2-37e8-4244-9bc5-a6026c0ab717';

  group('ProfileBloc', () {
    blocTest(
      'emits nothing when nothing is added',
      build: () async => ProfileBloc(
        userRepository: UserRepository(),
        userID: null,
      ),
      expect: [],
    );

    blocTest(
      'starts with InitialProfileState',
      build: () async => ProfileBloc(
        userRepository: _userRepositoryMock,
        userID: null,
      ),
      expect: [],
      verify: (bloc) async {
        expect(bloc.state, equals(ProfileUninitialized()));
      },
    );

    blocTest(
      'emits ProfileLoaded after FetchProfile is called',
      build: () async => ProfileBloc(
        userRepository: _userRepositoryMock,
        userID: null,
      ),
      act: (bloc) => bloc.add(FetchProfile(userID: _userId)),
      verify: (bloc) async {
        expect(
          bloc.state,
          equals(
            ProfileReady(
              details: null,
              stats: null,
              pictureUploadUrl: null,
            ),
          ),
        );
      },
    );
  });
}
