import 'dart:async';
import 'dart:math' as math;
import 'package:PickApp/event_details/event_details_scrollable.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'add_event_menu.dart';
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
  static final eventRepository = EventRepository();

  final Completer<GoogleMapController> _mapController = Completer();

  AnimationController _animationController;

  MapBloc _mapBloc;

  static final CameraPosition _kPoznan = CameraPosition(
    target: LatLng(52.4064, 16.9252),
    zoom: 12,
  );

  List<AddEventMenuButton> menu;

  @override
  void initState() {
    super.initState();
    _buildAddEventMenu();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    _mapBloc = MapBloc(eventRepository: eventRepository);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      bloc: _mapBloc,
      builder: (context, state) {
        if (state is MapUninitialized) {
          _mapBloc.add(FetchLocations());

          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is MapReady) {
          return Scaffold(
            appBar: mapScreenTopBar(context, _mapBloc),
            extendBodyBehindAppBar: true,
            body: GoogleMap(
              mapType: MapType.normal,
              markers: mapLocationsToMarkers(state, context),
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _kPoznan,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
              },
            ),
            floatingActionButton: AnimatedOpacity(
              opacity: 1,
              duration: Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: _buildMenu(context),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Set<Marker> mapLocationsToMarkers(state, context) {
    return state.locations.map<Marker>(
      (location) => Marker(
        markerId: MarkerId(location.id),
        position: LatLng(location.lat, location.lon),
        icon: state.icons[location.disciplineID],
        onTap: () {
          eventRepository.getEventDetails(location.id).then(
            (details) {
              showDialog(
                context: context,
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
                        child: EventDetailsScrollable(eventID: location.id),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    ).toSet();
  }

  void _buildAddEventMenu() {
    menu = [
      AddEventMenuButton(
        action: () => null,
        icon: Icons.business,
        label: 'Event',
        color: Colors.orange,
      ),
      AddEventMenuButton(
        action: () async {
          var controller = await _mapController.future;
          var screenSize = MediaQuery.of(context).size;
          var pixelRatio = MediaQuery.of(context).devicePixelRatio;
          var initialCameraPos = await controller.getLatLng(
            ScreenCoordinate(
              x: (screenSize.width * pixelRatio / 2).round(),
              y: (screenSize.height * pixelRatio / 2).round(),
            ),
          );
          var initialCameraZoom = await controller.getZoomLevel();
          final eventRepository = EventRepository();
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateEventScreen(
                eventRepository: eventRepository,
                mapBloc: _mapBloc,
                initialCameraPos: CameraUpdate.newLatLngZoom(
                  initialCameraPos,
                  initialCameraZoom,
                ),
              ),
            ),
          );
          if (result != null) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${result[0]}'),
                backgroundColor: Colors.green,
              ),
            );
            await controller.moveCamera(
              CameraUpdate.newLatLngZoom(result[1], 17),
            );
          }
        },
        icon: Icons.room,
        label: 'Event',
        color: Colors.purple,
      ),
    ];
  }

  Widget _buildMenu(BuildContext context) {
    var foregroundColor = Colors.white;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(menu.length, (int index) {
        Widget child = Container(
          padding: EdgeInsets.only(bottom: 10),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _animationController,
              curve: Curves.fastOutSlowIn,
            ),
            child: FloatingActionButton(
              heroTag: null,
              backgroundColor: menu[index].color,
              mini: false,
              child: Icon(menu[index].icon, color: foregroundColor),
              onPressed: () {
                menu[index].action();
                _animationController.reverse();
              },
            ),
          ),
        );
        return child;
      }).toList()
        ..add(
          FloatingActionButton(
            heroTag: null,
            backgroundColor: Colors.green,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (BuildContext context, Widget child) {
                return Transform(
                  transform: Matrix4.rotationZ(
                      _animationController.value * 0.5 * math.pi),
                  alignment: FractionalOffset.center,
                  child: Icon(_animationController.isDismissed
                      ? Icons.add
                      : Icons.close),
                );
              },
            ),
            onPressed: () {
              if (_animationController.isDismissed) {
                _animationController.forward();
              } else {
                _animationController.reverse();
              }
            },
          ),
        ),
    );
  }
}
