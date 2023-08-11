
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/panel_widgets/panel_widgets.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/providers.dart';

import '../../main_form/database_communication.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  @override
  Widget build(BuildContext context) {
    return Portal(
      child: MultiProvider(
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
                Navigator.of(context).popAndPushNamed('/admin-login');
              });
              return const SizedBox.shrink();
            } else {
              // User is signed in, show admin panel
              return Scaffold(
                appBar: AppBar(
                  forceMaterialTransparency: true,
                  title: const Text('Zatwierdzone'),
                  actions: [
                    ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context)
                            .popAndPushNamed('/admin-login');
                      },
                      child: const Text('Wyloguj'),
                    ),
                  ],
                ),
                body: Center(
                  child: FutureBuilder(
                    future:
                    context.read<DataAndSelectionManager>().fetchArchive(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SideMenuBar(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width /
                                MediaQuery.of(context).size.height > 1
                                ? MediaQuery.of(context).size.width * 0.250
                                : double.infinity,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width /
                                      MediaQuery.of(context).size.height > 1
                                      ? MediaQuery.of(context).size.width * 0.250
                                      : double.infinity,
                                  child: const TopMenuBar(pageType: PageType.archivePage),
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
                                                    .archivedReports
                                                    .length) {
                                              return ArchiveListElement(
                                                report: context
                                                    .read<DataAndSelectionManager>()
                                                    .archivedReports[index],
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
      ),
    );
  }
}
