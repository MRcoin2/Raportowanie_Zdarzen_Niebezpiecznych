import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/authentication/form_auth_dialog.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/database_communication.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/form_widgets/form_fields.dart';
import 'package:image_picker/image_picker.dart';

import '../../authentication/secrets/api_key.dart';
import 'package:http/http.dart' as http;

final List<String> categories = [
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

class MainForm extends StatefulWidget {
  const MainForm({super.key});

  @override
  State<MainForm> createState() => _MainFormState();
}

class _MainFormState extends State<MainForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _affiliationController = TextEditingController();
  late String _chosenStatus;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _otherCategoryController =
      TextEditingController();
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  late String _chosenCategory;
  bool _isCategoryOther = false;

  bool _verificationStatus = false;

  bool _agreementStatus = false;
  String _lastVerifiedEmail = "";

  Future<void> _authDialogBuilder(BuildContext context, String email) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AuthDialog(email: email);
        }).then((verificationStatus) {
      setState(() {
        _verificationStatus = verificationStatus;
        if (_verificationStatus) {
          _lastVerifiedEmail = email;
        }
      });
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
          Text(
            'Dane osobowe:',
            style: Theme.of(context).textTheme.titleMedium,
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
                      formKey: _emailKey,
                      sufixIcon: _verificationStatus
                          ? const Icon(Icons.how_to_reg)
                          : const Icon(Icons.person_off),
                      controller: _emailController,
                      labelText: "E-mail służbowy",
                      validator: (value) {
                        if (_lastVerifiedEmail != _emailController.text &&
                            _lastVerifiedEmail.isNotEmpty) {
                          _verificationStatus = false;
                          return 'Proszę zweryfikować e-mail';
                        }
                        if (value == null ||
                            value.isEmpty ||
                            !RegExp(r'^.*\..*@.*\.s.*\.gov\.pl$')
                                .hasMatch(value)) {
                          return 'Proszę wprowadzić poprawny e-mail kończący się na @*.s*.gov.pl';
                        } else if (!_verificationStatus) {
                          return 'Proszę zweryfikować e-mail';
                        }
                        return null;
                      },
                    ),
                  ),
                  !_verificationStatus
                      ? ElevatedButton(
                          style: ButtonStyle(
                              elevation: MaterialStateProperty.all(4)),
                          onPressed: () {
                            if (RegExp(r'^.*\..*@.*\.s.*\.gov\.pl$')
                                .hasMatch(_emailController.text)) {
                              //TODO remove true when done testing
                              _authDialogBuilder(
                                  context, _emailController.text);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Proszę wprowadzić poprawny e-mail kończący się na @*.s*.gov.pl"),
                                ),
                              );
                            }
                          },
                          child: const Text("zwerfikuj"))
                      : Container(),
                ],
              ),
              MainFormField(
                controller: _phoneController,
                labelText: "Numer Telefonu (opcjonalnie)",
                validator: (value) {
                  if (value!.isNotEmpty &&
                      !RegExp(r'^\d{9}$').hasMatch(value)) {
                    return 'Proszę wprowadzić poprawny numer telefonu lub nie wprowadzać nic';
                  }
                  return null;
                },
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
                      _chosenStatus = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          Text(
            'Dane zdarzenia:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: DatePickerFormField(
                    dateController: _dateController,
                    labelText: "Data zdarzenia",
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
                            _chosenCategory = value!;
                            if (value == "inne...") {
                              _isCategoryOther = true;
                            } else {
                              _isCategoryOther = false;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                  _isCategoryOther
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: OutlinedButton(
                  // disable button when more then 10 imabes uploaded
                  onPressed: _images.length >= 10
                      ? null
                      : () {
                          _picker
                              .pickMultiImage(imageQuality: 50)
                              .then((files) {
                            if (files.length + _images.length > 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Można dodać maksymalnie 10 zdjęć"),
                                ),
                              );
                            } else {
                              setState(() {
                                _images.addAll(files);
                              });
                            }
                          });
                        },
                  child: const Text("Dodaj Zdjęcia (opcjonalne)"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Dodano ${_images.length}/10 zdjęć"),
              ),
              //clear added images
              IconButton(
                onPressed: () {
                  setState(() {
                    _images.clear();
                  });
                },
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
          _images.isEmpty
              ? Container()
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.height /
                              MediaQuery.of(context).size.width <
                          1
                      ? MediaQuery.of(context).size.width * 0.50
                      : double.infinity,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: _images[index].readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Stack(children: [
                              Card(
                                elevation: 4,
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: Image.memory(
                                    snapshot.data as Uint8List,
                                  ),
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _images.removeAt(index);
                                    });
                                  },
                                  icon: const Icon(Icons.clear))
                            ]);
                          }
                          return const CircularProgressIndicator();
                        },
                      );
                    },
                  ),
                ),
          CheckboxFormField(
            title: const Text(
                "Zgadzam się na przetwarzanie moich danych osobowych w celu zbierania informacji o niebezpieczeństwach w pracy kuratora."),
            onSaved: (value) => setState(() {
              _agreementStatus = value!;
            }),
            validator: (value) {
              if (value == null || !value) {
                return 'Proszę wyrazić zgodę na przetwarzanie danych osobowych';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  //TODO remove true when done testing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Przetwarzanie danych...')),
                  );
                  BuildContext? dialogContext;
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        dialogContext = context;
                        return const AlertDialog(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  "Przetwarzanie danych...\n(może to chwilę zająć - proszę czekać)"),
                              SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Center(
                                      child: CircularProgressIndicator())),
                            ],
                          ),
                        );
                      });
                  try {
                    Report report = Report(
                        id: "",
                        hasBeenEdited: false,
                        additionalInfo: "",
                        reportTimestamp: DateTime.now(),
                        personalData: {
                          "name": _nameController.text,
                          "surname": _surnameController.text,
                          "phone": _phoneController.text,
                          "email": _emailController.text,
                          "affiliation": _affiliationController.text,
                          "status": _chosenStatus,
                        },
                        incidentData: {
                          "incident timestamp": DateFormat('dd.MM.yyyy hh:mm')
                              .parse(
                                  "${_dateController.text} ${_timeController.text}"),
                          "date": _dateController.text,
                          "time": _timeController.text,
                          "location": _placeController.text,
                          "category": _chosenCategory == "inne..."
                              ? _otherCategoryController.text
                              : _chosenCategory,
                          "description": _descriptionController.text,
                        });
                    String id = await submitForm(report.toMap(), _images);
                    report.id = id;
                    report.imageUrls = await report.getImageUrls();
                    //clear form
                    _nameController.clear();
                    _surnameController.clear();
                    _emailController.clear();
                    _phoneController.clear();
                    _affiliationController.clear();
                    _dateController.clear();
                    _timeController.clear();
                    _placeController.clear();
                    _descriptionController.clear();
                    _otherCategoryController.clear();
                    _images.clear();
                    _formKey.currentState?.reset();

                    //notify user
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Navigator.pop(dialogContext!);
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          dialogContext = context;
                          return AlertDialog(
                            icon: const Icon(Icons.check),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pushReplacementNamed("/");
                                  },
                                  child: const Text("Ok"))
                            ],
                            content: const Text(
                                "Zgłoszenie wysłano pomyślnie.\nNa podany adres email wysłano potwierdzenie z linkiem do dodania informacji o zakończeniu zdarzenia."),
                          );
                        });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Zgłoszenie wysłano pomyślnie')),
                    );
                    await http.post(Uri.https(API_URL, 'confirm-submission'),
                        body: json.encode({
                          'api_key': API_KEY,
                          'data': {
                            'id': id,
                            'additionalInfo': '',
                            'hasBeenEdited': false,
                            "report timestamp":
                                report.reportTimestamp.millisecondsSinceEpoch /
                                    1000,
                            "personal data": {
                              "phone": report.personalData['phone'],
                              "affiliation": report.personalData['affiliation'],
                              "name": report.personalData['name'],
                              "status": report.personalData['status'],
                              "email": report.personalData['email'],
                              "surname": report.personalData['surname']
                            },
                            "incident data": {
                              "incident timestamp": report
                                      .incidentData['incident timestamp']
                                      .millisecondsSinceEpoch /
                                  1000,
                              "time": report.incidentData['time'],
                              "category": report.incidentData['category'],
                              "location": report.incidentData['location'],
                              "date": report.incidentData['date'],
                              "description": report.incidentData['description']
                            },
                            "images": report.imageUrls,
                          },
                        }));
                  } catch (e) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    Navigator.pop(dialogContext!);
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          dialogContext = context;
                          return AlertDialog(
                            icon: const Icon(Icons.error),
                            actions: [
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Ok"))
                            ],
                            content: const Center(
                              child: Text(
                                  "Wystąpił błąd podczas wysyłania zgłoszenia"),
                            ),
                          );
                        });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Wystąpił błąd podczas wysyłania zgłoszenia')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Proszę wypełnić wszystkie wymagane pola')),
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
