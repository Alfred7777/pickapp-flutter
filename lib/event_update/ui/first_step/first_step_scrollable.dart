import 'package:PickApp/event_details/event_details_bloc.dart';
import 'package:PickApp/event_details/event_details_event.dart';
import 'package:PickApp/event_details/event_details_state.dart';
import 'package:PickApp/event_update/bloc/event_update_bloc.dart';
import 'package:PickApp/event_update/bloc/event_update_state.dart';
import 'package:PickApp/event_update/bloc/event_update_event.dart';
import 'package:PickApp/event_update/ui/second_step/second_step_screen.dart';

import 'package:PickApp/repositories/eventRepository.dart';
import 'package:PickApp/repositories/userRepository.dart';

import 'package:PickApp/event_update/widgets/user_widget.dart';
import 'package:PickApp/event_update/widgets/header.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FirstStepScrollable extends StatefulWidget {
  final String eventID;

  FirstStepScrollable({@required this.eventID});

  @override
  State<FirstStepScrollable> createState() =>
      FirstStepScrollableState(eventID: eventID);
}

class FirstStepScrollableState extends State<FirstStepScrollable> {
  final String eventID;
  final eventRepository = EventRepository();
  EventDetailsBloc _eventDetailsBloc;
  List<Discipline> disciplineList;
  FirstStepScrollableState({@required this.eventID});

