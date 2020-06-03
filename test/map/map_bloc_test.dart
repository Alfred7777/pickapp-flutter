import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  var _eventRepositoryMock = MockEventRepository();

  var _discipline =
      Discipline('b5c6e905-6b06-4c92-8c4f-5abc8dd44bfa', 'Basketball');

  var _location = Location(
    id: 'id',
    lat: 100.50,
    lon: 100.50,
    disciplineId: 'disciplineId',
  );

  var _anotherLocation = Location(
    id: 'id',
    lat: 100.50,
    lon: 100.50,
    disciplineId: 'anotherDisciplineId',
  );

  when(_eventRepositoryMock.getMap())
      .thenAnswer((_) => Future.value({_location}));

  when(_eventRepositoryMock.getDisciplines())
      .thenAnswer((_) => Future.value([_discipline]));

  when(_eventRepositoryMock.filterMapByDiscipline('anotherDisciplineId'))
      .thenAnswer((_) => Future.value({_anotherLocation}));

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
          expect(
            bloc.state,
            equals(MapUninitialized()),
          );
        });

    blocTest(
      'emits MapReady when FetchLocations is added',
      build: () async => MapBloc(eventRepository: _eventRepositoryMock),
      act: (bloc) => bloc.add(FetchLocations()),
      expect: [isA<MapReady>()],
      verify: (bloc) async {
        verify(
          _eventRepositoryMock.getMap(),
        ).called(1);
        expect(
          bloc.state,
          equals(MapReady(locations: {_location}, icons: {})),
        );
      },
    );

    blocTest(
      'emits MapReady when FilterMapByDiscipline is added with correctly filtered locations',
      build: () async => MapBloc(eventRepository: _eventRepositoryMock),
      act: (bloc) =>
          bloc.add(FilterMapByDiscipline(disciplineId: 'anotherDisciplineId')),
      expect: [isA<MapReady>()],
      verify: (bloc) async {
        verify(
          _eventRepositoryMock.filterMapByDiscipline('anotherDisciplineId'),
        ).called(1);
        expect(
          bloc.state,
          equals(MapReady(locations: {_anotherLocation}, icons: {})),
        );
      },
    );
  });
}
