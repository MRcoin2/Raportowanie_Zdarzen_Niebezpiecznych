import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/authentication/auth_dialog.dart';

class MainForm extends StatefulWidget {
  const MainForm({super.key});

  @override
  State<MainForm> createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _affiliationController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();
  late String status;
  List<String> categories = [
    "napaść na kuratora (słowna)",
    "napaść na kuratora (fizyczna)",
    "pogryzienie przez zwierzę",
    "zniszczenie ubrania",
    "zniszczenie mienia (np uszkodzenie samochodu)",
    "wypadek podczas wykonywania czynności służbowych (np złamanie, zasłabnięcie)",
    "zarażenie się chorobą",
    "groźby pod adresem kuratora",
    "inne...",
  ];
  bool isCategoryOther = false;

  Future<void> _dialogBuilder(BuildContext context, String email) {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
      return AuthDialog(email: email);
    });
  }
  
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
                      controller: _nameController,
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
                      controller: _surnameController,
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
              Row(
                children: [
                  Expanded(
                    child: MainFormField(
                      controller: _emailController,
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
                  ),ElevatedButton(onPressed: ()=>_dialogBuilder(context, _emailController.text), child: Text("zwerfikuj"))
                ],
              ),
              MainFormField(
                controller: _affiliationController,
                labelText: "Nazwa sądu i zespołu kuratorskiego",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić nazwę sądu i zespołu kuratorskiego';
                  }
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField(
                  items: const [
                    DropdownMenuItem(
                      value: "Kurator zawodowy",
                      child: Text("Kurator zawodowy"),
                    ),
                    DropdownMenuItem(
                      value: "Kurator społeczny",
                      child: Text("Kurator społeczny"),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: "Status kuratora",
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Proszę wybrać status';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      status = value!;
                    });
                  },
                ),
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
                  Expanded(
                      child: DatePickerFormField(
                    dateController: _dateController,
                  )),
                  Expanded(
                      child: TimePickerFormField(
                    timeController: _timeController,
                  )),
                ],
              ),
              MainFormField(
                controller: _placeController,
                labelText: "Miejsce zdarzenia",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proszę wprowadzić miejsce zdarzenia';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField(
                        items: [
                          ...categories.map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis),
                              )))
                        ],
                        decoration: const InputDecoration(
                          labelText: "Kategoria zdarzenia",
                          hintStyle: TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                        isExpanded: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Proszę wybrać kategorię zdarzenia';
                          }
                          if (value == "inne...") {
                            return null;
                          }
                          _otherCategoryController.text = value;
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            status = value!;
                            if (value == "inne...") {
                              isCategoryOther = true;
                            } else {
                              isCategoryOther = false;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  isCategoryOther
                      ? Expanded(
                          child: MainFormField(
                            controller: _otherCategoryController,
                            labelText: "Inna kategoria zdarzenia",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Proszę wprowadzić inną kategorię zdarzenia';
                              }
                              return null;
                            },
                          ),
                        )
                      : Container(),
                ],
              ),
              MainFormField(
                controller: _descriptionController,
                labelText: "Opis zdarzenia",
                maxLines: 5,
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
              child: const Text("Wyślij"),
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
  final TextEditingController controller;
  final int? maxLines;

  const MainFormField(
      {super.key,
      required this.labelText,
      required this.validator,
      required this.controller,
      this.maxLines});

  @override
  State<MainFormField> createState() => _MainFormFieldState();
}

class _MainFormFieldState extends State<MainFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        maxLines: widget.maxLines ?? 1,
        decoration: InputDecoration(
          labelText: widget.labelText,
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
