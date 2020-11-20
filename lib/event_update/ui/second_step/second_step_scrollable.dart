import 'package:PickApp/event_update/bloc/event_update_bloc.dart';
import 'package:PickApp/event_update/bloc/event_update_event.dart';
import 'package:PickApp/event_update/bloc/event_update_state.dart';

import 'package:PickApp/home/home_screen.dart';
import 'package:PickApp/repositories/eventRepository.dart';
import 'package:PickApp/event_update/widgets/header.dart';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SecondStepScrollable extends StatefulWidget {
  final String eventID;
  final EventUpdateBloc eventUpdateBloc;

  SecondStepScrollable({
    @required this.eventID,
    @required this.eventUpdateBloc,
  });

  @override
  State<SecondStepScrollable> createState() => SecondStepScrollableState(
        eventID: eventID,
        eventUpdateBloc: eventUpdateBloc,
      );
}

class SecondStepScrollableState extends State<SecondStepScrollable> {
  final String eventID;
  final EventUpdateBloc eventUpdateBloc;

  final eventRepository = EventRepository();

  SecondStepScrollableState({
    @required this.eventID,
    @required this.eventUpdateBloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventUpdateBloc, EventUpdateState>(
      bloc: eventUpdateBloc,
      builder: (context, state) {
        return SecondStepForm(
          joinedEvent: false,
          eventID: eventID,
          eventUpdateBloc: eventUpdateBloc,
        );
      },
    );
  }
}

class SecondStepForm extends StatefulWidget {
  final bool joinedEvent;
  final String eventID;
  final EventUpdateBloc eventUpdateBloc;

  SecondStepForm({
    @required this.joinedEvent,
    @required this.eventID,
    @required this.eventUpdateBloc,
  });

  @override
  State<SecondStepForm> createState() => _SecondStepFormState(
        joinedEvent: joinedEvent,
        eventID: eventID,
        eventUpdateBloc: eventUpdateBloc,
      );
}

class _SecondStepFormState extends State<SecondStepForm> {
  final bool joinedEvent;
  final String eventID;
  final EventUpdateBloc eventUpdateBloc;

  String eventName;
  String eventDisciplineID;
  DateTime startDate;
  DateTime endDate;
  EventPrivacyRule eventPrivacy;

  _SecondStepFormState({
    @required this.joinedEvent,
    @required this.eventID,
    @required this.eventUpdateBloc,
  });

  @override
  void initState() {
    super.initState();
    eventName = eventUpdateBloc.state.props[0];
    eventDisciplineID = eventUpdateBloc.state.props[1];
    eventPrivacy = eventUpdateBloc.state.props[2];
    description = eventUpdateBloc.initialEventDescription;
    startDate = eventUpdateBloc.initialEventStartDate;
    endDate = eventUpdateBloc.initialEventEndDate;
  }

  final EventRepository eventRepository = EventRepository();

  String description;

  void setDescription(dynamic childValue) {
    setState(() {
      description = childValue;
    });
  }

  void setStartDate(dynamic childValue) {
    setState(() {
      startDate = childValue;
    });
  }

  void setEndDate(dynamic childValue) {
    setState(() {
      endDate = childValue;
    });
  }

  void updateEventTrigger() {
    eventUpdateBloc.add(
      UpdateEventButtonPressed(
        eventName: eventName,
        eventID: eventID,
        eventDescription: description,
        eventDisciplineID: eventDisciplineID,
        eventStartDate: startDate,
        eventEndDate: endDate,
        allowInvitations: eventPrivacy.allowInvitations,
        requireParticipationAcceptation:
            eventPrivacy.requireParticipationAcceptation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventUpdateBloc, EventUpdateState>(
      bloc: eventUpdateBloc,
      builder: (context, state) {
        return SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Header(text: 'Description', fontSize: 0.04),
          MaterialDescriptionInput(
            initialValue: description,
            notifyParent: setDescription,
          ),
          DatePicker(
              startDate: startDate,
              endDate: endDate,
              notifyParent: [setStartDate, setEndDate]),
          NextButton(
            eventUpdateBloc: eventUpdateBloc,
            notifyParent: updateEventTrigger,
          )
        ]));
      },
    );
  }
}

class MaterialDescriptionInput extends StatefulWidget {
  final String initialValue;
  final Function(dynamic childValue) notifyParent;

  const MaterialDescriptionInput(
      {@required this.initialValue, @required this.notifyParent});

