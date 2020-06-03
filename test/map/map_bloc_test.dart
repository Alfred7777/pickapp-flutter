import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart';

void main() {
  var _eventRepositoryMock = MockEventRepository();
  var _location =
      Location(id: 'id', lat: 100.50, lon: 100.50, disciplineId: 'discipline');

  when(_eventRepositoryMock.getMap())
      .thenAnswer((_) => Future.value({_location}));

  group('MapBloc', () {
    blocTest(
      'emits nothing when nothing is added',
      build: () async => MapBloc(eventRepository: EventRepository()),
      expect: [],
    );

    blocTest('starts with MapUninitialized state',
        build: () async => MapBloc(eventRepository: _eventRepositoryMock),
        expect: [],
        verify: (bloc) async {
          expect(bloc.state, equals(MapUninitialized()));
        });

    blocTest(
      'emits MapReady when FetchLocations is added',
      build: () async => MapBloc(eventRepository: _eventRepositoryMock),
      act: (bloc) => bloc.add(FetchLocations()),
      expect: [isA<MapReady>()],
      verify: (bloc) async {
        verify(_eventRepositoryMock.getMap()).called(1);
        expect(bloc.state, equals(MapReady(locations: {_location})));
      },
    );
  });
}
