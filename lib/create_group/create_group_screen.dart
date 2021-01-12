import 'package:PickApp/widgets/loading_screen.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'create_group_bloc.dart';
import 'create_group_state.dart';
import 'create_group_event.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/repositories/group_repository.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  State<CreateGroupScreen> createState() => CreateGroupScreenState();
}

class CreateGroupScreenState extends State<CreateGroupScreen> {
  final eventRepository = EventRepository();
  final groupRepository = GroupRepository();
  CreateGroupBloc _createGroupBloc;

  TextEditingController _nameController;
  TextEditingController _descriptionController;
  String _disciplineID;

  @override
  void initState() {
    super.initState();
    _createGroupBloc = CreateGroupBloc(
      eventRepository: eventRepository,
      groupRepository: groupRepository,
    );

    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _createGroupBloc.close();
    super.dispose();
  }

  void _setDiscipline(String disciplineID) {
    _disciplineID = disciplineID;
  }

  void _createGroup() {
    _createGroupBloc.add(
      CreateGroupButtonPressed(
        disciplines: _createGroupBloc.state.props.first,
        groupName: _nameController.text,
        groupDescription: _descriptionController.text,
        groupDisciplineID: _disciplineID,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: sideScreenTopBar(context),
      body: BlocListener<CreateGroupBloc, CreateGroupState>(
        bloc: _createGroupBloc,
        listener: (context, state) {
          if (state is FetchDisciplinesFailure) {
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CreateGroupFailure) {
            Navigator.pop(context);
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is CreateGroupCreated) {
            Navigator.pop(context, [state.props.first]);
          }
        },
        child: BlocBuilder<CreateGroupBloc, CreateGroupState>(
          bloc: _createGroupBloc,
          condition: (prevState, currState) {
            if (currState is CreateGroupLoading) {
              return false;
            }
            if (currState is CreateGroupFailure) {
              return false;
            }
            return true;
          },
          builder: (context, state) {
            if (state is CreateGroupInitial) {
              _createGroupBloc.add(FetchDisciplines());
            }
            if (state is CreateGroupReady) {
              return CreateGroupStepper(
                nameController: _nameController,
                descriptionController: _descriptionController,
                disciplines: _createGroupBloc.state.props.first,
                createGroup: _createGroup,
                setDiscipline: _setDiscipline,
                initDisciplineID: _disciplineID,
              );
            }
            return LoadingScreen();
          },
        ),
      ),
    );
  }
}

class CreateGroupStepper extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final Function createGroup;
  final Function setDiscipline;
  final String initDisciplineID;

  CreateGroupStepper({
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.createGroup,
    @required this.setDiscipline,
    @required this.initDisciplineID,
  });

  @override
  State<CreateGroupStepper> createState() => CreateGroupStepperState(
        nameController: nameController,
        descriptionController: descriptionController,
        disciplines: disciplines,
        createGroup: createGroup,
        setDiscipline: setDiscipline,
        initDisciplineID: initDisciplineID,
      );
}

class CreateGroupStepperState extends State<CreateGroupStepper> {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final Function createGroup;
  final Function setDiscipline;
  final String initDisciplineID;

  int _currentStep = 0;
  final _formKeys = [GlobalKey<FormState>()];

  CreateGroupStepperState({
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.createGroup,
    @required this.setDiscipline,
    @required this.initDisciplineID,
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
            createGroup();
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
            setDiscipline: setDiscipline,
            initDisciplineID: initDisciplineID,
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
              labelText: 'Group Name',
            ),
            onEditingComplete: () => node.nextFocus(),
            validator: (value) {
              if (value.isEmpty) {
                return 'Group Name is required!';
              }
              if (value.length > 80) {
                return 'Group Name can\'t be longer than 80 characters!';
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
              labelText: 'Group Description',
            ),
            onEditingComplete: () => node.unfocus(),
            validator: (value) {
              if (value.length > 280) {
                return 'Group description can\'t be longer than 280 characters!';
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
