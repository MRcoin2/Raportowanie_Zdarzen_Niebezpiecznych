import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../database_communication.dart';
import '../form_widgets/form_fields.dart';

class AddInfoPage extends StatefulWidget {
  final String reportId;

  AddInfoPage({super.key, required this.reportId});

  @override
  State<AddInfoPage> createState() => _AddInfoPageState();
}

class _AddInfoPageState extends State<AddInfoPage> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();

  final List<XFile> _images = [];

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
            future: hasReportBeenEdited(widget.reportId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator()));
              } else {
                print("document edited: $snapshot.data");
                if (snapshot.data == false) {
                  return SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Column(
                        children: [
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, bottom: 8.0, left: 18.0, right: 18.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.height /
                                    MediaQuery.of(context).size.width <
                                    1
                                    ? MediaQuery.of(context).size.width * 0.50
                                    : double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: FutureBuilder(
                                    future: FirebaseFirestore.instance
                                        .collection("settings")
                                        .doc("addInfo")
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox(width: 50,height: 50, child: Center(child: CircularProgressIndicator()));
                                      } else {
                                        return Text(
                                            snapshot.data!.data()?["description"]);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Dodawanie informacji do zgłoszenia: ${widget.reportId}",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          //
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 18.0, bottom: 18.0),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.8,
                              child: Card(
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0,
                                      bottom: 8.0,
                                      left: 18.0,
                                      right: 18.0),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.height /
                                                MediaQuery.of(context)
                                                    .size
                                                    .width <
                                            1
                                        ? MediaQuery.of(context).size.width *
                                            0.50
                                        : double.infinity,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Form(
                                          key: _formKey,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                'Dane dodatkowe:',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: MainFormField(
                                                            controller:
                                                                _descriptionController,
                                                            labelText:
                                                                "Opis zakończenia zdarzenia",
                                                            maxLines: 5,
                                                            validator: (value) {
                                                              if (value ==
                                                                      null ||
                                                                  value
                                                                      .isEmpty) {
                                                                return 'Proszę wprowadzić opis';
                                                              }
                                                              return null;
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: OutlinedButton(
                                                            // disable button when more then 10 images uploaded
                                                            onPressed:
                                                                _images.length >=
                                                                        10
                                                                    ? null
                                                                    : () {
                                                                        _picker
                                                                            .pickMultiImage(imageQuality: 50)
                                                                            .then((files) {
                                                                          if (files.length + _images.length >
                                                                              10) {
                                                                            ScaffoldMessenger.of(context).showSnackBar(
                                                                              const SnackBar(
                                                                                content: Text("Można dodać maksymalnie 10 zdjęć"),
                                                                              ),
                                                                            );
                                                                          } else {
                                                                            setState(() {
                                                                              _images.addAll(files);
                                                                            });
                                                                          }
                                                                        });
                                                                      },
                                                            child: const Text(
                                                                "Dodaj Zdjęcia (opcjonalne)"),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Text(
                                                              "Dodano ${_images.length}/10 zdjęć"),
                                                        ),
                                                        //clear added images
                                                        IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              _images.clear();
                                                            });
                                                          },
                                                          icon: const Icon(
                                                              Icons.clear),
                                                        ),
                                                      ],
                                                    ),
                                                    _images.isEmpty
                                                        ? Container()
                                                        : SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.3,
                                                            width: MediaQuery.of(context)
                                                                            .size
                                                                            .height /
                                                                        MediaQuery.of(context)
                                                                            .size
                                                                            .width <
                                                                    1
                                                                ? MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.50
                                                                : double
                                                                    .infinity,
                                                            child: GridView
                                                                .builder(
                                                              gridDelegate:
                                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                                crossAxisCount:
                                                                    5,
                                                              ),
                                                              itemCount: _images
                                                                  .length,
                                                              itemBuilder:
                                                                  (context,
                                                                      index) {
                                                                return FutureBuilder(
                                                                  future: _images[
                                                                          index]
                                                                      .readAsBytes(),
                                                                  builder: (context,
                                                                      snapshot) {
                                                                    if (snapshot
                                                                        .hasData) {
                                                                      return Stack(
                                                                          children: [
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
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: FilledButton(
                                                        onPressed: () async {
                                                          if (_formKey
                                                              .currentState!
                                                              .validate()) {
                                                            //TODO remove true when done testing
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Przetwarzanie danych...')),
                                                            );
                                                            try {
                                                              await updateReport(
                                                                  {
                                                                      "additionalInfo":
                                                                          _descriptionController
                                                                              .text,
                                                                    },
                                                                  _images,
                                                                  widget
                                                                      .reportId);
                                                              //notify user
                                                              ScaffoldMessenger.of(context).clearSnackBars();
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                const SnackBar(
                                                                    content: Text('Zgłoszenie zaktualizowano pomyślnie')),
                                                              );
                                                              //clear form
                                                              _formKey.currentState?.reset();
                                                                  Navigator.of(context).pushReplacementNamed("/");
                                                            } catch (e) {
                                                              print(e);
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .clearSnackBars();
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                    content: Text(
                                                                        'Wystąpił błąd podczas wysyłania zgłoszenia')),
                                                              );
                                                            }
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Proszę wypełnić wszystkie wymagane pola')),
                                                            );
                                                          }
                                                        },
                                                        child: const Text(
                                                            "Wyślij"),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  return Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Zgłoszenie było już edytowane."),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Ok"),
                          )
                        ],
                      ),
                    ),
                  );
                }
              }
            }),
      ),
    );
  }
}
