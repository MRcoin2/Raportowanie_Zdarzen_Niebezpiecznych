import 'dart:html';

import 'package:flutter/material.dart';

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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.33,
            child: Column(
              children: [
                MainFormField(
                  labelText: "Imię",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić imię';
                    }
                    return null;
                  },
                ),
                MainFormField(
                  labelText: "Nazwisko",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić nazwisko';
                    }
                    return null;
                  },
                ),
                MainFormField(
                  labelText: "E-mail służbowy",
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !RegExp(r'^.*\..*@.*\.s.*\.gov\.pl$').hasMatch(value)) {
                      return 'Proszę wprowadzi poprawny e-mail kończący się na @*.s*.gov.pl';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          const Text(
            'Dane zdarzenia:',
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.33,
            child: Column(
              children: [
                DatePickerFormField(),
                MainFormField(
                  labelText: "Godzina zdarzenia",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wprowadzić godzinę zdarzenia';
                    }
                    return null;
                  },
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
        _dateController.text = "${selectedDate.day}.${selectedDate.month}.${selectedDate.year}";
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
              ),
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

// ),IconButton(onPressed: ()=>_selectDate,  icon: Icon(Icons.calendar_month),
