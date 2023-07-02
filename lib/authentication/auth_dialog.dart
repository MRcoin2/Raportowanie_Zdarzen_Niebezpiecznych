import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';

class AuthDialog extends StatefulWidget {
  final String email;

  AuthDialog({super.key, required this.email});



  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  EmailOTP emailAuth = EmailOTP();
  @override
  void initState() {
    super.initState();
    emailAuth.setConfig(
        appEmail: "",
        appName: "Email OTP",
        userEmail: widget.email,
        otpLength: 4,
        otpType: OTPType.digitsOnly
    );
    emailAuth.setSMTP(
        host: "smtp.gmail.com",
        auth: true,
        username: "",
        password: "",
        secure: "TLS",
        port: 576
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(//todo scrap this, make rest api on a remote server that also serves as a mailserver and send the verification email from there. SETUP HTTPS FOR SECURITY OF THE OTP
          future: emailAuth.sendOTP(),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("E-mail zweryfikowano."),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.check_circle_outline,
                          size: 48.0, color: Colors.green),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop("ok");
                        },
                        child: const Text("ok")),
                  ],
                ),
              );
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                        "Wejdź w link wysłany na podanego maila aby potwierdzić swoją tożsamość."),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
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
