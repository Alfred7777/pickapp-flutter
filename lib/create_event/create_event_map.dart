import 'package:PickApp/repositories/eventRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'create_event_bloc.dart';
import 'create_event_state.dart';
import 'create_event_event.dart';

class CreateEventMap extends StatefulWidget {
  final CameraUpdate initialCameraPos;

  CreateEventMap({@required this.initialCameraPos});

  @override
  State<CreateEventMap> createState() =>
      _CreateEventMapState(initialCameraPos: initialCameraPos);
}

class _CreateEventMapState extends State<CreateEventMap> {
  final CameraUpdate initialCameraPos;

  _CreateEventMapState({@required this.initialCameraPos});

  final EventRepository eventRepository = EventRepository();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String disciplineID;
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  LatLng eventPos;
  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var _markers = <Marker>{};
    List<Discipline> disciplineList;

    void _onCreateEventButtonPressed(CreateEventState state) {
      BlocProvider.of<CreateEventBloc>(context).add(CreateEventButtonPressed(
        eventName: _nameController.text,
        eventDescription: _descriptionController.text,
        eventDisciplineID: disciplineID,
        eventPos: eventPos,
        eventStartDate: startDate,
        eventEndDate: endDate,
      ));
      Navigator.pop(context);
    }

    void _onChooseLocationButtonPressed(CreateEventState state) {
      if (_markers.isEmpty) {
        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text('Pick event location!'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        eventPos = _markers.first.position;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                top: 0.12 * screenSize.height,
                bottom: 0.02 * screenSize.height,
                left: 0.01 * screenSize.height,
                right: 0.01 * screenSize.height,
              ),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0)),
                ),
                color: Color(0xFFF3F3F3),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    Future<Null> _selectStartDate(BuildContext context) async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: DateTime(DateTime.now().year - 5),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (picked != null && picked != startDate) {
                        setState(() {
                          if (picked.isBefore(startDate)) {
                            var difference =
                                picked.difference(startDate).inDays;
                            startDate = startDate.add(
                              Duration(days: difference),
                            );
                          } else {
                            var difference =
                                picked.difference(startDate).inDays + 1;
                            startDate = startDate.add(
                              Duration(days: difference),
                            );
                          }
                        });
                      }
                    }

                    Future<Null> _selectEndDate(BuildContext context) async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: DateTime(DateTime.now().year - 5),
                        lastDate: DateTime(DateTime.now().year + 5),
                      );
                      if (picked != null && picked != endDate) {
                        setState(() {
                          if (picked.isBefore(endDate)) {
                            var difference = picked.difference(endDate).inDays;
                            endDate = endDate.add(Duration(days: difference));
                          } else {
                            var difference =
                                picked.difference(endDate).inDays + 1;
                            endDate = endDate.add(Duration(days: difference));
                          }
                        });
                      }
                    }

                    Future<Null> _selectStartTime(BuildContext context) async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(startDate),
                      );
                      if (picked != null) {
                        setState(() {
                          startDate = DateTime(
                            startDate.year,
                            startDate.month,
                            startDate.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    }

                    Future<Null> _selectEndTime(BuildContext context) async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(endDate),
                      );
                      if (picked != null) {
                        setState(() {
                          endDate = DateTime(
                            endDate.year,
                            endDate.month,
                            endDate.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    }

                    return Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0 * screenSize.height,
                            ),
                            child: Text(
                              'Event name',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.01 * screenSize.height,
                            ),
                            child: SizedBox(
                              height: 30.0,
                              width: 0.80 * screenSize.width,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                    top: 12.0,
                                    left: 14.0,
                                    right: 10.0,
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                controller: _nameController,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.01 * screenSize.height,
                            ),
                            child: Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.01 * screenSize.height,
                            ),
                            child: SizedBox(
                              height: 0.14 * screenSize.height,
                              width: 0.80 * screenSize.width,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: EdgeInsets.only(
                                    top: 14.0,
                                    left: 10.0,
                                    right: 4.0,
                                  ),
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                minLines: 30,
                                controller: _descriptionController,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.01 * screenSize.height,
                            ),
                            child: Text(
                              'Discipline',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.01 * screenSize.height,
                              left: 0.1 * screenSize.width,
                              right: 0.1 * screenSize.width,
                            ),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: disciplineID,
                              hint: Text(
                                'Select discipline',
                                style: TextStyle(
                                  color: Color(0x883D3A3A),
                                  fontSize: 16,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              onChanged: (String newValue) {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  disciplineID = newValue;
                                });
                              },
                              items: disciplineList.map((discipline) {
                                return DropdownMenuItem<String>(
                                  value: discipline.id,
                                  child: Text(discipline.name),
                                );
                              }).toList(),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.01 * screenSize.height,
                            ),
                            child: Text(
                              'Start date',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.01 * screenSize.height,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                RaisedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    _selectStartDate(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      0.006 * screenSize.height,
                                    ),
                                    child: Icon(
                                      Icons.event,
                                      size: 0.045 * screenSize.height,
                                      color: Colors.black,
                                    ),
                                  ),
                                  shape: CircleBorder(),
                                  color: Colors.white,
                                ),
                                Text(
                                  DateFormat.yMd().format(startDate),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    _selectStartTime(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      0.006 * screenSize.height,
                                    ),
                                    child: Icon(
                                      Icons.schedule,
                                      size: 0.045 * screenSize.height,
                                      color: Colors.black,
                                    ),
                                  ),
                                  shape: CircleBorder(),
                                  color: Colors.white,
                                ),
                                Text(
                                  DateFormat.jm().format(startDate),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.01 * screenSize.height,
                            ),
                            child: Text(
                              'End date',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.01 * screenSize.height,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                RaisedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    _selectEndDate(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                        0.006 * screenSize.height),
                                    child: Icon(
                                      Icons.event,
                                      size: 0.045 * screenSize.height,
                                      color: Colors.black,
                                    ),
                                  ),
                                  shape: CircleBorder(),
                                  color: Colors.white,
                                ),
                                Text(
                                  DateFormat.yMd().format(endDate),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    FocusScope.of(context).unfocus();
                                    _selectEndTime(context);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      0.006 * screenSize.height,
                                    ),
                                    child: Icon(
                                      Icons.schedule,
                                      size: 0.045 * screenSize.height,
                                      color: Colors.black,
                                    ),
                                  ),
                                  shape: CircleBorder(),
                                  color: Colors.white,
                                ),
                                Text(
                                  DateFormat.jm().format(endDate),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              top: 0.02 * screenSize.height,
                            ),
                            child: ButtonTheme(
                              height: 40,
                              minWidth: 0.44 * screenSize.width,
                              child: FlatButton(
                                onPressed: () =>
                                    _onCreateEventButtonPressed(state),
                                color: Color(0xFF5EC374),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Text(
                                  'CREATE',
                                  style: TextStyle(
                                    color: Color(0xFFFFFFFF),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      }
    }

    return BlocListener<CreateEventBloc, CreateEventState>(
      listener: (context, state) {
        if (state is CreateEventFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('${state.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is CreateEventCreated) {
          Navigator.pop(context, ['Event created', eventPos]);
        }
      },
      child: BlocBuilder<CreateEventBloc, CreateEventState>(
        builder: (context, state) {
          eventRepository.getDisciplines().then((list) {
            disciplineList = list;
          });
          return Stack(
            overflow: Overflow.visible,
            children: [
              StatefulBuilder(builder: (context, setState) {
                return GoogleMap(
                    markers: _markers,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(52.4064, 16.9252), zoom: 14),
                    mapType: MapType.normal,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                      mapController.moveCamera(initialCameraPos);
                    },
                    onTap: (LatLng point) {
                      setState(() {
                        _markers.clear();
                        _markers.add(Marker(
                          markerId: MarkerId('pickedPos'),
                          position: point,
                        ));
                      });
                    });
              }),
              Positioned.fill(
                bottom: 0.05 * screenSize.height,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ButtonTheme(
                    height: 40,
                    child: RaisedButton(
                      onPressed: () => _onChooseLocationButtonPressed(state),
                      color: Color(0xFF5EC374),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Text(
                        'CREATE EVENT',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 0.15 * screenSize.height,
                    width: screenSize.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF5EC374),
                            Color(0xFF5EC374),
                            Color(0x005EC374)
                          ]),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        'Tap on map to choose location',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
