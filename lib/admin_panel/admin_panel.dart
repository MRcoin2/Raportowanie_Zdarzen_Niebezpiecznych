import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/panel_widgets.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/providers.dart';

import '../main_form/database_communication.dart';

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
        ChangeNotifierProvider(create: (context) => DataAndSelectionManager()),
      ],
      child: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.data == null || snapshot.data!.isAnonymous) {
            // No user is signed in, redirect to login page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/admin-login');
            });
            return const SizedBox.shrink();
          } else {
            // User is signed in, show admin panel
            return Scaffold(
              appBar: AppBar(
                forceMaterialTransparency: true,
                title: const Text('Admin Panel'),
                actions: [
                  ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context)
                          .pushReplacementNamed('/admin-login');
                    },
                    child: const Text('Logout'),
                  ),
                ],
              ),
              body: Center(
                child: FutureBuilder(
                  future:
                      context.read<DataAndSelectionManager>().fetchReports(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SideMenuBar(),
                        Column(
                          children: [
                            //logout button

                            SizedBox(
                              width: MediaQuery.of(context).size.width /
                                          MediaQuery.of(context).size.height >
                                      1
                                  ? MediaQuery.of(context).size.width * 0.250
                                  : double.infinity,
                              child: const TopMenuBar(),
                            ),
                            Consumer<DataAndSelectionManager>(
                              builder: (context, reportData, child) {
                                return Expanded(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width /
                                                MediaQuery.of(context)
                                                    .size
                                                    .height >
                                            1
                                        ? MediaQuery.of(context).size.width *
                                            0.250
                                        : double.infinity,
                                    child: ListView.builder(
                                      itemBuilder: (context, index) {
                                        if (index <
                                            context
                                                .read<DataAndSelectionManager>()
                                                .reports
                                                .length) {
                                          return ReportListElement(
                                            report: context
                                                .read<DataAndSelectionManager>()
                                                .reports[index],
                                          );
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        Expanded(
                          child: Consumer(builder: (context, reportData, _) {
                            Report? report = context
                                .watch<DataAndSelectionManager>()
                                .highlighted;
                            if (report == null) {
                              return const SizedBox.shrink();
                            } else {
                              return ReportDisplayCard(report);
                            }
                          }),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
