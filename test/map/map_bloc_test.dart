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

  var _locationMarker = MapMarker(
    id: 'id1',
    position: LatLng(52.50, 61.50),
    disciplineID: null,
  );

  var _eventMarker = MapMarker(
    id: 'id2',
    position: LatLng(30.50, 60.50),
    disciplineID: 'disciplineId',
  );

  var _anotherEventMarker = MapMarker(
    id: 'id3',
    position: LatLng(40.50, 75.50),
    disciplineID: 'anotherDisciplineId',
  );

  var fetchEventMapError =
      'We can\'t show you events map right now. Please try again later.';

  var fetchLocationMapError =
      'We can\'t show you locations map right now. Please try again later.';

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
      'emits [Map Loading, MapReady] when FetchMap is succesful',
      build: () async {
        when(_mapRepositoryMock.getEventMap())
            .thenAnswer((_) async => [_eventMarker]);
        when(_mapRepositoryMock.getLocationMap())
            .thenAnswer((_) async => [_locationMarker]);
        return MapBloc(mapRepository: _mapRepositoryMock);
      },
      act: (bloc) => bloc.add(FetchMap()),
      expect: [
        isA<MapLoading>(),
        isA<MapReady>(),
      ],
      verify: (bloc) async {
        verify(
          _mapRepositoryMock.getEventMap(),
        ).called(1);
        verify(
          _mapRepositoryMock.getLocationMap(),
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
      'emits [Map Loading, FetchMapFailure] when getEventMap is unsuccesful',
      build: () async {
        when(_mapRepositoryMock.getEventMap()).thenThrow(
          Exception(fetchEventMapError),
        );
        return MapBloc(mapRepository: _mapRepositoryMock);
      },
      act: (bloc) => bloc.add(FetchMap()),
      expect: [
        isA<MapLoading>(),
        isA<FetchMapFailure>(),
      ],
      verify: (bloc) async {
        verify(
          _mapRepositoryMock.getEventMap(),
        ).called(1);
        verifyNever(
          _mapRepositoryMock.getLocationMap(),
        );
        expect(
          bloc.state,
          equals(
            FetchMapFailure(
              error: fetchEventMapError,
            ),
          ),
        );
      },
    );

    blocTest(
      'emits [Map Loading, FetchMapFailure] when getLocationMap is unsuccesful',
      build: () async {
        when(_mapRepositoryMock.getEventMap())
            .thenAnswer((_) async => [_eventMarker]);
        when(_mapRepositoryMock.getLocationMap()).thenThrow(
          Exception(fetchLocationMapError),
        );
        return MapBloc(mapRepository: _mapRepositoryMock);
      },
      act: (bloc) => bloc.add(FetchMap()),
      expect: [
        isA<MapLoading>(),
        isA<FetchMapFailure>(),
      ],
      verify: (bloc) async {
        verify(
          _mapRepositoryMock.getEventMap(),
        ).called(1);
        verify(
          _mapRepositoryMock.getLocationMap(),
        ).called(1);
        expect(
          bloc.state,
          equals(
            FetchMapFailure(
              error: fetchLocationMapError,
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
        when(_mapRepositoryMock.getLocationMap())
            .thenAnswer((_) async => [_locationMarker]);
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
        verify(
          _mapRepositoryMock.getLocationMap(),
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
  });
}
