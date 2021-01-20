import 'package:PickApp/map/filter_map/filter_map_bloc.dart';
import 'package:PickApp/map/filter_map/filter_map_event.dart';
import 'package:PickApp/map/filter_map/filter_map_state.dart';
import 'package:PickApp/map/map_bloc.dart';
import 'package:PickApp/map/map_state.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/widgets/date_picker.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterMapScrollable extends StatefulWidget {
  final MapBloc mapBloc;

  const FilterMapScrollable({@required this.mapBloc});

  @override
  State<FilterMapScrollable> createState() => FilterMapScrollableState();
}

class FilterMapScrollableState extends State<FilterMapScrollable> {
  static final eventRepository = EventRepository();

  FilterMapBloc _filterMapBloc;
  MapBloc _mapBloc;

  List<String> _disciplineIDs;
  bool _filterByDate;
  DateTime _fromDate;
  DateTime _toDate;
  String _visibility;

  GlobalKey<FormState> _dateFormKey;

  @override
  void initState() {
    super.initState();

    _mapBloc = widget.mapBloc;

    _filterMapBloc = FilterMapBloc(
      eventRepository: eventRepository,
      mapBloc: _mapBloc,
    );

    if (_mapBloc.state is MapReady) {
      Map<String, dynamic> _activeFilters = _mapBloc.state.props.last;

      _disciplineIDs = _activeFilters['discipline_ids'];

      _filterByDate = _activeFilters['filter_by_date'];
      _fromDate = _activeFilters['from_date'] ?? DateTime.now();
      _toDate =
          _activeFilters['to_date'] ?? DateTime.now().add(Duration(days: 7));

      _visibility = _activeFilters['visibility'];

      _dateFormKey = GlobalKey<FormState>();
    }
  }

  void _addDiscipline(String disciplineID) {
    _disciplineIDs.add(disciplineID);
  }

  void _removeDiscipline(String disciplineID) {
    _disciplineIDs.remove(disciplineID);
  }

  void _setFilterByDate(bool filterByDate) {
    _filterByDate = filterByDate;
  }

  void _setFromDate(DateTime fromDate) {
    _fromDate = fromDate;
  }

  void _setToDate(DateTime toDate) {
    _toDate = toDate;
  }

  void _setVisibility(String visibility) {
    _visibility = visibility;
  }

  String _validateToDate() {
    if (!_toDate.isAfter(_fromDate)) {
      return 'Second date can\'t be after the first one!';
    }
    return null;
  }

  void _applyFilters() {
    if (_dateFormKey.currentState.validate()) {
      if (_disciplineIDs.isEmpty &&
          !_filterByDate &&
          _visibility == 'events_and_locations') {
        _filterMapBloc.add(RevokeFilter());
      } else {
        _filterMapBloc.add(
          ApplyFilter(
            disciplineIDs: _disciplineIDs,
            filterByDate: _filterByDate,
            fromDate: _filterByDate ? _fromDate : null,
            toDate: _filterByDate ? _toDate : null,
            visibility: _visibility,
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          color: Colors.grey[100],
          child: BlocBuilder<FilterMapBloc, FilterMapState>(
            bloc: _filterMapBloc,
            builder: (context, state) {
              if (state is FilterMapUninitialized) {
                _filterMapBloc.add(FetchDisciplines());
              }
              if (state is FilterMapReady) {
                return FilterList(
                  formKey: _dateFormKey,
                  disciplineList: state.disciplines,
                  initDisciplineIDs: _disciplineIDs,
                  initFilterByDate: _filterByDate,
                  initFromDate: _fromDate,
                  initToDate: _toDate,
                  initVisibility: _visibility,
                  addDiscipline: _addDiscipline,
                  removeDiscipline: _removeDiscipline,
                  setFilterByDate: _setFilterByDate,
                  setFromDate: _setFromDate,
                  setToDate: _setToDate,
                  setVisibility: _setVisibility,
                  validateToDate: _validateToDate,
                  applyFilters: _applyFilters,
                );
              }
              return LoadingScreen();
            },
          ),
        ),
      ),
    );
  }
}

class FilterList extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<Discipline> disciplineList;
  final List<String> initDisciplineIDs;
  final bool initFilterByDate;
  final DateTime initFromDate;
  final DateTime initToDate;
  final String initVisibility;
  final Function addDiscipline;
  final Function removeDiscipline;
  final Function setFilterByDate;
  final Function setFromDate;
  final Function setToDate;
  final Function setVisibility;
  final Function validateToDate;
  final Function applyFilters;