  @override
  void initState() {
    super.initState();
    _eventDetailsBloc = EventDetailsBloc(
      eventRepository: eventRepository,
      eventID: eventID,
    );
    eventRepository.getDisciplines().then((value) => disciplineList = value);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventDetailsBloc, EventDetailsState>(
      bloc: _eventDetailsBloc,
      builder: (context, state) {
        if (state is EventDetailsUninitialized) {
          _eventDetailsBloc.add(FetchEventDetails(eventID: eventID));
        }
        if (state is EventDetailsJoined) {
          return FirstStepForm(
            joinedEvent: true,
            eventDetails: state.eventDetails,
            participantsList: state.participantsList,
            disciplineList: disciplineList,
            eventID: eventID,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class FirstStepForm extends StatefulWidget {
  final bool joinedEvent;
  final Map<String, dynamic> eventDetails;
  final List<User> participantsList;
  final List<Discipline> disciplineList;

  final String eventID;

  FirstStepForm({
    @required this.joinedEvent,
    @required this.eventDetails,
    @required this.participantsList,
    @required this.disciplineList,
    @required this.eventID,
  });

  @override
  State<FirstStepForm> createState() => _FirstStepFormState(
        joinedEvent: joinedEvent,
        eventDetails: eventDetails,
        participantsList: participantsList,
        disciplineList: disciplineList,
        eventID: eventID,
      );
}

class _FirstStepFormState extends State<FirstStepForm> {
  final bool joinedEvent;
  final Map<String, dynamic> eventDetails;
  final List<User> participantsList;
  final List<Discipline> disciplineList;
  final String eventID;

  String name;
  String disciplineID;

  List<EventPrivacyRule> eventPrivacySettings;
  EventPrivacyRule currentEventPrivacy;

  EventUpdateBloc _eventUpdateBloc;

  _FirstStepFormState({
    @required this.joinedEvent,
    @required this.eventDetails,
    @required this.participantsList,
    @required this.disciplineList,
    @required this.eventID,
  });

  @override
  void initState() {
    super.initState();

    _eventUpdateBloc = EventUpdateBloc(
      initialEventName: eventDetails['name'],
      initialEventDisciplineID: eventDetails['discipline_id'],
      initialEventDescription: eventDetails['description'],
      initialEventStartDate: eventDetails['start_date'],
      initialEventEndDate: eventDetails['end_date'],
      initialAllowInvitations: eventDetails['settings']['allow_invitations'],
      initialRequireParticipationAcceptation: eventDetails['settings']
          ['require_participation_acceptation'],
      eventRepository: eventRepository,
    );

    name = _eventUpdateBloc.initialEventName;
    disciplineID = _eventUpdateBloc.initialEventDisciplineID;
    currentEventPrivacy = eventRepository.convertSettingsToEventPrivacyRule(
      _eventUpdateBloc.initialAllowInvitations,
      _eventUpdateBloc.initialRequireParticipationAcceptation,
    );
  }

  final EventRepository eventRepository = EventRepository();

  void setName(dynamic childValue) {
    setState(() {
      name = childValue;
    });
  }

  void setDisciplineID(dynamic childValue) {
    setState(() {
      disciplineID = childValue;
    });
  }

  void setCurrentEventPrivacy(dynamic childValue) {
    setState(() {
      currentEventPrivacy = childValue;
    });
    print(currentEventPrivacy.name);
  }

  void setFirstStep() {
    _eventUpdateBloc.add(
      EventUpdateFirstStepFinished(
        eventName: name,
        eventDisciplineID: disciplineID,
        eventPrivacy: currentEventPrivacy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _builder(
      context,
      eventName: name,
      disciplineID: disciplineID,
      disciplineList: disciplineList,
      currentEventPrivacy: currentEventPrivacy,
    );
  }

  Widget _builder(
    BuildContext context, {
    String eventName,
    String disciplineID,
    List<Discipline> disciplineList,
    EventPrivacyRule currentEventPrivacy,
  }) {
    return BlocBuilder<EventUpdateBloc, EventUpdateState>(
      bloc: _eventUpdateBloc,
      builder: (context, state) {
        return SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Header(text: 'Event Details', fontSize: 0.04),
            EventImage(disciplineID: disciplineID),
            UserWidget(),
            MaterialInput(
              initialValue: eventName,
              notifyParent: setName,
            ),
            DisciplineDropdown(
              disciplineID: disciplineID,
              disciplineList: disciplineList,
              notifyParent: setDisciplineID,
            ),
            PrivacySettingsDropdown(
              currentEventPrivacy: currentEventPrivacy,
              notifyParent: setCurrentEventPrivacy,
            ),
            NextStepButton(
              eventID: eventID,
              notifyParent: setFirstStep,
              eventUpdateBloc: _eventUpdateBloc,
            )
          ]),
        );
      },
    );
  }
}

class EventImage extends StatelessWidget {
  final String disciplineID;

  const EventImage({this.disciplineID});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Center(
      child: Container(
        margin: EdgeInsets.only(
          left: 0.04 * screenSize.width,
          right: 0.04 * screenSize.width,
          top: 0.014 * screenSize.height,
          bottom: 0.018 * screenSize.height,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            'assets/images/event_placeholder/${disciplineID}.png',
            width: screenSize.width,
          ),
        ),
      ),
    );
  }
}

class MaterialInput extends StatefulWidget {
  final String initialValue;
  final Function(dynamic childValue) notifyParent;

  const MaterialInput(
      {@required this.initialValue, @required this.notifyParent});

  @override
  State<MaterialInput> createState() => _MaterialInputState(
        initialValue: initialValue,
        notifyParent: notifyParent,
      );
}

class _MaterialInputState extends State<MaterialInput> {
  final String initialValue;
  final Function(dynamic childValue) notifyParent;

  _MaterialInputState(
      {@required this.initialValue, @required this.notifyParent});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.only(
        left: 0.04 * screenSize.width,
        right: 0.04 * screenSize.width,
        top: 0.014 * screenSize.height,
        bottom: 0.018 * screenSize.height,
      ),
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Event Name',
        ),
        initialValue: initialValue,
        onChanged: (String newInputValue) {
          widget.notifyParent(newInputValue);
        },
      ),
    );
  }
}

class DisciplineDropdown extends StatefulWidget {
  final String disciplineID;
  final List<Discipline> disciplineList;

