import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MainForm extends StatefulWidget {
  const MainForm({super.key});

  @override
  State<MainForm> createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Dane osobowe:',
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: MainFormField(
                      labelText: "Imię",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Proszę wprowadzić imię';
                        }
                        return null;
                      },
                    ),
                  ),
                  Expanded(
                    child: MainFormField(
                      labelText: "Nazwisko",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Proszę wprowadzić nazwisko';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              MainFormField(
                labelText: "E-mail służbowy",
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      !RegExp(r'^.*\..*@.*\.s.*\.gov\.pl$').hasMatch(value)) {
                    return 'Proszę wprowadzić poprawny e-mail kończący się na @*.s*.gov.pl';
                  }
                  return null;
                },
              ),
            ],
          ),
          const Text(
            'Dane zdarzenia:',
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: DatePickerFormField()),
                  Expanded(child: TimePickerFormField()),
                ],
              ),
              MainFormField(
                labelText: "Miejsce zdarzenia",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić miejsce zdarzenia';
                  }
                  return null;
                },
              ),
              MainFormField(
                labelText: "Opis zdarzenia",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić opis zdarzenia';
                  }
                  return null;
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: Text("Wyślij"),
            ),
          ),
        ],
      ),
    );
  }
}

class MainFormField extends StatefulWidget {
  final String labelText;

  final String? Function(String?) validator;

  const MainFormField(
      {super.key, required this.labelText, required this.validator});

  @override
  State<MainFormField> createState() => _MainFormFieldState();
}

class _MainFormFieldState extends State<MainFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: widget.labelText,
        ),
        validator: widget.validator,
      ),
    );
  }
}

// form field that on click displays a date picker dialog and fills itself with the selected date
class DatePickerFormField extends StatefulWidget {
  const DatePickerFormField({super.key});

  @override
  State<DatePickerFormField> createState() => _DatePickerFormFieldState();
}

class _DatePickerFormFieldState extends State<DatePickerFormField> {
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat('dd.MM.yyyy').format(selectedDate);
      });
    }
  }

  TextEditingController _dateController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Data zdarzenia",
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
                ;
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
            icon: Icon(Icons.calendar_month),
          ),
        ],
      ),
    );
  }
}

// form field that on click displays a time picker dialog and fills itself with the selected time
class TimePickerFormField extends StatefulWidget {
  const TimePickerFormField({super.key});

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
        _timeController.text = DateFormat('HH:mm')
            .format(DateTime(0, 0, 0, selectedTime.hour, selectedTime.minute));
      });
    }
  }

  TextEditingController _timeController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextFormField(
              controller: _timeController,
              decoration: const InputDecoration(
                labelText: "Godzina zdarzenia",
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
            icon: Icon(Icons.access_time),
          ),
        ],
      ),
    );
  }
}