  const FilterList({
    @required this.formKey,
    @required this.disciplineList,
    @required this.initDisciplineIDs,
    @required this.initFilterByDate,
    @required this.initFromDate,
    @required this.initToDate,
    @required this.initVisibility,
    @required this.addDiscipline,
    @required this.removeDiscipline,
    @required this.setFilterByDate,
    @required this.setFromDate,
    @required this.setToDate,
    @required this.setVisibility,
    @required this.validateToDate,
    @required this.applyFilters,
  });

  @override
  State<StatefulWidget> createState() => FilterListState(
        formKey: formKey,
        disciplineList: disciplineList,
        initDisciplineIDs: initDisciplineIDs,
        initFilterByDate: initFilterByDate,
        initFromDate: initFromDate,
        initToDate: initToDate,
        initVisibility: initVisibility,
        addDiscipline: addDiscipline,
        removeDiscipline: removeDiscipline,
        setFilterByDate: setFilterByDate,
        setFromDate: setFromDate,
        setToDate: setToDate,
        setVisibility: setVisibility,
        validateToDate: validateToDate,
        applyFilters: applyFilters,
      );
}

class FilterListState extends State<FilterList> {
  final GlobalKey<FormState> formKey;
  final List<Discipline> disciplineList;
  final List<String> initDisciplineIDs;
  final bool initFilterByDate;
  final DateTime initFromDate;
  final DateTime initToDate;
  final String initVisibility;
  final Function addDiscipline;
  final Function removeDiscipline;
  final Function setFilterByDate;
  final Function setFromDate;
  final Function setToDate;
  final Function setVisibility;
  final Function validateToDate;
  final Function applyFilters;

  FilterListState({
    @required this.formKey,
    @required this.disciplineList,
    @required this.initDisciplineIDs,
    @required this.initFilterByDate,
    @required this.initFromDate,
    @required this.initToDate,
    @required this.initVisibility,
    @required this.addDiscipline,
    @required this.removeDiscipline,
    @required this.setFilterByDate,
    @required this.setFromDate,
    @required this.setToDate,
    @required this.setVisibility,
    @required this.validateToDate,
    @required this.applyFilters,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: 12,
            bottom: 4,
          ),
          child: Text(
            'Map Filters',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 32,
          ),
          child: VisibilityFilter(
            initVisibility: initVisibility,
            setVisibility: setVisibility,
          ),
        ),
        Text(
          'Date',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 6,
            left: 32,
            right: 32,
          ),
          child: DateFilter(
            formKey: formKey,
            initFilterByDate: initFilterByDate,
            initFromDate: initFromDate,
            initToDate: initToDate,
            setFilterByDate: setFilterByDate,
            setFromDate: setFromDate,
            setToDate: setToDate,
            validateToDate: validateToDate,
          ),
        ),
        Text(
          'Disciplines',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 24,
          ),
          child: DisciplineFilter(
            disciplineList: disciplineList,
            initDisciplineIDs: initDisciplineIDs,
            addDiscipline: addDiscipline,
            removeDiscipline: removeDiscipline,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            bottom: 8,
            left: 32,
            right: 32,
          ),
          child: ApplyFiltersButton(
            applyFilters: applyFilters,
          ),
        ),
      ],
    );
  }
}

class VisibilityFilter extends StatefulWidget {
  final String initVisibility;
  final Function setVisibility;

  const VisibilityFilter({
    @required this.initVisibility,
    @required this.setVisibility,
  });

  @override
  State<StatefulWidget> createState() => VisibilityFilterState(
        initVisibility: initVisibility,
        setVisibility: setVisibility,
      );
}

class VisibilityFilterState extends State<VisibilityFilter> {
  final String initVisibility;
  final Function setVisibility;

  var _visibility;

  VisibilityFilterState({
    @required this.initVisibility,
    @required this.setVisibility,
  });

  @override
  void initState() {
    _visibility = initVisibility;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Visibile markers',
      ),
      value: _visibility,
      items: [
        DropdownMenuItem<String>(
          value: 'events_and_locations',
          child: Text('Events and Locations'),
        ),
        DropdownMenuItem<String>(
          value: 'events',
          child: Text('Events'),
        ),
        DropdownMenuItem<String>(
          value: 'locations',
          child: Text('Locations'),
        ),
      ],
      onChanged: (String newValue) {
        setState(() {
          _visibility = newValue;
          setVisibility(newValue);
        });
      },
    );
  }
}

