import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TextFieldDateTimePicker extends StatefulWidget {
  final ValueChanged<DateTime> onDateChanged;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateFormat dateFormat;
  final FocusNode focusNode;
  final String labelText;
  final Icon prefixIcon;
  final FormFieldValidator validator;

  TextFieldDateTimePicker({
    this.labelText,
    this.prefixIcon,
    this.focusNode,
    this.dateFormat,
    this.validator,
    @required this.firstDate,
    @required this.lastDate,
    @required this.initialDate,
    @required this.onDateChanged,
  })  : assert(initialDate != null),
        assert(firstDate != null),
        assert(lastDate != null),
        assert(!initialDate.isBefore(firstDate),
            'initialDate must be on or after firstDate'),
        assert(!initialDate.isAfter(lastDate),
            'initialDate must be on or before lastDate'),
        assert(!firstDate.isAfter(lastDate),
            'lastDate must be on or after firstDate'),
        assert(onDateChanged != null, 'onDateChanged must not be null');

  @override
  State<TextFieldDateTimePicker> createState() =>
      TextFieldDateTimePickerState();
}

class TextFieldDateTimePickerState extends State<TextFieldDateTimePicker> {
  TextEditingController _dateController;
  DateFormat _dateFormat;
  DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();

    if (widget.dateFormat != null) {
      _dateFormat = widget.dateFormat;
    } else {
      _dateFormat = DateFormat.yMd().add_Hm();
    }

    _selectedDateTime = widget.initialDate;

    _dateController = TextEditingController();
    _dateController.text = _dateFormat.format(_selectedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.always,
      focusNode: widget.focusNode,
      controller: _dateController,
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
        prefixIcon: widget.prefixIcon,
        labelText: widget.labelText,
      ),
      onTap: () => _selectDate(context),
      readOnly: true,
      validator: widget.validator,
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<Null> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: widget.firstDate,
      lastDate: widget.lastDate,
    );

    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        final pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        if (pickedDateTime != _selectedDateTime) {
          _selectedDateTime = pickedDateTime;
          _dateController.text = _dateFormat.format(_selectedDateTime);
          widget.onDateChanged(_selectedDateTime);
        }
      }
    }

    if (widget.focusNode != null) {
      widget.focusNode.unfocus();
    }
  }
}
