import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.data == null) {
          // No user is signed in, redirect to login page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed('/admin-login');
          });
          return SizedBox.shrink();
        } else {
          // User is signed in, show admin panel
          return Scaffold(
            body: Center(child: Column(
              children: [
                Text('Admin Panel'),
                //logout button
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/admin-login');
                  },
                  child: Text('Logout'),
                ),
              ],
            )),
          );
        }
      },
    );
  }
}
