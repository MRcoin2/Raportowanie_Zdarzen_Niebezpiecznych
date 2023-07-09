import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/panel_widgets.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/providers.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => SelectionManager()),
        ChangeNotifierProvider(create: (context) => SubmissionData()),
      ],
      child: FutureBuilder<User?>(
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
              appBar: AppBar(
                title: Text('Admin Panel'),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context)
                          .pushReplacementNamed('/admin-login');
                    },
                    child: Text('Logout'),
                  ),
                ],
              ),
              body: Center(
                  child: Column(
                children: [
                  //logout button

                  SizedBox(
                    width: MediaQuery.of(context).size.width /
                                MediaQuery.of(context).size.height >
                            1
                        ? MediaQuery.of(context).size.width * 0.50
                        : double.infinity,
                    child: TopMenuBar(),
                  ),
                  FutureBuilder(
                      future: context.read<SubmissionData>().fetchSubmissions(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        return Consumer<SubmissionData>(
                          builder: (context, submissionData, child) {
                            return SizedBox(
                            height: 500,
                            width: MediaQuery.of(context).size.width /
                                        MediaQuery.of(context).size.height >
                                    1
                                ? MediaQuery.of(context).size.width * 0.50
                                : double.infinity,
                            child:
                                ListView.builder(itemBuilder: (context, index) {
                              print(index);
                              if (index < context.read<SubmissionData>().submissions.length) {
                                return SubmissionListElement(
                                  index: index,
                                );
                              }
                              return null;
                            }),
                          );}
                        );
                      }),
                ],
              )),
            );
          }
        },
      ),
    );
  }
}
