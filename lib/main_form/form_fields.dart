import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainFormField extends StatefulWidget {
  final String labelText;
  final String? Function(String?) validator;
  final TextEditingController controller;
  final int? maxLines;
  final GlobalKey? formKey;
  final Icon? sufixIcon;

  const MainFormField(
      {super.key,
        required this.labelText,
        required this.validator,
        required this.controller,
        this.maxLines,
        GlobalKey? this.formKey,
        Icon? this.sufixIcon});

  @override
  State<MainFormField> createState() => _MainFormFieldState();
}

class _MainFormFieldState extends State<MainFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        key: widget.formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLines: widget.maxLines ?? 1,
        decoration: InputDecoration(
          labelText: widget.labelText,
          suffixIcon: widget.sufixIcon,
          hintStyle: const TextStyle(overflow: TextOverflow.clip),
        ),
        validator: widget.validator,
        controller: widget.controller,
      ),
    );
  }
}

// form field that on click displays a date picker dialog and fills itself with the selected date
class DatePickerFormField extends StatefulWidget {
  final TextEditingController dateController;

  const DatePickerFormField({super.key, required this.dateController});

  @override
  State<DatePickerFormField> createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale("pl", "PL"),
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        widget.dateController.text =
            DateFormat('dd.MM.yyyy').format(selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.dateController,
              decoration: const InputDecoration(
                labelText: "Data zdarzenia",
                hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
                hintText: "DD.MM.RRRR",
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    !RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(value)) {
                  return 'Proszę wprowadzić datę w formacie DD.MM.RRRR';
                }
                //catch an error parsing the date
                try {
                  DateFormat('dd.MM.yyyy').parseStrict(value);
                } catch (e) {
                  return 'Proszę wprowadzić datę w formacie DD.MM.RRRR';
                }
                if (DateFormat('dd.mm.yyyy')
                    .parseStrict(value)
                    .isAfter(DateTime.now())) {
                  return 'Data zdarzenia nie może być późniejsza niż dzisiejsza';
                } else if (DateFormat('dd.mm.yyyy')
                    .parseStrict(value)
                    .isBefore(DateTime(2020))) {
                  return 'Data zdarzenia nie może być wcześniejsza niż 01.01.2020';
                }
                return null;
              },
            ),
          ),
          IconButton(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
    );
  }
}

// form field that on click displays a time picker dialog and fills itself with the selected time
class TimePickerFormField extends StatefulWidget {
  final TextEditingController timeController;

  const TimePickerFormField({super.key, required this.timeController});

  @override
  State<TimePickerFormField> createState() => _TimePickerFormFieldState();
}

class _TimePickerFormFieldState extends State<TimePickerFormField> {
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        widget.timeController.text = DateFormat('HH:mm')
            .format(DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextFormField(
              controller: widget.timeController,
              decoration: const InputDecoration(
                labelText: "Godzina zdarzenia",
                hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
                hintText: "GG:MM",
              ),
              validator: (value) {
                if (value == null ||
                    value.isEmpty ||
                    !RegExp(r'^[0-9]{2}:[0-9]{2}$').hasMatch(value)) {
                  return 'Proszę wprowadzić godzinę w formacie GG:MM';
                }
                try {
                  DateFormat('HH:mm').parseStrict(value);
                } catch (e) {
                  return 'Proszę wprowadzić godzinę w formacie GG:MM';
                }
                return null;
              },
            ),
          ),
          IconButton(
            onPressed: () => _selectTime(context),
            icon: const Icon(Icons.access_time),
          ),
        ],
      ),
    );
  }
}
