import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/providers.dart';

import '../main_form/database_communication.dart';

class SubmissionListElement extends StatefulWidget {
  late final Submission submission;

  SubmissionListElement({super.key, required this.submission});

  @override
  State<SubmissionListElement> createState() => _SubmissionListElementState();
}

class _SubmissionListElementState extends State<SubmissionListElement> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.submission.eventData['category'],
                    style: Theme.of(context).textTheme.titleLarge,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    widget.submission.eventData['date'].toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    widget.submission.eventData['description'],
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          onPressed: () {
                            //TODO implement archiving
                          },
                          icon: Icon(Icons.archive_outlined)),
                      IconButton(
                          onPressed: () {
                            //TODO add a confirmation dialog
                            context
                                .read<DataAndSelectionManager>()
                                .deleteSubmission(widget.submission);
                          },
                          icon: Icon(Icons.delete_outline)),
                      IconButton(
                          onPressed: () {
                            context
                                .read<DataAndSelectionManager>()
                                .toggleSelection(widget.submission);
                          },
                          icon: context
                                  .watch<DataAndSelectionManager>()
                                  .isSelected(widget.submission)
                              ? Icon(Icons.check_box_outlined)
                              : Icon(Icons.check_box_outline_blank)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TopMenuBar extends StatefulWidget {
  const TopMenuBar({super.key});

  @override
  State<TopMenuBar> createState() => _TopMenuBarState();
}

class _TopMenuBarState extends State<TopMenuBar> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () {}, icon: Icon(Icons.sort)),
                  IconButton(
                      onPressed: () {}, icon: Icon(Icons.filter_alt_outlined))
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.archive_outlined),
                        tooltip: "Archiwizuj wszystkie zaznaczone",
                      ),
                      IconButton(
                        onPressed: () {
                          context
                              .read<DataAndSelectionManager>()
                              .deleteSelected();
                        },
                        icon: Icon(Icons.delete_sweep_outlined),
                        tooltip: "Usuń wszystkie zaznaczone",
                      ),
                      IconButton(
                        onPressed: () {
                          // read data from SubmissionData and pass it to SelectionManager to select all
                          context
                              .read<DataAndSelectionManager>()
                              .toggleSelectAll();
                        },
                        icon: context
                                .watch<DataAndSelectionManager>()
                                .isEverythingSelected
                            ? Icon(Icons.check_box_outlined)
                            : Icon(Icons.check_box_outline_blank),
                        tooltip: "Zaznacz wszystkie",
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SideMenuBar extends StatelessWidget {
  const SideMenuBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.home_outlined),
                title: Text("Strona główna"),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.document_scanner_outlined),
                title: Text("Generowanie raportu"),
                onTap: () {},
              ),
              Padding(padding: EdgeInsets.only(top: 8)),
              ListTile(
                leading: Icon(Icons.archive_outlined),
                title: Text("Archiwum"),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text("Kosz"),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.settings_outlined),
                title: Text("Ustawienia"),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubmissionDisplayCard extends StatelessWidget {
  final Submission submission;

  const SubmissionDisplayCard(this.submission, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              submission.eventData['category']??'',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              submission.eventData['date']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              submission.eventData['description']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              submission.eventData['location']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              submission.personalData['name']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              submission.personalData['email']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              submission.personalData['phone']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
