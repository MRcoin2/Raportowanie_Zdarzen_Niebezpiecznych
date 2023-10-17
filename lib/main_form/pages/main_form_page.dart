import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../form_widgets/form.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key, required this.title});

  final String title;

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Raportowanie Zdarzeń Niebezpiecznych",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Image.asset("assets/images/logo_krk_100.jpg",
                              height: 100, width: 100, isAntiAlias: false),
                        ),
                      ],
                    ),
                  ),
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
                          padding: EdgeInsets.all(8.0),
                          child: FutureBuilder(
                            future: FirebaseFirestore.instance
                                .collection("settings")
                                .doc("mainForm")
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
                    padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
                    child: Card(
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
                          child: const Center(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: MainForm(key: Key("main-form")),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
