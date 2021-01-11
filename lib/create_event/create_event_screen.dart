import 'package:PickApp/main.dart';
import 'package:PickApp/widgets/date_picker.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'create_event_bloc.dart';
import 'create_event_state.dart';
import 'create_event_event.dart';
import 'package:PickApp/repositories/event_repository.dart';

class CreateEventScreen extends StatefulWidget {
  final CameraPosition initialCameraPos;

  CreateEventScreen({@required this.initialCameraPos});

  @override
  State<CreateEventScreen> createState() =>
      CreateEventScreenState(initialCameraPos: initialCameraPos);
}

class CreateEventScreenState extends State<CreateEventScreen> {
  final CameraPosition initialCameraPos;
  final eventRepository = EventRepository();
  CreateEventBloc _createEventBloc;

  TextEditingController _nameController;
  TextEditingController _descriptionController;
  String _disciplineID;
  DateTime _startDate;
  DateTime _endDate;

  List<EventPrivacyRule> _eventPrivacyRules;
  EventPrivacyRule _privacyRule;

  CreateEventScreenState({
    @required this.initialCameraPos,
  });

  @override
  void initState() {
    super.initState();
    _createEventBloc = CreateEventBloc(
      eventRepository: eventRepository,
    );

    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    _startDate = DateTime.now().add(Duration(minutes: 15));
    _endDate = DateTime.now().add(Duration(hours: 2, minutes: 15));

    _eventPrivacyRules = EventPrivacyRule.getEventPrivacyRules();
    _privacyRule = EventPrivacyRule.fromBooleans(true, false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _createEventBloc.close();
    super.dispose();
  }

  void _pickLocation(LatLng pos) {
    _createEventBloc.add(
      LocationPicked(
        disciplines: _createEventBloc.state.props.first,
        pickedPos: pos,
      ),
    );
  }

  void _setDiscipline(String disciplineID) {
    _disciplineID = disciplineID;
  }

  void _setStartDate(DateTime startDate) {
    _startDate = startDate;
  }

  void _setEndDate(DateTime endDate) {
    _endDate = endDate;
  }

  void _setPrivacyRule(EventPrivacyRule privacyRule) {
    _privacyRule = privacyRule;
  }

  String _validateStartDate() {
    if (!_endDate.isAfter(_startDate)) {
      return 'Event can\'t start after the end of it!';
    }
    if (DateTime.now().isAfter(_startDate)) {
      return 'Event can\'t start in the past!';
    }
    return null;
  }

  String _validateEndDate() {
    if (DateTime.now().isAfter(_endDate)) {
      return 'Event can\'t end in the past!';
    }
    return null;
  }

  void _createEvent() {
    _createEventBloc.add(
      CreateEventButtonPressed(
        disciplines: _createEventBloc.state.props.first,
        eventName: _nameController.text,
        eventDescription: _descriptionController.text,
        eventDisciplineID: _disciplineID,
        eventPos: _createEventBloc.state.props.last,
        eventStartDate: _startDate,
        eventEndDate: _endDate,
        allowInvitations: _privacyRule.allowInvitations,
        requireParticipationAcceptation:
            _privacyRule.requireParticipationAcceptation,
      ),
    );
  }

  void _showCreateEventPopup() {
    showDialog(
      context: navigatorKey.currentContext,
      builder: (BuildContext context) {
        return CreateEventPopup(
          nameController: _nameController,
          descriptionController: _descriptionController,
          disciplines: _createEventBloc.state.props.first,
          eventPrivacyRules: _eventPrivacyRules,
          createEvent: _createEvent,
          setDiscipline: _setDiscipline,
          setStartDate: _setStartDate,
          setEndDate: _setEndDate,
          setPrivacyRule: _setPrivacyRule,
          initDisciplineID: _disciplineID,
          initStartDate: _startDate,
          initEndDate: _endDate,
          initPrivacyRule: _privacyRule,
          validateStartDate: _validateStartDate,
          validateEndDate: _validateEndDate,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CreateEventBloc, CreateEventState>(
        bloc: _createEventBloc,
        listener: (context, state) {
          if (state is FetchDisciplinesFailure) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CreateEventFailure) {
            Navigator.pop(context);
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CreateEventCreated) {
            Navigator.pop(context);
            Navigator.pop(context, [state.props.last, state.props.first]);
          }
        },
        child: BlocBuilder<CreateEventBloc, CreateEventState>(
          bloc: _createEventBloc,
          condition: (prevState, currState) {
            if (currState is CreateEventLoading) {
              return false;
            }
            if (currState is CreateEventFailure) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is CreateEventInitial) {
              _createEventBloc.add(FetchDisciplines());
            }
            if (state is CreateEventReady) {
              return CreateEventMap(
                initialCameraPos: initialCameraPos,
                pickedPos: state.pickedPos,
                pickLocation: _pickLocation,
                showCreateEventPopup: _showCreateEventPopup,
              );
            }
            return LoadingScreen();
          },
        ),
      ),
    );
  }
}

class CreateEventMap extends StatelessWidget {
  final CameraPosition initialCameraPos;
  final LatLng pickedPos;
  final Function pickLocation;
  final Function showCreateEventPopup;