  final Function(dynamic childValue) notifyParent;

  const DisciplineDropdown({
    @required this.disciplineID,
    @required this.disciplineList,
    @required this.notifyParent,
  });

  @override
  State<DisciplineDropdown> createState() => _DisciplineDropdownState(
        disciplineID: disciplineID,
        disciplineList: disciplineList,
        notifyParent: notifyParent,
      );
}

class _DisciplineDropdownState extends State<DisciplineDropdown> {
  String disciplineID;
  final List<Discipline> disciplineList;

  final Function(dynamic childValue) notifyParent;

  _DisciplineDropdownState({
    @required this.disciplineID,
    @required this.disciplineList,
    @required this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        left: 0.05 * screenSize.width,
        right: 0.05 * screenSize.width,
        top: 0.014 * screenSize.height,
        bottom: 0.018 * screenSize.height,
      ),
      child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(
            'Select discipline',
            style: TextStyle(),
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          onChanged: (String newValue) {
            FocusScope.of(context).unfocus();
            widget.notifyParent(newValue);
            setState(() {
              disciplineID = newValue;
            });
          },
          value: disciplineID,
          items: disciplineList.map((discipline) {
            return DropdownMenuItem<String>(
              value: discipline.id,
              child: Text(discipline.name),
            );
          }).toList()),
    );
  }
}

class PrivacySettingsDropdown extends StatefulWidget {
  final EventPrivacyRule currentEventPrivacy;

  final Function(dynamic childValue) notifyParent;

  const PrivacySettingsDropdown({
    @required this.currentEventPrivacy,
    @required this.notifyParent,
  });

  @override
  State<PrivacySettingsDropdown> createState() => _PrivacySettingsDropdownState(
        currentEventPrivacy: currentEventPrivacy,
        notifyParent: notifyParent,
      );
}

class _PrivacySettingsDropdownState extends State<PrivacySettingsDropdown> {
  EventPrivacyRule currentEventPrivacy;
  final Function(dynamic childValue) notifyParent;
  final EventRepository eventRepository = EventRepository();

  List<EventPrivacyRule> eventPrivacySettings;

  _PrivacySettingsDropdownState({
    @required this.currentEventPrivacy,
    @required this.notifyParent,
  });

  @override
  void initState() {
    super.initState();
    eventPrivacySettings = eventRepository.getEventPrivacyRules();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(
        left: 0.05 * screenSize.width,
        right: 0.05 * screenSize.width,
      ),
      child: DropdownButton<EventPrivacyRule>(
        isExpanded: true,
        hint: Text(
          'Event privacy settings',
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
        onChanged: (EventPrivacyRule newValue) {
          FocusScope.of(context).unfocus();
          widget.notifyParent(newValue);
          setState(() {
            currentEventPrivacy = newValue;
          });
        },
        value: currentEventPrivacy,
        items: eventPrivacySettings.map((privacyRule) {
          return DropdownMenuItem<EventPrivacyRule>(
            value: privacyRule,
            child: Text(privacyRule.name),
          );
        }).toList(),
      ),
    );
  }
}

class NextStepButton extends StatelessWidget {
  final String eventID;
  final EventUpdateBloc eventUpdateBloc;
  final Function() notifyParent;

  const NextStepButton({
    this.eventID,
    this.eventUpdateBloc,
    this.notifyParent,
  });

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        left: 0.04 * screenSize.width,
        right: 0.04 * screenSize.width,
        top: 0.014 * screenSize.height,
        bottom: 0.018 * screenSize.height,
      ),
      child: ElevatedButton(
        onPressed: () {
          var route = MaterialPageRoute<void>(
            builder: (context) => SecondStepScreen(
              eventID: eventID,
              eventUpdateBloc: eventUpdateBloc,
            ),
          );
          Navigator.push(context, route);
          notifyParent();
        },
        child: Text(
          'NEXT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
