import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'event_update_bloc.dart';
import 'event_update_event.dart';
import 'event_update_state.dart';
import 'package:PickApp/event_update/step_page/first_step_page.dart';
import 'package:PickApp/event_update/step_page/second_step_page.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/widgets/loading_screen.dart';

class EventUpdateScreen extends StatefulWidget {
  final String eventID;

  EventUpdateScreen({@required this.eventID});

  @override
  State<EventUpdateScreen> createState() => EventUpdateScreenState(
        eventID: eventID,
      );
}

class EventUpdateScreenState extends State<EventUpdateScreen> {
  final String eventID;
  final eventRepository = EventRepository();
  EventUpdateBloc _eventUpdateBloc;

  LatLng _eventPos;

  TextEditingController _nameController;
  TextEditingController _descriptionController;
  String _disciplineID;
  DateTime _startDate;
  DateTime _endDate;

  List<EventPrivacyRule> _eventPrivacyRules;
  EventPrivacyRule _privacyRule;

  List<EventRecurringRule> _eventRecurringRules;
  EventRecurringRule _recurringRule;

  EventUpdateScreenState({
    @required this.eventID,
  });

  @override
  void initState() {
    super.initState();
    _eventUpdateBloc = EventUpdateBloc(
      eventRepository: eventRepository,
      eventID: eventID,
    );

    _nameController = TextEditingController();
    _descriptionController = TextEditingController();

    _eventPrivacyRules = EventPrivacyRule.getEventPrivacyRules();

    _eventRecurringRules = EventRecurringRule.getEventRecurringRules();
  }

  @override
  void dispose() {
    _eventUpdateBloc.close();
    super.dispose();
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

  void _setRecurringRule(EventRecurringRule recurringRule) {
    _recurringRule = recurringRule;
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

  void _navigateToNextStep() {
    var route = MaterialPageRoute<void>(
      builder: (context) => SecondStepPage(
        eventPos: _eventPos,
        eventPrivacyRules: _eventPrivacyRules,
        eventRecurringRules: _eventRecurringRules,
        updateEvent: _updateEvent,
        setStartDate: _setStartDate,
        setEndDate: _setEndDate,
        setPrivacyRule: _setPrivacyRule,
        setRecurringRule: _setRecurringRule,
        validateStartDate: _validateStartDate,
        validateEndDate: _validateEndDate,
        initStartDate: _startDate,
        initEndDate: _endDate,
        initPrivacyRule: _privacyRule,
        initRecurringRule: _recurringRule,
      ),
    );
    Navigator.push(context, route);
  }

  void _updateEvent() {
    _eventUpdateBloc.add(UpdateEventButtonPressed(
      initialDetails: _eventUpdateBloc.state.props.first,
      disciplines: _eventUpdateBloc.state.props.last,
      eventID: eventID,
      eventName: _nameController.text,
      eventDescription: _descriptionController.text,
      eventDisciplineID: _disciplineID,
      eventStartDate: _startDate,
      eventEndDate: _endDate,
      eventPrivacyRule: _privacyRule,
      recurrenceIntervalInSeconds: _recurringRule.recurrenceIntervalInSeconds,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener(
        bloc: _eventUpdateBloc,
        listener: (context, state) {
          if (state is EventUpdateFailure) {
            Navigator.pop(context);
            Scaffold.of(context).showSnackBar(
              SnackBar(
                content: Text('${state.error}'),
                backgroundColor: Colors.red,
                duration: Duration(milliseconds: 500),
              ),
            );
          }
          if (state is EventUpdateSuccess) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
          if (state is EventUpdateReady && _eventPos == null) {
            _eventPos = state.initialDetails.position;
            _disciplineID = state.initialDetails.disciplineID;
            _startDate = state.initialDetails.startDate;
            _endDate = state.initialDetails.endDate;
            _privacyRule = EventPrivacyRule.fromBooleans(
              state.initialDetails.allowInvitations,
              state.initialDetails.requireParticipationAcceptation,
            );
            _recurringRule = EventRecurringRule.getRule(
                state.initialDetails.recurrenceIntervalInSeconds);
          }
        },
        child: BlocBuilder<EventUpdateBloc, EventUpdateState>(
          bloc: _eventUpdateBloc,
          builder: (context, state) {
            if (state is EventUpdateUninitialized) {
              _eventUpdateBloc.add(FetchInitialDetails(eventID: eventID));
            }
            if (state is EventUpdateReady) {
              return FirstStepPage(
                initialDetails: state.initialDetails,
                disciplineList: state.disciplines,
                nameController: _nameController,
                descriptionController: _descriptionController,
                navigateToNextStep: _navigateToNextStep,
                setDiscipline: _setDiscipline,
              );
            }
            return LoadingScreen();
          },
        ),
      ),
    );
  }
}
