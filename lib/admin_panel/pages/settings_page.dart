import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../panel_widgets/panel_widgets.dart';
import '../providers.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _mainFormHelpController = TextEditingController();
  TextEditingController _addInfoPageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => DataAndSelectionManager()),
      ],
      child: FutureBuilder<User?>(
        future: FirebaseAuth.instance
            .authStateChanges()
            .first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.data == null || snapshot.data!.isAnonymous) {
            // No user is signed in, redirect to login page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).popAndPushNamed('/admin-login');
            });
            return const SizedBox.shrink();
          } else {
            // User is signed in, show admin panel
            return Scaffold(
              appBar: AppBar(
                forceMaterialTransparency: true,
                title: const Text('Ustawienia'),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).popAndPushNamed('/admin-login');
                    },
                    child: const Text('Wyloguj'),
                  ),
                ],
              ),
              body: FutureBuilder(
                  future: context.read<DataAndSelectionManager>()
                      .fetchSettings(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: SizedBox(width: 50,
                        height: 50,
                        child: CircularProgressIndicator(),),);
                    }
                    else {
                      _mainFormHelpController.text =
                          snapshot.data?.mainForm["description"] ?? "";
                      _addInfoPageController.text =
                          snapshot.data?.addInfo["description"] ?? "";
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(flex: 1, child: SideMenuBar(
                            description: "Strona kosza\n\nZnajdują się tu usunięte zgłoszenia. Można je z tąd usunąć trwale. Będą one tu przechowywane bezterminowo do momentu trwałego usunięcia.",)),
                          Expanded(
                            flex: 3,
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Form(
                                  child: Column(
                                    children: [
                                      Text("Opis do głównej ankiety:"),
                                      TextFormField(
                                        controller: _mainFormHelpController,
                                        maxLines: 5,),
                                      Divider(),
                                      Text(
                                          "Opis do strony dodatkowych informacji:"),
                                      TextFormField(
                                        maxLines: 5,
                                        controller: _addInfoPageController,),
                                      Padding(padding: EdgeInsets.all(8.0),
                                        child: FilledButton(onPressed: () {
                                          context.read<
                                              DataAndSelectionManager>()
                                              .updateSettings(Settings(
                                              {
                                                "description": _mainFormHelpController
                                                    .text
                                              }, {
                                            "description": _addInfoPageController
                                          }));
                                        }, child: Text("Zapisz"),),)
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  }
              ),
            );
          }
        },
      ),
    );
  }
}
