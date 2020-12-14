import 'dart:math' as math;
import 'package:PickApp/event_details/event_details_scrollable.dart';
import 'package:PickApp/main.dart';
import 'package:PickApp/repositories/mapRepository.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluster/fluster.dart';
import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:PickApp/create_event/create_event_screen.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  static final mapRepository = MapRepository();
  static final eventRepository = EventRepository();

  GoogleMapController _mapController;
  AnimationController _menuAnimationController;
  MapBloc _mapBloc;

  List<AddEventMenuButton> menu;

  static final CameraPosition _kPoznan = CameraPosition(
    target: LatLng(52.4064, 16.9252),
    zoom: 12,
  );

  Set<Marker> _markers;

  @override
  void initState() {
    super.initState();

    menu = [
      AddEventMenuButton(
        action: () => _navigateToCreateLocation(),
        icon: Icons.location_city,
        color: Colors.purple,
      ),
      AddEventMenuButton(
        action: () => _navigateToCreateEvent(),
        icon: Icons.place,
        color: Colors.blueAccent,
      ),
    ];

    _menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _mapBloc = MapBloc(mapRepository: mapRepository);
  }

  @override
  void dispose() {
    _menuAnimationController.dispose();
    _mapBloc.close();
    super.dispose();
  }

  void _navigateToCreateEvent() async {
    var mapBounds = await _mapController.getVisibleRegion();
    var initialCameraZoom = await _mapController.getZoomLevel();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateEventScreen(
          initialCameraPos: CameraPosition(
            target: LatLng(
              (mapBounds.northeast.latitude + mapBounds.southwest.latitude) / 2,
              (mapBounds.northeast.longitude + mapBounds.southwest.longitude) /
                  2,
            ),
            zoom: initialCameraZoom,
          ),
        ),
      ),
    );
    if (result != null) {
      _mapBloc.add(FetchLocations());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('${result[0]}'),
          backgroundColor: Colors.green,
        ),
      );
      await _mapController.moveCamera(
        CameraUpdate.newLatLngZoom(result[1], 16),
      );
    }
  }

  void _navigateToCreateLocation() async {}

  void _showEventDetails(String eventID) async {
    await showDialog(
      context: navigatorKey.currentContext,
      builder: (BuildContext context) {
        var screenSize = MediaQuery.of(context).size;
        return Padding(
          padding: EdgeInsets.only(
            top: 0.12 * screenSize.height,
            bottom: 0.02 * screenSize.height,
            left: 0.02 * screenSize.width,
            right: 0.02 * screenSize.width,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32.0),
            child: Material(
              color: Color(0xFFF3F3F3),
              child: EventDetailsScrollable(eventID: eventID),
            ),
          ),
        );
      },
    );
  }

  void _zoomCluster(int clusterID) async {
    Fluster<EventMarker> _fluster = _mapBloc.state.props.last;
    var _clusterLocations = _fluster.points(clusterID);
    double x0, x1, y0, y1;

    for (var location in _clusterLocations) {
      var latLng = location.position;
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }

    var clusterBounds = LatLngBounds(
      northeast: LatLng(x1, y1),
      southwest: LatLng(x0, y0),
    );
    await _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(clusterBounds, 60.0),
    );
  }

  Future<Set<Marker>> getMapMarkers(int currentZoom) async {
    Fluster<EventMarker> _fluster = _mapBloc.state.props.last;
    var markerSet = <Marker>{};
    var futureMarkerSet = _fluster
        .clusters([-180, -85, 180, 85], currentZoom)
        .map((cluster) => cluster.toMarker(
              _zoomCluster,
              _showEventDetails,
            ))
        .toSet();
    for (var marker in futureMarkerSet) {
      markerSet.add(await marker);
    }
    return markerSet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mapScreenTopBar(context, _mapBloc),
      extendBodyBehindAppBar: true,
      body: BlocListener<MapBloc, MapState>(
        bloc: _mapBloc,
        listener: (context, state) {
          if (state is FetchMapFailure) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is MapReady) {
            getMapMarkers(16).then((markers) {
              setState(() {
                _markers = markers;
              });
            });
          }
        },
        child: BlocBuilder<MapBloc, MapState>(
          bloc: _mapBloc,
          condition: (prevState, currState) {
            if (currState is MapLoading) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is MapUninitialized) {
              _mapBloc.add(FetchLocations());
            }
            if (state is MapReady) {
              return GoogleMap(
                compassEnabled: false,
                initialCameraPosition: _kPoznan,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: _markers,
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  getMapMarkers(12).then((markers) {
                    setState(() {
                      _markers = markers;
                    });
                  });
                },
                onCameraMove: (position) {
                  getMapMarkers(position.zoom.round()).then((markers) {
                    setState(() {
                      _markers = markers;
                    });
                  });
                },
              );
            }
            return LoadingScreen();
          },
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: 1,
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: AddMenu(
          menuButtons: menu,
          animationController: _menuAnimationController,
        ),
      ),
    );
  }
}

class AddEventMenuButton {
  final IconData icon;
  final VoidCallback action;
  final Color color;

  const AddEventMenuButton({
    @required this.icon,
    @required this.action,
    @required this.color,
  });
}

class FloatingMenuButton extends StatelessWidget {
  final AnimationController animationController;

  const FloatingMenuButton({
    @required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: null,
      backgroundColor: Colors.green,
      child: AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return Transform(
            transform: Matrix4.rotationZ(
              animationController.value * 0.5 * math.pi,
            ),
            alignment: FractionalOffset.center,
            child: Icon(
              animationController.isDismissed ? Icons.add : Icons.close,
            ),
          );
        },
      ),
      onPressed: () {
        if (animationController.isDismissed) {
          animationController.forward();
        } else {
          animationController.reverse();
        }
      },
    );
  }
}

class AddMenu extends StatelessWidget {
  final AnimationController animationController;
  final List<AddEventMenuButton> menuButtons;

  const AddMenu({
    @required this.animationController,
    @required this.menuButtons,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(menuButtons.length + 1, (int index) {
        if (index == menuButtons.length) {
          return FloatingMenuButton(
            animationController: animationController,
          );
        }
        return AddMenuItem(
          eventMenuButton: menuButtons[index],
          animationController: animationController,
        );
      }),
    );
  }
}

class AddMenuItem extends StatelessWidget {
  final AddEventMenuButton eventMenuButton;
  final AnimationController animationController;

  const AddMenuItem({
    @required this.eventMenuButton,
    @required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: animationController,
          curve: Curves.fastOutSlowIn,
        ),
        child: FloatingActionButton(
          heroTag: null,
          backgroundColor: eventMenuButton.color,
          mini: false,
          child: Icon(
            eventMenuButton.icon,
            color: Colors.white,
          ),
          onPressed: () {
            eventMenuButton.action();
            animationController.reverse();
          },
        ),
      ),
    );
  }
}
