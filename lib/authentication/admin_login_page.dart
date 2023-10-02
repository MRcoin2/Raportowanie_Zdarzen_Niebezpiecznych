import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/authentication/secrets/api_key.dart';
import 'package:http/http.dart' as http;

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _totpController = TextEditingController();
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.height /
                      MediaQuery.of(context).size.width <
                  1
              ? MediaQuery.of(context).size.width * 0.40
              : double.infinity,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Proszę wprowadzić email';
                          }
                          return null;
                        },
                        focusNode: _focusNode1,
                        onFieldSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_focusNode2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Hasło'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Proszę wprowadzić hasło';
                          }
                          return null;
                        },
                        focusNode: _focusNode2,
                        onFieldSubmitted: (_) => _signIn(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: FilledButton(
                          onPressed: _signIn,
                          child: const Text('Zaloguj się'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        var response = await http.post(Uri.https(API_URL,'verify-user'),
            body: json.encode({
              'api_key': API_KEY,
              'email': _emailController.text,
              'password': _passwordController.text,
            }));
        if (response.statusCode == 200) {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Weryfikacja Dwuetapowa'),
                  content: SizedBox(
                    width: 300,
                    height: 100,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Kod 2FA'),
                          controller: _totpController,
                          maxLength: 6,
                          obscureText: false,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Proszę wprowadzić kod 2FA';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          http
                              .post(
                                Uri.https(API_URL,'verify-totp'),
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode({
                                  'api_key': API_KEY,
                                  'email': _emailController.text,
                                  'password': _passwordController.text,
                                  'totp': _totpController.text,
                                }),
                              )
                              .then(
                                  (value) => Navigator.of(context).pop(value));
                        },
                        child: const Text('Zwerfikuj')),
                  ],
                );
              }).then((value) async {
            try {
              print(value.body);
              await FirebaseAuth.instance.signInWithCustomToken(value.body);
              Navigator.of(context).popAndPushNamed('/admin-panel');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wprowadzono nieprawidłowy kod 2FA')),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nieprawidłowy email lub hasło')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wystąpił błąd podczas logowania')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
}
