import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../authentication/secrets/api_key.dart';
import '../panel_widgets/panel_widgets.dart';
import '../providers.dart';
import 'package:http/http.dart' as http;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _mainFormHelpController = TextEditingController();
  final TextEditingController _addInfoPageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataAndSelectionManager()),
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
                      FirebaseAuth.instance.signOut();
                      Navigator.of(context).popAndPushNamed('/admin-login');
                    },
                    child: const Text('Wyloguj'),
                  ),
                ],
              ),
              body: FutureBuilder(
                  future:
                  context.read<DataAndSelectionManager>().fetchSettings(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      _mainFormHelpController.text =
                          snapshot.data?.mainForm["description"] ?? "";
                      _addInfoPageController.text =
                          snapshot.data?.addInfo["description"] ?? "";
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Expanded(
                              flex: 1,
                              child: SideMenuBar(
                                description:
                                "Strona ustawień\n\nNa tej stronie można zmienić wiadomości wyświetlane nad główną ankietą i nad panelem dodawania informacji do zgłoszenia, oraz można dodać nowego administratora.",
                              )),
                          Expanded(
                            flex: 2,
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Opis do głównej ankiety:"),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          controller: _mainFormHelpController,
                                          maxLines: 5,
                                        ),
                                      ),
                                      const Divider(),
                                      const Text(
                                          "Opis do strony dodatkowych informacji:"),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: TextFormField(
                                          maxLines: 5,
                                          controller: _addInfoPageController,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FilledButton(
                                          onPressed: () {
                                            context
                                                .read<DataAndSelectionManager>()
                                                .updateSettings(InterfaceSettings({
                                              "description":
                                              _mainFormHelpController
                                                  .text
                                            }, {
                                              "description":
                                              _addInfoPageController.text
                                            }));
                                          },
                                          child: const Text("Zapisz"),
                                        ),
                                      ),
                                      const Divider(),
                                      const Text("Dodawanie administratorów:"),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller: _emailController,
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty || !value.contains("@")) {
                                                    return 'Proszę wprowadzić email';
                                                  }
                                                  return null;
                                                },
                                                decoration: const InputDecoration(
                                                  labelText: "Email",
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: TextFormField(
                                                controller: _passwordController,
                                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty || value.length < 6) {
                                                    return 'Proszę wprowadzić hasło dłuższe niż 6 znaków';
                                                  }
                                                  return null;
                                                },
                                                obscureText: true,
                                                decoration: const InputDecoration(
                                                  labelText: "Hasło",
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: FilledButton(
                                          onPressed: () async {
                                            try {
                                              var response = await http.post(
                                                Uri.https(
                                                    API_URL, 'create-user'),
                                                body: json.encode({
                                                  'api_key': API_KEY,
                                                  'id_token': await FirebaseAuth
                                                      .instance.currentUser!
                                                      .getIdToken(),
                                                  'email': _emailController
                                                      .text,
                                                  'password': _passwordController
                                                      .text,
                                                }),);
                                              if (response.statusCode == 200){
                                                FirebaseFirestore.instance.collection("admins").doc(json.decode(response.body)["uid"]).set(
                                                    {});
                                                showDialog(context: context, builder: (context){
                                                  return Center(
                                                    child: Card(
                                                      elevation: 4,
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [Padding(
                                                            padding: const EdgeInsets.all(8.0),
                                                            child: Text("Sekret werfikacji dwuetapowej: ${json.decode(response.body)["totp_secret"]}"),
                                                          ),
                                                            QrImageView(
                                                              data: "otpauth://totp/KRK:${_emailController.text.toLowerCase().replaceAll(" ", "")}?secret=${json.decode(response.body)["totp_secret"]}&issuer=KRK",
                                                              version: QrVersions.auto,
                                                              size: 200.0,
                                                              backgroundColor: Colors.white,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                });
                                              }
                                            }
                                            catch(e){
                                              showDialog(context: context, builder: (context){
                                                return const AlertDialog(
                                                  title: Text("Błąd"),
                                                  content: Text("Nie udało się dodać administratora"),
                                                );
                                              });
                                              return;
                                            }
                                          },
                                          child: const Text("Dodaj"),
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Spacer(flex: 1,)
                        ],
                      );
                    }
                  }),
            );
          }
        },
      ),
    );
  }
}
