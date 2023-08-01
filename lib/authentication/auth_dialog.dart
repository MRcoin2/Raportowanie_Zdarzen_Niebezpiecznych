import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'secrets/api_key.dart';

enum codeInputStatus {
  inputting,
  pendingVerification,
  verificationSuccess,
  verificationFailure
}

Future<bool> verifyCode(String code, String email) async {
  //make a POST request to API_URL/verify-otp with the email and code in the data of the https request
  //if the response is 200, return true, else return false
  var response = await http.post(Uri.parse('$API_URL/verify-otp'),
      body: json.encode({'api_key': API_KEY, 'email': email, 'otp': code}));
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

Future sendCode(String email) async {
  //make a POST request to API_URL/send-otp with the email in the data of the https request
  //if the response is 200, return true, else return false
  var response = await http.post(Uri.parse('$API_URL/send-otp'),
      body: json.encode({"email": email, "api_key": API_KEY, "otp_length": 4}));
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

class AuthDialog extends StatefulWidget {
  final String email;

  const AuthDialog({super.key, required this.email});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  String _code = "";
  bool _verified = false;
  codeInputStatus _status = codeInputStatus.inputting;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    //send the code to the user's email on dialog creation
    sendCode(widget.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Builder(
          builder: (context) {
            if (_status == codeInputStatus.pendingVerification) {
              return FutureBuilder(
                future: verifyCode(_code, widget.email).then((value) {
                  if (value) {
                    _verified = true;
                    _status = codeInputStatus.verificationSuccess;
                  } else {
                    _status = codeInputStatus.verificationFailure;
                  }
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return FutureBuilder(
                      future: Future.delayed(const Duration(seconds: 2)),
                      builder: (context, snapshot) {
                        // close dialog when email is verified
                        if (snapshot.connectionState == ConnectionState.done) {
                          Navigator.of(context).pop(_verified);
                        }
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _status == codeInputStatus.verificationSuccess
                                  ? const Text("E-mail zweryfikowano.")
                                  : const Text(
                                      "Nie udało się zweryfikować tożsamości"),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: _status ==
                                        codeInputStatus.verificationSuccess
                                    ? const Icon(Icons.check_circle_outline,
                                        size: 48.0, color: Colors.green)
                                    : Icon(Icons.no_accounts,
                                        size: 48.0,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(_verified);
                                  },
                                  child: const Text("ok")),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Weryfikowanie kodu..."),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Wpisz kod wysłany na podanego maila aby potwierdzić swoją tożsamość.",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: "Kod",
                          constraints: BoxConstraints(maxWidth: 200.0),
                        ),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        onEditingComplete: () {
                          setState(() {
                            _code = _codeController.text;
                            _status = codeInputStatus.pendingVerification;
                          });
                        },
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FilledButton(
                              onPressed: () {
                                setState(() {
                                  _code = _codeController.text;
                                  _status = codeInputStatus.pendingVerification;
                                });
                              },
                              child: const Text("Zweryfikuj")),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(_verified);
                              },
                              child: const Text("anuluj")),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
