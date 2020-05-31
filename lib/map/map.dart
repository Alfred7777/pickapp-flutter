import 'dart:async';
import 'dart:math' as math;
import 'dart:io';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:PickApp/widgets/bottom_navbar.dart';
import 'package:PickApp/widgets/nav_drawer/nav_drawer.dart';
import 'package:PickApp/create_event/create_event_page.dart';
import 'add_event_menu.dart';

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> with TickerProviderStateMixin {
  final eventRepository = EventRepository();

  final Completer<GoogleMapController> _controller = Completer();

  AnimationController _animationController;

  static final CameraPosition _kPoznan =
      CameraPosition(target: LatLng(52.4064, 16.9252), zoom: 13);

  List<AddEventMenuButton> menu;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Set<Marker> markers;

  @override
  void initState() {
    super.initState();
    _buildAddEventMenu();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {});

    eventRepository.getEvents().then((events) {
      setState(() {
        markers = events;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    child: null))
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.filter_list),
            iconSize: 34.0,
            color: Color(0xFF000000),
            onPressed: () {},
          )
        ],
      ),
      drawer: NavDrawer(),
      extendBodyBehindAppBar: true,
      body: GoogleMap(
        mapType: MapType.normal,
        markers: markers,
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

  void _buildAddEventMenu() {
    menu = [
      AddEventMenuButton(
          action: () => _createEvent(),
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
          color: Colors.purple)
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

  void _createEvent() async {
    final marker = Marker(
      markerId: MarkerId('1'),
      position: LatLng(52.46, 16.92),
      infoWindow: InfoWindow(title: '1', snippet: '*'),
    );

    setState(() {
      markers.add(marker);
      stderr.writeln(markers);
    });
  }
}
