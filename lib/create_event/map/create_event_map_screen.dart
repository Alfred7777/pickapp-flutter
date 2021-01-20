import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'create_event_map_bloc.dart';
import 'create_event_map_state.dart';
import 'create_event_map_event.dart';
import 'package:PickApp/utils/marker_clusters.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/repositories/map_repository.dart';
import 'package:PickApp/create_event/form/create_event_form_screen.dart';

class CreateEventMapScreen extends StatefulWidget {
  final CameraPosition initialCameraPos;

  CreateEventMapScreen({@required this.initialCameraPos});

  @override
  State<CreateEventMapScreen> createState() =>
      CreateEventMapScreenState(initialCameraPos: initialCameraPos);
}

class CreateEventMapScreenState extends State<CreateEventMapScreen> {
  final CameraPosition initialCameraPos;
  final mapRepository = MapRepository();
  CreateEventMapBloc _createEventMapBloc;

  GoogleMapController _mapController;
  Set<Marker> _markers;
  Marker _pickedPos;

  CreateEventMapScreenState({
    @required this.initialCameraPos,
  });

  @override
  void initState() {
    super.initState();
    _createEventMapBloc = CreateEventMapBloc(
      mapRepository: mapRepository,
    );
  }

  @override
  void dispose() {
    _createEventMapBloc.close();
    super.dispose();
  }

  void _createEvent() async {
    var route = MaterialPageRoute(
      builder: (context) => CreateEventFormScreen(
        pickedPos: _pickedPos.position,
        location: null,
      ),
    );
    var _result = await Navigator.push(context, route);
    if (_result != null) {
      _createEventMapBloc.add(EventCreated(
        message: _result[0],
        position: _result[1],
      ));
    }
  }

  void _pickLocation(LatLng pos) {
    setState(() {
      _pickedPos = Marker(
        markerId: MarkerId('pickedPos'),
        position: pos,
      );
    });
    _updateMarkers();
  }

  void _updateMarkers() async {
    if (_createEventMapBloc.state is CreateEventMapReady &&
        _mapController != null) {
      var _mapBounds = await _mapController.getVisibleRegion();
      var _currentZoom = await _mapController.getZoomLevel();
      var _extendedBounds = MarkerClusters.extendBounds(_mapBounds);

      var _clusters = await MarkerClusters.getMarkers(
        _mapController,
        _createEventMapBloc.state.props.last,
        _extendedBounds,
        _currentZoom,
        false,
      );

      if (_pickedPos != null) {
        _clusters.add(_pickedPos);
      }

      setState(() {
        _markers = _clusters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CreateEventMapBloc, CreateEventMapState>(
        bloc: _createEventMapBloc,
        listener: (context, state) {
          if (state is FetchLocationsFailure) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CreateEventMapCreated) {
            Navigator.pop(context, [state.message, state.position]);
          }
        },
        child: BlocBuilder<CreateEventMapBloc, CreateEventMapState>(
          bloc: _createEventMapBloc,
          condition: (prevState, currState) {
            if (currState is CreateEventMapLoading) {
              return false;
            }
            if (currState is FetchLocationsFailure) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is CreateEventMapInitial) {
              _createEventMapBloc.add(FetchLocations());
            }
            if (state is CreateEventMapReady) {
              return Stack(
                alignment: Alignment.center,
                overflow: Overflow.visible,
                children: [
                  GoogleMap(
                    initialCameraPosition: initialCameraPos,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      _updateMarkers();
                    },
                    onCameraIdle: _updateMarkers,
                    onTap: (LatLng point) {
                      _pickLocation(point);
                    },
                  ),
                  CreateEventButton(
                    pickedPos: _pickedPos,
                    createEvent: _createEvent,
                  ),
                  CreateEventOverlay(),
                ],
              );
            }
            return LoadingScreen();
          },
        ),
      ),
    );
  }
}

class CreateEventButton extends StatelessWidget {
  final Marker pickedPos;
  final Function createEvent;

  const CreateEventButton({
    @required this.pickedPos,
    @required this.createEvent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Positioned(
      bottom: 0.064 * screenSize.height,
      child: MaterialButton(
        onPressed: () {
          if (pickedPos == null) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('Pick event location!'),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            createEvent();
          }
        },
        height: 40,
        minWidth: 160,
        color: Colors.green,
        child: Text(
          'CREATE EVENT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class CreateEventOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 104,
          width: screenSize.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green,
                Colors.green,
                Colors.green,
                Colors.green.withAlpha(200),
                Colors.green.withAlpha(0),
              ],
            ),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8,
              ),
              child: Text(
                'Tap on map to choose event place or choose one of the available locations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
