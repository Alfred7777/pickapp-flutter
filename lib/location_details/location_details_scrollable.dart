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

class LocationDetailsScrollable extends StatefulWidget {
  final String locationID;

  LocationDetailsScrollable({@required this.locationID});

  @override
  State<LocationDetailsScrollable> createState() =>
      LocationDetailsScrollableState(locationID: locationID);
}

class LocationDetailsScrollableState extends State<LocationDetailsScrollable> {
  final String locationID;
  final locationRepository = LocationRepository();
  LocationDetailsBloc _locationDetailsBloc;

  LocationDetailsScrollableState({@required this.locationID});

  @override
  void initState() {
    super.initState();
    _locationDetailsBloc = LocationDetailsBloc(
      locationRepository: locationRepository,
      locationID: locationID,
    );
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

  const LocationDetails({
    @required this.locationDetails,
    @required this.eventList,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverMapHeader(
            minExtent: 0.16 * screenSize.height,
            maxExtent: 0.3 * screenSize.height,
            markerPos: locationDetails.position,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 0.02 * screenSize.height,
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
                  Padding(
                    padding: EdgeInsets.all(0.008 * screenSize.height),
                    child: Divider(
                      color: Colors.grey[400],
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
                  Padding(
                    padding: EdgeInsets.all(0.008 * screenSize.height),
                    child: Divider(
                      color: Colors.grey[400],
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 0.06 * screenSize.width,
                        bottom: 0.01 * screenSize.height,
                      ),
                      child: Text(
                        'Events',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  EventList(
                    eventList: eventList,
                  ),
                  SizedBox(
                    height: 0.01 * screenSize.height,
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
