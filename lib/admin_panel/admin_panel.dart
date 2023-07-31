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
        ChangeNotifierProvider(create: (context) => DataAndSelectionManager()),
      ],
      child: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.data == null || snapshot.data!.isAnonymous) {
            // No user is signed in, redirect to login page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/admin-login');
            });
            return SizedBox.shrink();
          } else {
            // User is signed in, show admin panel
            return Scaffold(
              appBar: AppBar(
                forceMaterialTransparency: true,
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
                child: FutureBuilder(
                  future: context
                      .read<DataAndSelectionManager>()
                      .fetchSubmissions(),
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
                              child: TopMenuBar(),
                            ),
                            Consumer<DataAndSelectionManager>(
                              builder: (context, submissionData, child) {
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
                                        print(index);
                                        if (index <
                                            context
                                                .read<DataAndSelectionManager>()
                                                .submissions
                                                .length) {
                                          return SubmissionListElement(
                                            submission: context
                                                .read<DataAndSelectionManager>()
                                                .submissions[index],
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
                        Expanded(child:
                            Consumer(builder: (context, submissionData, _) {
                          return SubmissionDisplayCard(context
                              .read<DataAndSelectionManager>()
                              .submissions[0]);
                        })),
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
