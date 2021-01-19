import 'package:flutter/material.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/sliver_map_header.dart';

class FirstStepPage extends StatefulWidget {
  final EventDetails initialDetails;
  final List<Discipline> disciplineList;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final Function navigateToNextStep;
  final Function setDiscipline;

  const FirstStepPage({
    @required this.initialDetails,
    @required this.disciplineList,
    @required this.nameController,
    @required this.descriptionController,
    @required this.navigateToNextStep,
    @required this.setDiscipline,
  });

  @override
  State<FirstStepPage> createState() => FirstStepPageState(
        initialDetails: initialDetails,
        disciplineList: disciplineList,
        nameController: nameController,
        descriptionController: descriptionController,
        navigateToNextStep: navigateToNextStep,
        setDiscipline: setDiscipline,
      );
}

class FirstStepPageState extends State<FirstStepPage> {
  final EventDetails initialDetails;
  final List<Discipline> disciplineList;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final Function navigateToNextStep;
  final Function setDiscipline;

  FirstStepPageState({
    @required this.initialDetails,
    @required this.disciplineList,
    @required this.nameController,
    @required this.descriptionController,
    @required this.navigateToNextStep,
    @required this.setDiscipline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideScreenTopBar(
        title: 'Edit Event',
      ),
      body: SafeArea(
        child: FirstStepForm(
          initialDetails: initialDetails,
          disciplineList: disciplineList,
          nameController: nameController,
          descriptionController: descriptionController,
          navigateToNextStep: navigateToNextStep,
          setDiscipline: setDiscipline,
        ),
      ),
    );
  }
}

class FirstStepForm extends StatefulWidget {
  final EventDetails initialDetails;
  final List<Discipline> disciplineList;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final Function navigateToNextStep;
  final Function setDiscipline;

  const FirstStepForm({
    @required this.initialDetails,
    @required this.disciplineList,
    @required this.nameController,
    @required this.descriptionController,
    @required this.navigateToNextStep,
    @required this.setDiscipline,
  });

  @override
  State<FirstStepForm> createState() => FirstStepFormState(
        initialDetails: initialDetails,
        disciplineList: disciplineList,
        nameController: nameController,
        descriptionController: descriptionController,
        navigateToNextStep: navigateToNextStep,
        setDiscipline: setDiscipline,
      );
}

class FirstStepFormState extends State<FirstStepForm> {
  final EventDetails initialDetails;
  final List<Discipline> disciplineList;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final Function navigateToNextStep;
  final Function setDiscipline;

  final _informationFormKey = GlobalKey<FormState>();

  FirstStepFormState({
    @required this.initialDetails,
    @required this.disciplineList,
    @required this.nameController,
    @required this.descriptionController,
    @required this.navigateToNextStep,
    @required this.setDiscipline,
  });

  @override
  void initState() {
    super.initState();
  }

  bool _isFormValid() {
    if (_informationFormKey.currentState == null) {
      return true;
    } else {
      if (_informationFormKey.currentState.validate()) {
        return true;
      }
      return false;
    }
  }

  void _nextStep() {
    if (_isFormValid()) {
      navigateToNextStep();
    }
  }

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
            markerPos: initialDetails.position,
            privacyBadge: null,
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 0.04 * screenSize.width,
                        bottom: 18,
                      ),
                      child: Text(
                        'Event Details',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 0.9 * screenSize.width,
                    child: InformationForm(
                      formKey: _informationFormKey,
                      nameController: nameController,
                      descriptionController: descriptionController,
                      disciplines: disciplineList,
                      setDiscipline: setDiscipline,
                      initName: initialDetails.name,
                      initDescription: initialDetails.description,
                      initDisciplineID: initialDetails.disciplineID,
                    ),
                  ),
                  NextStepButton(
                    notifyParent: _nextStep,
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

class InformationForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final Function setDiscipline;
  final String initName;
  final String initDescription;
  final String initDisciplineID;

  const InformationForm({
    @required this.formKey,
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.setDiscipline,
    @required this.initName,
    @required this.initDescription,
    @required this.initDisciplineID,
  });

  @override
  State<InformationForm> createState() => InformationFormState(
        formKey: formKey,
        nameController: nameController,
        descriptionController: descriptionController,
        disciplines: disciplines,
        setDiscipline: setDiscipline,
        initName: initName,
        initDescription: initDescription,
        initDisciplineID: initDisciplineID,
      );
}

class InformationFormState extends State<InformationForm> {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final List<Discipline> disciplines;
  final Function setDiscipline;
  final String initName;
  final String initDescription;
  final String initDisciplineID;

  InformationFormState({
    @required this.formKey,
    @required this.nameController,
    @required this.descriptionController,
    @required this.disciplines,
    @required this.setDiscipline,
    @required this.initName,
    @required this.initDescription,
    @required this.initDisciplineID,
  });

  @override
  void initState() {
    super.initState();
    nameController.text = initName;
    descriptionController.text = initDescription;
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    var _disciplineID = initDisciplineID;
    return Form(
      key: formKey,
      child: Column(
        children: [
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
            maxLines: 4,
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

class NextStepButton extends StatelessWidget {
  final Function notifyParent;

  const NextStepButton({
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return MaterialButton(
      height: 32,
      minWidth: 0.9 * screenSize.width,
      onPressed: notifyParent,
      color: Colors.green,
      child: Text(
        'NEXT',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
