import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/map_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import '../mocks.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  var _mapRepositoryMock = MockMapRepository();

  var _eventMarker = EventMarker(
    id: 'id',
    position: LatLng(30.50, 60.50),
    disciplineID: 'disciplineId',
  );

  var _anotherEventMarker = EventMarker(
    id: 'id',
    position: LatLng(40.50, 75.50),
    disciplineID: 'anotherDisciplineId',
  );

  var fetchMapError =
      'We can\'t show you events map right now. Please try again later.';

  group('MapBloc', () {
    blocTest(
      'emits nothing when nothing is added',
      build: () async => MapBloc(mapRepository: MapRepository()),
      expect: [],
    );

    blocTest(
      'starts with MapUninitialized state',
      build: () async => MapBloc(mapRepository: _mapRepositoryMock),
      expect: [],
      verify: (bloc) async {
        expect(
          bloc.state,
          equals(MapUninitialized()),
        );
      },
    );

    blocTest(
      'emits [Map Loading, MapReady] when FetchLocations is succesful',
      build: () async {
        when(_mapRepositoryMock.getEventMap())
            .thenAnswer((_) async => [_eventMarker]);
        return MapBloc(mapRepository: _mapRepositoryMock);
      },
      act: (bloc) => bloc.add(FetchLocations()),
      expect: [
        isA<MapLoading>(),
        isA<MapReady>(),
      ],
      verify: (bloc) async {
        verify(
          _mapRepositoryMock.getEventMap(),
        ).called(1);
        // expect(
        //   bloc.state,
        //   equals(
        //     MapReady(
        //       eventMarkers: [_eventMarker],
        //       eventFluster: bloc.initEventFluster([_eventMarker]),
        //     ),
        //   ),
        // );
      },
    );

    blocTest(
      'emits [Map Loading, FetchMapFailure] when FetchLocations is unsuccesful',
      build: () async {
        when(_mapRepositoryMock.getEventMap()).thenThrow(
          Exception(fetchMapError),
        );
        return MapBloc(mapRepository: _mapRepositoryMock);
      },
      act: (bloc) => bloc.add(FetchLocations()),
      expect: [
        isA<MapLoading>(),
        isA<FetchMapFailure>(),
      ],
      verify: (bloc) async {
        verify(
          _mapRepositoryMock.getEventMap(),
        ).called(1);
        expect(
          bloc.state,
          equals(
            FetchMapFailure(
              error: fetchMapError,
            ),
          ),
        );
      },
    );

    blocTest(
      'emits [Map Loading, MapReady] when FilterMapByDiscipline is added with correctly filtered locations',
      build: () async {
        when(_mapRepositoryMock.getEventMap('anotherDisciplineId'))
            .thenAnswer((_) async => [_anotherEventMarker]);
        return MapBloc(mapRepository: _mapRepositoryMock);
      },
      act: (bloc) => bloc.add(
        FilterMapByDiscipline(disciplineId: 'anotherDisciplineId'),
      ),
      expect: [
        isA<MapLoading>(),
        isA<MapReady>(),
      ],
      verify: (bloc) async {
        verify(
          _mapRepositoryMock.getEventMap('anotherDisciplineId'),
        ).called(1);
        // expect(
        //   bloc.state,
        //   equals(
        //     MapReady(
        //       eventMarkers: [_anotherEventMarker],
        //       eventFluster: bloc.initEventFluster([_anotherEventMarker]),
        //     ),
        //   ),
        // );
      },
    );

    blocTest(
      'emits [Map Loading, FetchMapFailure] when FilterMapByDiscipline is unsuccesful',
      build: () async {
        when(_mapRepositoryMock.getEventMap('anotherDisciplineId')).thenThrow(
          Exception(fetchMapError),
        );
        return MapBloc(mapRepository: _mapRepositoryMock);
      },
      act: (bloc) => bloc.add(
        FilterMapByDiscipline(disciplineId: 'anotherDisciplineId'),
      ),
      expect: [
        isA<MapLoading>(),
        isA<FetchMapFailure>(),
      ],
      verify: (bloc) async {
        verify(
          _mapRepositoryMock.getEventMap('anotherDisciplineId'),
        ).called(1);
        expect(
          bloc.state,
          equals(
            FetchMapFailure(
              error: fetchMapError,
            ),
          ),
        );
      },
    );
  });
}
