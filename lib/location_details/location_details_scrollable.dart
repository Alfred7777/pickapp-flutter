import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/location_repository.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/sliver_map_header.dart';
import 'package:PickApp/widgets/list_bar/event_bar.dart';
import 'location_details_event.dart';
import 'location_details_state.dart';
import 'location_details_bloc.dart';
import 'package:PickApp/create_event/form/create_event_form_screen.dart';

class LocationDetailsScrollable extends StatefulWidget {
  final String locationID;
  final bool showEvents;

  LocationDetailsScrollable({
    @required this.locationID,
    @required this.showEvents,
  });

  @override
  State<LocationDetailsScrollable> createState() =>
      LocationDetailsScrollableState(
        locationID: locationID,
        showEvents: showEvents,
      );
}

class LocationDetailsScrollableState extends State<LocationDetailsScrollable> {
  final String locationID;
  final bool showEvents;
  final locationRepository = LocationRepository();
  LocationDetailsBloc _locationDetailsBloc;

  LocationDetailsScrollableState({
    @required this.locationID,
    @required this.showEvents,
  });

  @override
  void initState() {
    super.initState();
    _locationDetailsBloc = LocationDetailsBloc(
      locationRepository: locationRepository,
      locationID: locationID,
    );
  }

  void _createEvent() async {
    if (_locationDetailsBloc.state is LocationDetailsReady) {
      var route = MaterialPageRoute(
        builder: (context) => CreateEventFormScreen(
          pickedPos: null,
          location: _locationDetailsBloc.state.props[1],
        ),
      );
      var _result = await Navigator.push(context, route);
      if (showEvents) {
        _locationDetailsBloc.add(FetchLocationDetails(locationID: locationID));
      } else {
        Navigator.pop(context);
        Navigator.pop(context, [_result[0], _result[1]]);
      }
    }
  }

  Widget _buildFailureAlert(BuildContext context, String errorMessage) {
    return AlertDialog(
      title: Text('An Error Occured!'),
      content: Text(errorMessage),
      actions: [
        FlatButton(
          child: Text('Try Again'),
          onPressed: () {
            Navigator.of(context).pop();
            _locationDetailsBloc.add(
              LocationDetailsFetchFailure(
                locationID: locationID,
              ),
            );
          },
        ),
        FlatButton(
          child: Text('Go Back'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _locationDetailsBloc,
      listener: (context, state) {
        if (state is LocationDetailsFailure) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return _buildFailureAlert(context, state.error);
            },
          );
        }
      },
      child: BlocBuilder<LocationDetailsBloc, LocationDetailsState>(
        bloc: _locationDetailsBloc,
        builder: (context, state) {
          if (state is LocationDetailsUninitialized) {
            _locationDetailsBloc.add(
              FetchLocationDetails(
                locationID: locationID,
              ),
            );
          }
          if (state is LocationDetailsReady) {
            return LocationDetails(
              locationDetails: state.locationDetails,
              eventList: state.eventList,
              showEvents: showEvents,
              createEvent: _createEvent,
            );
          }
          return LoadingScreen();
        },
      ),
    );
  }
}

class LocationDetails extends StatelessWidget {
  final Location locationDetails;
  final List<Event> eventList;
  final bool showEvents;
  final Function createEvent;

  const LocationDetails({
    @required this.locationDetails,
    @required this.eventList,
    @required this.showEvents,
    @required this.createEvent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverMapHeader(
            minExtent: 0.14 * screenSize.height,
            maxExtent: 0.28 * screenSize.height,
            markerPos: locationDetails.position,
            privacyBadge: null,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: 4,
                    ),
                    child: Text(
                      locationDetails.name,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 0.06 * screenSize.width),
                      child: Text(
                        'About',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 0.06 * screenSize.width,
                        right: 0.06 * screenSize.width,
                        top: 0.005 * screenSize.height,
                      ),
                      child: Text(
                        locationDetails.description ?? '',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  showEvents
                      ? Padding(
                          padding: EdgeInsets.all(0.008 * screenSize.height),
                          child: Divider(
                            color: Colors.grey[400],
                          ),
                        )
                      : Container(),
                  Row(
                    mainAxisAlignment: showEvents
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      showEvents
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 0.06 * screenSize.width,
                              ),
                              child: Text(
                                'Events',
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Container(),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 0.06 * screenSize.width,
                        ),
                        child: CreateEventButton(
                          createEvent: createEvent,
                          buttonDesign: showEvents,
                        ),
                      ),
                    ],
                  ),
                  showEvents
                      ? EventList(
                          eventList: eventList,
                        )
                      : Container(),
                  SizedBox(
                    height: 0.02 * screenSize.height,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EventList extends StatelessWidget {
  final List<Event> eventList;

  const EventList({
    @required this.eventList,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    if (eventList.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemCount: eventList.length,
        itemBuilder: (BuildContext context, int index) {
          return EventBar(
            event: eventList[index],
          );
        },
      );
    } else {
      return Container(
        width: screenSize.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 0.02 * screenSize.width,
                right: 0.02 * screenSize.width,
                top: 0.04 * screenSize.width,
                bottom: 0.05 * screenSize.width,
              ),
              child: Text(
                'There is no upcoming events in this location.',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }
  }
}

class CreateEventButton extends StatelessWidget {
  final Function createEvent;
  final bool buttonDesign;

  const CreateEventButton({
    @required this.createEvent,
    @required this.buttonDesign,
  });

  @override
  Widget build(BuildContext context) {
    if (buttonDesign) {
      return MaterialButton(
        padding: EdgeInsets.only(right: 4),
        onPressed: createEvent,
        height: 26,
        color: Colors.green,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
            ),
            Text(
              'Create',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: MaterialButton(
          onPressed: createEvent,
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
}