  const CreateEventMap({
    @required this.initialCameraPos,
    @required this.pickedPos,
    @required this.pickLocation,
    @required this.showCreateEventPopup,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Stack(
      alignment: Alignment.center,
      overflow: Overflow.visible,
      children: [
        GoogleMap(
          initialCameraPosition: initialCameraPos,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          markers: pickedPos == null
              ? {}
              : {
                  Marker(
                    markerId: MarkerId('pickedPos'),
                    position: pickedPos,
                  )
                },
          onTap: (LatLng point) {
            pickLocation(point);
          },
        ),
        Positioned(
          bottom: 0.064 * screenSize.height,
          child: MaterialButton(
            onPressed: () {
              if (pickedPos == null) {
                Scaffold.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pick event location!'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                showCreateEventPopup();
              }
            },
            height: 0.06 * screenSize.height,
            minWidth: 0.32 * screenSize.width,
            color: Colors.green,
            child: Text(
              'CREATE EVENT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 0.026 * screenSize.height,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                0.02 * screenSize.width,
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
                    Colors.green,
                    Colors.green,
                    Colors.green.withAlpha(0),
                  ],
                ),
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Tap on map to choose location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 0.026 * screenSize.height,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CreateEventPopup extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function createEvent;
  final Function setDiscipline;
  final Function setStartDate;
  final Function setEndDate;
  final Function setPrivacyRule;
  final String initDisciplineID;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final EventPrivacyRule initPrivacyRule;
  final Function validateStartDate;
  final Function validateEndDate;

  CreateEventPopup({
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.eventPrivacyRules,
    @required this.createEvent,
    @required this.setDiscipline,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.setPrivacyRule,
    @required this.initDisciplineID,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.initPrivacyRule,
    @required this.validateStartDate,
    @required this.validateEndDate,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: 0.16 * screenSize.height,
        bottom: 0.03 * screenSize.height,
        left: 0.04 * screenSize.width,
        right: 0.04 * screenSize.width,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0.02 * screenSize.width),
        child: Material(
          child: CreateEventStepper(
            nameController: nameController,
            descriptionController: descriptionController,
            disciplines: disciplines,
            eventPrivacyRules: eventPrivacyRules,
            createEvent: createEvent,
            setDiscipline: setDiscipline,
            setStartDate: setStartDate,
            setEndDate: setEndDate,
            setPrivacyRule: setPrivacyRule,
            initDisciplineID: initDisciplineID,
            initStartDate: initStartDate,
            initEndDate: initEndDate,
            initPrivacyRule: initPrivacyRule,
            validateStartDate: validateStartDate,
            validateEndDate: validateEndDate,
          ),
        ),
      ),
    );
  }
}

class CreateEventStepper extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function createEvent;
  final Function setDiscipline;
  final Function setStartDate;
  final Function setEndDate;
  final Function setPrivacyRule;
  final String initDisciplineID;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final EventPrivacyRule initPrivacyRule;
  final Function validateStartDate;
  final Function validateEndDate;

  CreateEventStepper({
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.eventPrivacyRules,
    @required this.createEvent,
    @required this.setDiscipline,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.setPrivacyRule,
    @required this.initDisciplineID,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.initPrivacyRule,
    @required this.validateStartDate,
    @required this.validateEndDate,
  });

  @override
  State<CreateEventStepper> createState() => CreateEventStepperState(
        nameController: nameController,
        descriptionController: descriptionController,
        disciplines: disciplines,
        eventPrivacyRules: eventPrivacyRules,
        createEvent: createEvent,
        setDiscipline: setDiscipline,
        setStartDate: setStartDate,
        setEndDate: setEndDate,
        setPrivacyRule: setPrivacyRule,
        initDisciplineID: initDisciplineID,
        initStartDate: initStartDate,
        initEndDate: initEndDate,
        initPrivacyRule: initPrivacyRule,
        validateStartDate: validateStartDate,
        validateEndDate: validateEndDate,
      );
}

class CreateEventStepperState extends State<CreateEventStepper> {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function createEvent;
  final Function setDiscipline;
  final Function setStartDate;
  final Function setEndDate;
  final Function setPrivacyRule;
  final String initDisciplineID;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final EventPrivacyRule initPrivacyRule;
  final Function validateStartDate;
  final Function validateEndDate;

  int _currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  CreateEventStepperState({
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.eventPrivacyRules,
    @required this.createEvent,
    @required this.setDiscipline,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.setPrivacyRule,
    @required this.initDisciplineID,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.initPrivacyRule,
    @required this.validateStartDate,
    @required this.validateEndDate,
  });

  StepState _getStepState(int stepNumber, String stepLabel) {
    if (stepNumber < _currentStep) {
      return StepState.complete;
    }
    if (stepNumber == _currentStep) {
      return StepState.editing;
    }
    return StepState.indexed;
  }

  bool _isStepValid(int stepNumber) {
    if (_formKeys[stepNumber].currentState == null) {
      return true;
    } else {
      if (_formKeys[stepNumber].currentState.validate()) {
        return true;
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: _currentStep,
      onStepTapped: (int stepNumber) => setState(() {
        if (_isStepValid(_currentStep)) {
          _currentStep = stepNumber;
        }
      }),
      onStepContinue: () => setState(() {
        if (_isStepValid(_currentStep)) {
          if (_currentStep != 2) {
            _currentStep += 1;
          } else {
            if (!_isStepValid(0)) {
              _currentStep = 0;
            } else if (!_isStepValid(1)) {
              _currentStep = 1;
            } else {
              createEvent();
            }
          }
        }
      }),
      onStepCancel: () => setState(() {
        if (_currentStep != 0) {
          _currentStep -= 1;
        } else {
          Navigator.pop(context);
        }
      }),
      controlsBuilder: (BuildContext context,
          {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
        return Row(
          children: [
            MaterialButton(
              elevation: 0,
              child: Text(
                _currentStep < 2 ? 'Next' : 'Create',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              color: Colors.green,
              textColor: Colors.white,
              onPressed: onStepContinue,
            ),
            SizedBox(width: 4),
            MaterialButton(
              child: Text(
                'Back',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              textColor: Colors.grey[600],
              onPressed: onStepCancel,
            ),
          ],
        );
      },
      steps: [
        Step(
          title: const Text('Information'),
          isActive: true,
          state: _getStepState(0, 'Information'),
          content: InformationStep(
            formKey: _formKeys[0],
            nameController: nameController,
            descriptionController: descriptionController,
            disciplines: disciplines,
            setDiscipline: setDiscipline,
            initDisciplineID: initDisciplineID,
          ),
        ),
        Step(
          title: const Text('Date'),
          isActive: true,
          state: _getStepState(1, 'Date'),
          content: DateStep(
            formKey: _formKeys[1],
            setStartDate: setStartDate,
            setEndDate: setEndDate,
            initStartDate: initStartDate,
            initEndDate: initEndDate,
            validateStartDate: validateStartDate,
            validateEndDate: validateEndDate,
          ),
        ),
        Step(
          title: const Text('Privacy Settings'),
          isActive: true,
          state: _getStepState(2, 'Privacy Settings'),
          content: PrivacySettingsStep(
            formKey: _formKeys[2],
            eventPrivacyRules: eventPrivacyRules,
            setPrivacyRule: setPrivacyRule,
            initPrivacyRule: initPrivacyRule,
          ),
        ),
      ],
    );
  }
}

class InformationStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final Function setDiscipline;
  final String initDisciplineID;

  const InformationStep({
    @required this.formKey,
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.setDiscipline,
    @required this.initDisciplineID,
  });

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    var _disciplineID = initDisciplineID;
    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(height: 2.0),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: nameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
              errorStyle: TextStyle(color: Colors.red),
              labelText: 'Event Name',
            ),
            onEditingComplete: () => node.nextFocus(),
            validator: (value) {
              if (value.isEmpty) {
                return 'Event Name is required!';
              }
              if (value.length > 80) {
                return 'Event Name can\'t be longer than 80 characters!';
              }
              return null;
            },
          ),
          SizedBox(height: 14.0),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: descriptionController,
            maxLines: 3,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
              errorStyle: TextStyle(color: Colors.red),
              labelText: 'Event Description',
            ),
            onEditingComplete: () => node.unfocus(),
            validator: (value) {
              if (value.length > 280) {
                return 'Description can\'t be longer than 280 characters!';
              }
              return null;
            },
          ),
          SizedBox(height: 14.0),
          DropdownButtonFormField<String>(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 2.0,
                ),
              ),
              errorStyle: TextStyle(color: Colors.red),
              labelText: 'Discipline',
            ),
            value: _disciplineID,
            items: disciplines.map((discipline) {
              return DropdownMenuItem<String>(
                value: discipline.id,
                child: Text(discipline.name),
              );
            }).toList(),
            onChanged: (String newValue) {
              _disciplineID = newValue;
              setDiscipline(newValue);
            },
            validator: (value) {
              if (value == null) {
                return 'Discipline is required!';
              }
              return null;
            },
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

class DateStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final Function setStartDate;
  final Function setEndDate;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final Function validateStartDate;
  final Function validateEndDate;

