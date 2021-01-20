import 'dart:math' as math;
import 'package:PickApp/utils/marker_clusters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/map_repository.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/create_event/map/create_event_map_screen.dart';
import 'package:PickApp/create_location/create_location_screen.dart';

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
    zoom: 14,
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
        builder: (context) => CreateEventMapScreen(
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
      _mapBloc.add(FetchMap());
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

  void _navigateToCreateLocation() async {
    var mapBounds = await _mapController.getVisibleRegion();
    var initialCameraZoom = await _mapController.getZoomLevel();
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateLocationScreen(
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
      _mapBloc.add(FetchMap());
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

  void _updateMarkers() async {
    if (_mapBloc.state is MapReady && _mapController != null) {
      var _mapBounds = await _mapController.getVisibleRegion();
      var _currentZoom = await _mapController.getZoomLevel();
      var _extendedBounds = MarkerClusters.extendBounds(_mapBounds);

      var _clusters = await MarkerClusters.getMarkers(
        _mapController,
        _mapBloc.state.props[1],
        _extendedBounds,
        _currentZoom,
        true,
      );

      setState(() {
        _markers = _clusters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MapScreenTopBar(
        mapBloc: _mapBloc,
      ),
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
            _updateMarkers();
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
              _mapBloc.add(FetchMap());
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
                  _updateMarkers();
                },
                onCameraIdle: _updateMarkers,
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
      elevation: 2,
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
