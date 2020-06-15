import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../mocks.dart';

void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();
  var _eventRepositoryMock = MockEventRepository();
  var _location =
      Location(id: 'id', lat: 100.50, lon: 100.50, disciplineID: 'discipline');
  var _discipline = 
      Discipline('b5c6e905-6b06-4c92-8c4f-5abc8dd44bfa', 'Basketball');

  when(_eventRepositoryMock.getMap())
      .thenAnswer((_) => Future.value({_location}));
  when(_eventRepositoryMock.getDisciplines())
      .thenAnswer((_) => Future.value([_discipline]));

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
        verify(_eventRepositoryMock.getDisciplines()).called(1);
        expect(bloc.state, equals(MapReady(locations: {_location}, icons:{})));
      },
    );
  });
}