  @override
  State<MaterialDescriptionInput> createState() =>
      _MaterialDescriptionInputState(initialValue: initialValue);
}

class _MaterialDescriptionInputState extends State<MaterialDescriptionInput> {
  final String initialValue;
  Function(dynamic childValue) notifyParent;

  _MaterialDescriptionInputState({@required this.initialValue});

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
        keyboardType: TextInputType.multiline,
        minLines: 10,
        maxLines: 10,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Event Description',
        ),
        initialValue: initialValue,
        onChanged: (String newInputValue) {
          widget.notifyParent(newInputValue);
        },
      ),
    );
  }
}

class DatePicker extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final List<Function(dynamic childValue)> notifyParent;

  const DatePicker({
    @required this.startDate,
    @required this.endDate,
    @required this.notifyParent,
  });

  @override
  State<DatePicker> createState() => _DatePickerState(
        startDate: startDate,
        endDate: endDate,
        notifyParent: notifyParent,
      );
}

class _DatePickerState extends State<DatePicker> {
  DateTime startDate;
  DateTime endDate;
  final List<Function(dynamic childValue)> notifyParent;

  _DatePickerState({
    @required this.startDate,
    @required this.endDate,
    @required this.notifyParent,
  });

  Future<Null> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: startDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
    );
    if (picked != null && picked != startDate) {
      if (picked.isBefore(startDate)) {
        var difference = picked.difference(startDate).inDays;
        widget.notifyParent.first(
          startDate.add(
            Duration(days: difference),
          ),
        );
        setState(() {
          startDate = startDate.add(
            Duration(days: difference),
          );
        });
      } else {
        var difference = picked.difference(startDate).inDays + 1;
        widget.notifyParent.first(
          startDate.add(
            Duration(days: difference),
          ),
        );
        setState(() {
          startDate = startDate.add(
            Duration(days: difference),
          );
        });
      }
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
      if (picked.isBefore(endDate)) {
        var difference = picked.difference(endDate).inDays;
        widget.notifyParent.last(
          endDate.add(
            Duration(days: difference),
          ),
        );
        setState(() {
          endDate = endDate.add(
            Duration(days: difference),
          );
        });
      } else {
        var difference = picked.difference(endDate).inDays + 1;
        widget.notifyParent.last(
          endDate.add(
            Duration(days: difference),
          ),
        );
        setState(() {
          endDate = endDate.add(
            Duration(days: difference),
          );
        });
      }
    }
  }

  Future<Null> _selectStartTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startDate),
    );
    if (picked != null) {
      widget.notifyParent.first(
        DateTime(
          startDate.year,
          startDate.month,
          startDate.day,
          picked.hour,
          picked.minute,
        ),
      );
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
      widget.notifyParent.last(
        DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          picked.hour,
          picked.minute,
        ),
      );
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

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(
            left: 0.04 * screenSize.width,
            top: 0.014 * screenSize.height,
            bottom: 0.018 * screenSize.height,
          ),
          child: Form(
            child: Column(
              children: [
                Header(text: 'Start Date', fontSize: 0.02),
                Row(
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
                Header(text: 'End Date', fontSize: 0.02),
                Row(
                  children: [
                    RaisedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        _selectEndDate(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(0.006 * screenSize.height),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NextButton extends StatefulWidget {
  final EventUpdateBloc eventUpdateBloc;
  final Function() notifyParent;
  NextButton({@required this.eventUpdateBloc, @required this.notifyParent});

  @override
  State<NextButton> createState() => NextButtonState(
        eventUpdateBloc: eventUpdateBloc,
        notifyParent: notifyParent,
      );
}

class NextButtonState extends State<NextButton> {
  final EventUpdateBloc eventUpdateBloc;
  final Function() notifyParent;

  NextButtonState({this.eventUpdateBloc, this.notifyParent});

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;

    return BlocListener<EventUpdateBloc, EventUpdateState>(
      bloc: eventUpdateBloc,
      listener: (context, state) {
        if (state is EventUpdateSuccess) {
          var route = MaterialPageRoute<void>(
            builder: (context) => HomeScreen(),
          );
          Navigator.push(context, route);
        }
        if (state is EventUpdateFailure) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.error.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          left: 0.04 * screenSize.width,
          right: 0.04 * screenSize.width,
          top: 0.014 * screenSize.height,
          bottom: 0.018 * screenSize.height,
        ),
        child: ElevatedButton(
          onPressed: () {
            notifyParent();
          },
          child: Text(
            'UPDATE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
