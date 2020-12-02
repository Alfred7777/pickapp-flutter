import 'package:PickApp/map/filter_map/filter_map_bloc.dart';
import 'package:PickApp/map/filter_map/filter_map_event.dart';
import 'package:PickApp/map/filter_map/filter_map_state.dart';
import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterMapScreen extends StatefulWidget {
  final MapBloc mapBloc;

  const FilterMapScreen({@required this.mapBloc});

  @override
  State<FilterMapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<FilterMapScreen> {
  static final eventRepository = EventRepository();

  FilterMapBloc _filterMapBloc;

  String _dropdownCurrentDisciplineId;

  @override
  void initState() {
    super.initState();

    var _mapBloc = widget.mapBloc;

    _filterMapBloc = FilterMapBloc(
      eventRepository: eventRepository,
      mapBloc: _mapBloc,
    );
  }

  void _onButtonPress() {
    if (_dropdownCurrentDisciplineId == null) {
      _filterMapBloc.add(RevokeFilter());
    } else {
      _filterMapBloc.add(
        ApplyFilter(disciplineId: _dropdownCurrentDisciplineId),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return BlocBuilder<FilterMapBloc, FilterMapState>(
      bloc: _filterMapBloc,
      builder: (context, state) {
        if (state is FilterMapUninitialized) {
          _filterMapBloc.add(FetchDisciplines());
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is FilterMapReady) {
          var disciplines = state.disciplines;

          return Padding(
            padding: EdgeInsets.only(
              top: 0.1 * screenSize.height,
              bottom: 0.02 * screenSize.height,
              left: 0.01 * screenSize.height,
              right: 0.01 * screenSize.height,
            ),
            child: Align(
              child: Container(
                height: 200,
                width: 400,
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                  ),
                  color: Color(0xFFF3F3F3),
                  elevation: 10.0,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Form(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                top: 0.00001 * screenSize.height,
                                bottom: 0.01 * screenSize.height,
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
                            Align(
                              child: Container(
                                height: 50,
                                width: 150,
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _dropdownCurrentDisciplineId,
                                  hint: Text(
                                    'Discipline',
                                    style: TextStyle(
                                      color: Color(0x883D3A3A),
                                      fontSize: 16,
                                    ),
                                  ),
                                  onChanged: (String newValue) {
                                    setState(() {
                                      _dropdownCurrentDisciplineId = newValue;
                                    });
                                  },
                                  items: [
                                        DropdownMenuItem<String>(
                                          child: Text('None'),
                                          value: null,
                                        ),
                                      ] +
                                      disciplines.map(
                                        (discipline) {
                                          return DropdownMenuItem<String>(
                                            key: Key(discipline.id),
                                            value: discipline.id,
                                            child: Text(
                                              discipline.name,
                                            ),
                                          );
                                        },
                                      ).toList(),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 0.05 * screenSize.height,
                              ),
                              child: ButtonTheme(
                                height: 40,
                                minWidth: 0.44 * screenSize.width,
                                child: FlatButton(
                                  onPressed: () => _onButtonPress(),
                                  color: Color(0xFF5EC374),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Text(
                                    'FILTER',
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
              ),
            ),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