  const DateStep({
    @required this.formKey,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.validateStartDate,
    @required this.validateEndDate,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(height: 2.0),
          TextFieldDateTimePicker(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            labelText: 'Start date',
            prefixIcon: Icon(
              Icons.date_range,
              color: Colors.grey[850],
            ),
            firstDate: DateTime(DateTime.now().year - 10),
            lastDate: DateTime(DateTime.now().year + 10),
            initialDate: initStartDate,
            onDateChanged: (DateTime date) {
              setStartDate(date);
            },
            validator: (value) {
              return validateStartDate();
            },
          ),
          SizedBox(height: 14.0),
          TextFieldDateTimePicker(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            labelText: 'End date',
            prefixIcon: Icon(
              Icons.date_range,
              color: Colors.grey[850],
            ),
            firstDate: DateTime(DateTime.now().year - 10),
            lastDate: DateTime(DateTime.now().year + 10),
            initialDate: initEndDate,
            onDateChanged: (DateTime date) {
              setEndDate(date);
            },
            validator: (value) {
              return validateEndDate();
            },
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}

class PrivacySettingsStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function setPrivacyRule;
  final EventPrivacyRule initPrivacyRule;

  PrivacySettingsStep({
    @required this.formKey,
    @required this.eventPrivacyRules,
    @required this.setPrivacyRule,
    @required this.initPrivacyRule,
  });

  @override
  State<PrivacySettingsStep> createState() => PrivacySettingsStepState(
        formKey: formKey,
        eventPrivacyRules: eventPrivacyRules,
        setPrivacyRule: setPrivacyRule,
        initPrivacyRule: initPrivacyRule,
      );
}

class PrivacySettingsStepState extends State<PrivacySettingsStep> {
  final GlobalKey<FormState> formKey;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function setPrivacyRule;
  final EventPrivacyRule initPrivacyRule;
  var _privacyRule;

  PrivacySettingsStepState({
    @required this.formKey,
    @required this.eventPrivacyRules,
    @required this.setPrivacyRule,
    @required this.initPrivacyRule,
  });

  @override
  void initState() {
    _privacyRule = initPrivacyRule;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          SizedBox(height: 2.0),
          DropdownButtonFormField<EventPrivacyRule>(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Privacy Settings',
            ),
            value: _privacyRule,
            items: eventPrivacyRules.map((privacyRule) {
              return DropdownMenuItem<EventPrivacyRule>(
                value: privacyRule,
                child: Text(privacyRule.name),
              );
            }).toList(),
            onChanged: (EventPrivacyRule newValue) {
              setState(() {
                _privacyRule = newValue;
                setPrivacyRule(newValue);
              });
            },
            validator: (value) {
              if (value == null) {
                'Privacy Settings are required!';
              }
              return null;
            },
          ),
          SizedBox(height: 8.0),
          Text(
            _privacyRule.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
