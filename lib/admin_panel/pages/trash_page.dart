import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/panel_widgets/panel_widgets.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/providers.dart';

import '../../main_form/database_communication.dart';

class TrashPage extends StatefulWidget {
  const TrashPage({super.key});

  @override
  State<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  @override
  Widget build(BuildContext context) {
    return Portal(
      child: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
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
                title: const Text('Kosz'),
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
              body: Center(
                child: FutureBuilder(
                  future:
                      context.read<DataAndSelectionManager>().fetchTrash(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Expanded(flex: 1, child: SideMenuBar(description: "Strona kosza\n\nZnajdują się tu usunięte zgłoszenia. Można je z tąd usunąć trwale. Będą one tu przechowywane bezterminowo do momentu trwałego usunięcia.",)),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              const TopMenuBar(pageType: PageType.trashPage),
                              Consumer<DataAndSelectionManager>(
                                builder: (context, reportData, child) {
                                  return Expanded(
                                      child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width /
                                                MediaQuery.of(context)
                                                    .size
                                                    .height >
                                            1
                                        ? MediaQuery.of(context).size.width *
                                            0.250
                                        : double.infinity,
                                    child: NotificationListener<
                                        ScrollEndNotification>(
                                      onNotification: (notification) {
                                        if (notification.metrics.pixels > 0 &&
                                            notification.metrics.atEdge) {
                                          context
                                              .read<DataAndSelectionManager>()
                                              .fetchMoreTrash();
                                        }
                                        return true;
                                      },
                                      child: ListView.builder(
                                        itemBuilder: (context, index) {
                                          if (index <
                                              context
                                                  .read<
                                                      DataAndSelectionManager>()
                                                  .trash
                                                  .length) {
                                            return TrashListElement(
                                              report: context
                                                  .read<
                                                      DataAndSelectionManager>()
                                                  .trash[index],
                                            );
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ));
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 2,
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
