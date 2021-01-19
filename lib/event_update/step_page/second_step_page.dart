import 'package:flutter/material.dart';
import 'package:PickApp/repositories/event_repository.dart';
import 'package:PickApp/widgets/top_bar.dart';
import 'package:PickApp/widgets/sliver_map_header.dart';
import 'package:PickApp/widgets/date_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SecondStepPage extends StatefulWidget {
  final LatLng eventPos;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function updateEvent;
  final Function setStartDate;
  final Function setEndDate;
  final Function setPrivacyRule;
  final Function validateStartDate;
  final Function validateEndDate;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final EventPrivacyRule initPrivacyRule;

  SecondStepPage({
    @required this.eventPos,
    @required this.eventPrivacyRules,
    @required this.updateEvent,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.setPrivacyRule,
    @required this.validateStartDate,
    @required this.validateEndDate,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.initPrivacyRule,
  });

  @override
  State<SecondStepPage> createState() => SecondStepPageState(
        eventPos: eventPos,
        eventPrivacyRules: eventPrivacyRules,
        updateEvent: updateEvent,
        setStartDate: setStartDate,
        setEndDate: setEndDate,
        setPrivacyRule: setPrivacyRule,
        validateStartDate: validateStartDate,
        validateEndDate: validateEndDate,
        initStartDate: initStartDate,
        initEndDate: initEndDate,
        initPrivacyRule: initPrivacyRule,
      );
}

class SecondStepPageState extends State<SecondStepPage> {
  final LatLng eventPos;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function updateEvent;
  final Function setStartDate;
  final Function setEndDate;
  final Function setPrivacyRule;
  final Function validateStartDate;
  final Function validateEndDate;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final EventPrivacyRule initPrivacyRule;

  SecondStepPageState({
    @required this.eventPos,
    @required this.eventPrivacyRules,
    @required this.updateEvent,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.setPrivacyRule,
    @required this.validateStartDate,
    @required this.validateEndDate,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.initPrivacyRule,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SideScreenTopBar(
        title: 'Edit Event',
      ),
      body: SafeArea(
        child: SecondStepForm(
          eventPos: eventPos,
          eventPrivacyRules: eventPrivacyRules,
          updateEvent: updateEvent,
          setStartDate: setStartDate,
          setEndDate: setEndDate,
          setPrivacyRule: setPrivacyRule,
          validateStartDate: validateStartDate,
          validateEndDate: validateEndDate,
          initStartDate: initStartDate,
          initEndDate: initEndDate,
          initPrivacyRule: initPrivacyRule,
        ),
      ),
    );
  }
}

class SecondStepForm extends StatefulWidget {
  final LatLng eventPos;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function updateEvent;
  final Function setStartDate;
  final Function setEndDate;
  final Function setPrivacyRule;
  final Function validateStartDate;
  final Function validateEndDate;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final EventPrivacyRule initPrivacyRule;

  SecondStepForm({
    @required this.eventPos,
    @required this.eventPrivacyRules,
    @required this.updateEvent,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.setPrivacyRule,
    @required this.validateStartDate,
    @required this.validateEndDate,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.initPrivacyRule,
  });

  @override
  State<SecondStepForm> createState() => SecondStepFormState(
        eventPos: eventPos,
        eventPrivacyRules: eventPrivacyRules,
        updateEvent: updateEvent,
        setStartDate: setStartDate,
        setEndDate: setEndDate,
        setPrivacyRule: setPrivacyRule,
        validateStartDate: validateStartDate,
        validateEndDate: validateEndDate,
        initStartDate: initStartDate,
        initEndDate: initEndDate,
        initPrivacyRule: initPrivacyRule,
      );
}

class SecondStepFormState extends State<SecondStepForm> {
  final LatLng eventPos;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function updateEvent;
  final Function setStartDate;
  final Function setEndDate;
  final Function setPrivacyRule;
  final Function validateStartDate;
  final Function validateEndDate;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final EventPrivacyRule initPrivacyRule;

  final _dateAndPrivacyFormKey = GlobalKey<FormState>();

  SecondStepFormState({
    @required this.eventPos,
    @required this.eventPrivacyRules,
    @required this.updateEvent,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.setPrivacyRule,
    @required this.validateStartDate,
    @required this.validateEndDate,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.initPrivacyRule,
  });

  @override
  void initState() {
    super.initState();
  }

  bool _isFormValid() {
    if (_dateAndPrivacyFormKey.currentState == null) {
      return true;
    } else {
      if (_dateAndPrivacyFormKey.currentState.validate()) {
        return true;
      }
      return false;
    }
  }

  void _updateEvent() {
    if (_isFormValid()) {
      updateEvent();
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
            markerPos: eventPos,
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
                        bottom: 16,
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
                    child: DateAndPrivacyForm(
                      formKey: _dateAndPrivacyFormKey,
                      eventPrivacyRules: eventPrivacyRules,
                      setStartDate: setStartDate,
                      setEndDate: setEndDate,
                      setPrivacyRule: setPrivacyRule,
                      validateStartDate: validateStartDate,
                      validateEndDate: validateEndDate,
                      initStartDate: initStartDate,
                      initEndDate: initEndDate,
                      initPrivacyRule: initPrivacyRule,
                    ),
                  ),
                  UpdateEventButton(
                    notifyParent: _updateEvent,
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

class DateAndPrivacyForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function setStartDate;
  final Function setEndDate;
  final Function setPrivacyRule;
  final Function validateStartDate;
  final Function validateEndDate;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final EventPrivacyRule initPrivacyRule;

  const DateAndPrivacyForm({
    @required this.formKey,
    @required this.eventPrivacyRules,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.setPrivacyRule,
    @required this.validateStartDate,
    @required this.validateEndDate,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.initPrivacyRule,
  });

  @override
  State<DateAndPrivacyForm> createState() => DateAndPrivacyFormState(
        formKey: formKey,
        eventPrivacyRules: eventPrivacyRules,
        setStartDate: setStartDate,
        setEndDate: setEndDate,
        setPrivacyRule: setPrivacyRule,
        validateStartDate: validateStartDate,
        validateEndDate: validateEndDate,
        initStartDate: initStartDate,
        initEndDate: initEndDate,
        initPrivacyRule: initPrivacyRule,
      );
}

class DateAndPrivacyFormState extends State<DateAndPrivacyForm> {
  final GlobalKey<FormState> formKey;
  final List<EventPrivacyRule> eventPrivacyRules;
  final Function setStartDate;
  final Function setEndDate;
  final Function setPrivacyRule;
  final Function validateStartDate;
  final Function validateEndDate;
  final DateTime initStartDate;
  final DateTime initEndDate;
  final EventPrivacyRule initPrivacyRule;

  var _privacyRule;

  DateAndPrivacyFormState({
    @required this.formKey,
    @required this.eventPrivacyRules,
    @required this.setStartDate,
    @required this.setEndDate,
    @required this.setPrivacyRule,
    @required this.validateStartDate,
    @required this.validateEndDate,
    @required this.initStartDate,
    @required this.initEndDate,
    @required this.initPrivacyRule,
  });

  @override
  void initState() {
    super.initState();
    _privacyRule = initPrivacyRule;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
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
          SizedBox(height: 14.0),
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

class UpdateEventButton extends StatelessWidget {
  final Function notifyParent;

  const UpdateEventButton({
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
        'UPDATE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
