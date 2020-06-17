import 'dart:async';
import 'dart:math' as math;
import 'package:PickApp/map/filter_map/filter_map_screen.dart';
import 'package:PickApp/widgets/event_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'add_event_menu.dart';
import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_event.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:PickApp/widgets/bottom_navbar.dart';
import 'package:PickApp/widgets/nav_drawer/nav_drawer.dart';
import 'package:PickApp/create_event/create_event_page.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  static final eventRepository = EventRepository();

  final Completer<GoogleMapController> _controller = Completer();

  AnimationController _animationController;

  MapBloc _mapBloc;

  static final CameraPosition _kPoznan =
      CameraPosition(target: LatLng(52.4064, 16.9252), zoom: 13);

  List<AddEventMenuButton> menu;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                    icon: Icon(Icons.menu),
                    iconSize: 34.0,
                    color: Color(0xFF000000),
                    onPressed: () {
                      _scaffoldKey.currentState.openDrawer();
                    }),
                centerTitle: true,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.search, color: Color(0xFF000000), size: 32.0),
                    ButtonTheme(
                        minWidth: 170,
                        height: 28,
                        child: FlatButton(
                          onPressed: () {},
                          color: Color(0x55C4C4C4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: null,
                        ))
                  ],
                ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    iconSize: 34.0,
                    color: Color(0xFF000000),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return FilterMapScreen(mapBloc: _mapBloc);
                        },
                      );
                    },
                  )
                ],
              ),
              drawer: NavDrawer(),
              extendBodyBehindAppBar: true,
              body: GoogleMap(
                mapType: MapType.normal,
                markers: mapLocationsToMarkers(state, context),
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                initialCameraPosition: _kPoznan,
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
              floatingActionButton: AnimatedOpacity(
                opacity: 1,
                duration: Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: _buildMenu(context),
              ),
              bottomNavigationBar: bottomNavbar(0),
            );
          }
          return CircularProgressIndicator();
        });
  }

  Set<Marker> mapLocationsToMarkers(state, context) {
    return state.locations
        .map<Marker>((location) => Marker(
              markerId: MarkerId(location.id),
              position: LatLng(location.lat, location.lon),
              icon: state.icons[location.disciplineId],
              onTap: () {
                eventRepository.getEventDetails(location.id).then((details) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return EventDetails(eventDetails: details);
                    },
                  );
                });
              },
            ))
        .toSet();
  }

  void _buildAddEventMenu() {
    menu = [
      AddEventMenuButton(
          action: () => null,
          icon: Icons.business,
          label: 'Event',
          color: Colors.orange),
      AddEventMenuButton(
          action: () async {
            final eventRepository = EventRepository();
            final result = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => CreateEventPage(
                      eventRepository: eventRepository,
                    )));
            if (result != null) {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                    content: Text('$result'), backgroundColor: Colors.green),
              );
            }
          },
          icon: Icons.room,
          label: 'Event',
          color: Colors.purple),
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
