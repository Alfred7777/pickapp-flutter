import 'package:PickApp/main.dart';
import 'package:PickApp/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'create_location_bloc.dart';
import 'create_location_state.dart';
import 'create_location_event.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/location_repository.dart';

class CreateLocationScreen extends StatefulWidget {
  final CameraPosition initialCameraPos;

  CreateLocationScreen({@required this.initialCameraPos});

  @override
  State<CreateLocationScreen> createState() => CreateLocationScreenState(
        initialCameraPos: initialCameraPos,
      );
}

class CreateLocationScreenState extends State<CreateLocationScreen> {
  final CameraPosition initialCameraPos;
  final eventRepository = EventRepository();
  final locationRepository = LocationRepository();
  CreateLocationBloc _createLocationBloc;

  TextEditingController _nameController;
  TextEditingController _descriptionController;
  List<String> _disciplineIDs;

  CreateLocationScreenState({
    @required this.initialCameraPos,
  });

  @override
  void initState() {
    super.initState();
    _createLocationBloc = CreateLocationBloc(
      eventRepository: eventRepository,
      locationRepository: locationRepository,
    );

    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _createLocationBloc.close();
    super.dispose();
  }

  void _pickLocation(LatLng pos) {
    _createLocationBloc.add(
      LocationPicked(
        disciplines: _createLocationBloc.state.props.first,
        pickedPos: pos,
      ),
    );
  }

  void _setDisciplines(List<String> disciplineIDs) {
    _disciplineIDs = disciplineIDs;
  }

  void _createLocation() {
    _createLocationBloc.add(
      CreateLocationButtonPressed(
        disciplines: _createLocationBloc.state.props.first,
        locationName: _nameController.text,
        locationDescription: _descriptionController.text,
        locationDisciplineIDs: _disciplineIDs,
        locationPos: _createLocationBloc.state.props.last,
      ),
    );
  }

  void _showCreateLocationPopup() {
    showDialog(
      context: navigatorKey.currentContext,
      builder: (BuildContext context) {
        return CreateLocationPopup(
          nameController: _nameController,
          descriptionController: _descriptionController,
          disciplines: _createLocationBloc.state.props[0],
          createLocation: _createLocation,
          setDisciplines: _setDisciplines,
          initDisciplineIDs: _disciplineIDs,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<CreateLocationBloc, CreateLocationState>(
        bloc: _createLocationBloc,
        listener: (context, state) {
          if (state is FetchDisciplinesFailure) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CreateLocationFailure) {
            Navigator.pop(context);
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CreateLocationCreated) {
            Navigator.pop(context);
            Navigator.pop(context, [state.props.last, state.props.first]);
          }
        },
        child: BlocBuilder<CreateLocationBloc, CreateLocationState>(
          bloc: _createLocationBloc,
          condition: (prevState, currState) {
            if (currState is CreateLocationLoading) {
              return false;
            }
            if (currState is CreateLocationFailure) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is CreateLocationInitial) {
              _createLocationBloc.add(FetchDisciplines());
            }
            if (state is CreateLocationReady) {
              return CreateLocationMap(
                initialCameraPos: initialCameraPos,
                pickedPos: state.pickedPos,
                pickLocation: _pickLocation,
                showCreateLocationPopup: _showCreateLocationPopup,
              );
            }
            return LoadingScreen();
          },
        ),
      ),
    );
  }
}

class CreateLocationMap extends StatelessWidget {
  final CameraPosition initialCameraPos;
  final LatLng pickedPos;
  final Function pickLocation;
  final Function showCreateLocationPopup;

  const CreateLocationMap({
    @required this.initialCameraPos,
    @required this.pickedPos,
    @required this.pickLocation,
    @required this.showCreateLocationPopup,
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
                    content: Text('Choose place for location!'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                showCreateLocationPopup();
              }
            },
            height: 40,
            minWidth: 160,
            color: Colors.green,
            child: Text(
              'CREATE LOCATION',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 100,
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
                  'Tap on map to choose place for location',
                  style: TextStyle(
                    color: Colors.white,
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
  }
}

class CreateLocationPopup extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final Function createLocation;
  final Function setDisciplines;
  final List<String> initDisciplineIDs;

  CreateLocationPopup({
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.createLocation,
    @required this.setDisciplines,
    @required this.initDisciplineIDs,
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
          child: CreateLocationStepper(
            nameController: nameController,
            descriptionController: descriptionController,
            disciplines: disciplines,
            createLocation: createLocation,
            setDisciplines: setDisciplines,
            initDisciplineIDs: initDisciplineIDs,
          ),
        ),
      ),
    );
  }
}

class CreateLocationStepper extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final Function createLocation;
  final Function setDisciplines;
  final List<String> initDisciplineIDs;

  CreateLocationStepper({
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.createLocation,
    @required this.setDisciplines,
    @required this.initDisciplineIDs,
  });

  @override
  State<CreateLocationStepper> createState() => CreateLocationStepperState(
        nameController: nameController,
        descriptionController: descriptionController,
        disciplines: disciplines,
        createLocation: createLocation,
        setDisciplines: setDisciplines,
        initDisciplineIDs: initDisciplineIDs,
      );
}

class CreateLocationStepperState extends State<CreateLocationStepper> {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final Function createLocation;
  final Function setDisciplines;
  final List<String> initDisciplineIDs;

  int _currentStep = 0;
  final _formKeys = [GlobalKey<FormState>()];

  CreateLocationStepperState({
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.createLocation,
    @required this.setDisciplines,
    @required this.initDisciplineIDs,
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
          if (_currentStep != 0) {
            _currentStep += 1;
          } else {
            createLocation();
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
                _currentStep < 0 ? 'Next' : 'Create',
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
            setDisciplines: setDisciplines,
            initDisciplineIDs: initDisciplineIDs,
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
  final Function setDisciplines;
  final List<String> initDisciplineIDs;

  const InformationStep({
    @required this.formKey,
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.setDisciplines,
    @required this.initDisciplineIDs,
  });

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
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
              labelText: 'Location Name',
            ),
            onEditingComplete: () => node.nextFocus(),
            validator: (value) {
              if (value.isEmpty) {
                return 'Location Name is required!';
              }
              if (value.length > 80) {
                return 'Location Name can\'t be longer than 80 characters!';
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
              labelText: 'Location Description',
            ),
            onEditingComplete: () => node.unfocus(),
            validator: (value) {
              if (value.length > 280) {
                return 'Location description can\'t be longer than 280 characters!';
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