class DateFilter extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final bool initFilterByDate;
  final DateTime initFromDate;
  final DateTime initToDate;
  final Function setFilterByDate;
  final Function setFromDate;
  final Function setToDate;
  final Function validateToDate;

  const DateFilter({
    @required this.formKey,
    @required this.initFilterByDate,
    @required this.initFromDate,
    @required this.initToDate,
    @required this.setFilterByDate,
    @required this.setFromDate,
    @required this.setToDate,
    @required this.validateToDate,
  });

  @override
  State<StatefulWidget> createState() => DateFilterState(
        formKey: formKey,
        initFilterByDate: initFilterByDate,
        initFromDate: initFromDate,
        initToDate: initToDate,
        setFilterByDate: setFilterByDate,
        setFromDate: setFromDate,
        setToDate: setToDate,
        validateToDate: validateToDate,
      );
}

class DateFilterState extends State<DateFilter> {
  final GlobalKey<FormState> formKey;
  final bool initFilterByDate;
  final DateTime initFromDate;
  final DateTime initToDate;
  final Function setFilterByDate;
  final Function setFromDate;
  final Function setToDate;
  final Function validateToDate;

  bool _filterByDate;

  DateFilterState({
    @required this.formKey,
    @required this.initFilterByDate,
    @required this.initFromDate,
    @required this.initToDate,
    @required this.setFilterByDate,
    @required this.setFromDate,
    @required this.setToDate,
    @required this.validateToDate,
  });

  @override
  void initState() {
    super.initState();
    _filterByDate = initFilterByDate;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Row(
            children: [
              Switch(
                value: _filterByDate,
                onChanged: (value) {
                  setState(() {
                    _filterByDate = value;
                    setFilterByDate(value);
                  });
                },
              ),
              Text(
                'Apply date filters',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          TextFieldDateTimePicker(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            labelText: 'Events from',
            firstDate: DateTime(DateTime.now().year - 10),
            lastDate: DateTime(DateTime.now().year + 10),
            initialDate: initFromDate,
            enabled: _filterByDate,
            onDateChanged: (DateTime date) {
              setFromDate(date);
            },
          ),
          SizedBox(height: 12.0),
          TextFieldDateTimePicker(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            labelText: 'Events to',
            firstDate: DateTime(DateTime.now().year - 10),
            lastDate: DateTime(DateTime.now().year + 10),
            initialDate: initToDate,
            enabled: _filterByDate,
            onDateChanged: (DateTime date) {
              setToDate(date);
            },
            validator: (value) {
              return validateToDate();
            },
          ),
        ],
      ),
    );
  }
}

class DisciplineFilter extends StatefulWidget {
  final List<Discipline> disciplineList;
  final List<String> initDisciplineIDs;
  final Function addDiscipline;
  final Function removeDiscipline;

  const DisciplineFilter({
    @required this.disciplineList,
    @required this.initDisciplineIDs,
    @required this.addDiscipline,
    @required this.removeDiscipline,
  });

  @override
  State<StatefulWidget> createState() => DisciplineFilterState(
        disciplineList: disciplineList,
        initDisciplineIDs: initDisciplineIDs,
        addDiscipline: addDiscipline,
        removeDiscipline: removeDiscipline,
      );
}

class DisciplineFilterState extends State<DisciplineFilter> {
  final List<Discipline> disciplineList;
  final List<String> initDisciplineIDs;
  final Function addDiscipline;
  final Function removeDiscipline;

  DisciplineFilterState({
    @required this.disciplineList,
    @required this.initDisciplineIDs,
    @required this.addDiscipline,
    @required this.removeDiscipline,
  });

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildDisciplineList() {
    var _disciplineWidgets = <Widget>[];
    widget.disciplineList.forEach((item) {
      _disciplineWidgets.add(Container(
        padding: EdgeInsets.all(4),
        child: ChoiceChip(
          label: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage(
                    'assets/images/icons/event/${item.id}.png',
                  ),
                ),
              ),
            ),
          ),
          selected: initDisciplineIDs.contains(item.id),
          onSelected: (selected) {
            if (selected) {
              setState(() {
                addDiscipline(item.id);
              });
            } else {
              setState(() {
                removeDiscipline(item.id);
              });
            }
          },
        ),
      ));
    });
    return _disciplineWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: _buildDisciplineList(),
    );
  }
}

class ApplyFiltersButton extends StatelessWidget {
  final Function applyFilters;

  const ApplyFiltersButton({
    @required this.applyFilters,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: applyFilters,
      height: 40,
      minWidth: 160,
      color: Colors.green,
      child: Text(
        'APPLY FILTERS',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
