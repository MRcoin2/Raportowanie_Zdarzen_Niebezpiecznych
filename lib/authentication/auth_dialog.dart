import 'package:flutter/material.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';

const API_URL = "https://rosowski.me";

enum codeInputStatus {
  inputting,
  pendingVerification,
  verificationSuccess,
  verificationFailure
}

class AuthDialog extends StatefulWidget {
  final String email;

  AuthDialog({super.key, required this.email});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  String _code = "";
  bool _onEditing = true;
  codeInputStatus _status = codeInputStatus.inputting;

  @override
  void initState() {
    // TODO: make a call to the api to send a verification code
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Builder(
          //todo scrap this, make rest api on a remote server that also serves as a mailserver and send the verification email from there. SETUP HTTPS FOR SECURITY OF THE OTP
          builder: (context) {
            if (_status == codeInputStatus.pendingVerification) {
              return FutureBuilder(
                future: Future.delayed(Duration(seconds: 3)),//TODO make a call to the api to verify the code
                builder: (context,snapshot) {
                  if (snapshot.connectionState == ConnectionState.done)
                    return FutureBuilder(
                      future: Future.delayed(const Duration(seconds: 2)),
                      builder: (context, snapshot) {
                        // close dialog when email is verified
                        if (snapshot.connectionState == ConnectionState.done) {
                          Navigator.of(context).pop();
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
                                    : const Icon(Icons.no_accounts,
                                    size: 48.0, color: Colors.redAccent),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop("ok");
                                  },
                                  child: const Text("ok")),
                            ],
                          ),
                        );
                      },
                    );
                  else {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              "Weryfikowanie kodu..."),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      ),
                    );
                  }
                });
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        "Wpisz kod wysłany na podanego maila aby potwierdzić swoją tożsamość."),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: VerificationCode(
                        textStyle: const TextStyle(fontSize: 20.0),
                        keyboardType: TextInputType.number,
                        underlineColor: Colors.amber,
                        // If this is null it will use primaryColor: Colors.red from Theme
                        length: 4,
                        cursorColor: Colors.blue,
                        // If this is null it will default to the ambient
                        // clearAll is NOT required, you can delete it
                        // takes any widget, so you can implement your design
                        onCompleted: (String value) {
                          setState(() {
                            _code = value;
                            _status = codeInputStatus.pendingVerification;
                          });
                        },
                        onEditing: (bool value) {
                          setState(() {
                            _onEditing = value;
                          });
                          if (!_onEditing) FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop("cancel");
                        },
                        child: const Text("cancel")),
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
