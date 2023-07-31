import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/providers.dart';

import '../main_form/database_communication.dart';

class ReportListElement extends StatefulWidget {
  late final Report report;

  ReportListElement({super.key, required this.report});

  @override
  State<ReportListElement> createState() => _ReportListElementState();
}

class _ReportListElementState extends State<ReportListElement> {
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
                    widget.report.incidentData['category'],
                    style: Theme.of(context).textTheme.titleLarge,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  Text(
                    widget.report.incidentData['date'].toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    widget.report.incidentData['description'],
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
                                .deleteReport(widget.report);
                          },
                          icon: Icon(Icons.delete_outline)),
                      IconButton(
                          onPressed: () {
                            context
                                .read<DataAndSelectionManager>()
                                .toggleSelection(widget.report);
                          },
                          icon: context
                                  .watch<DataAndSelectionManager>()
                                  .isSelected(widget.report)
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

class ReportDisplayCard extends StatelessWidget {
  final Report report;

  const ReportDisplayCard(this.report, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.incidentData['category']??'',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              report.incidentData['date']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.incidentData['description']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.incidentData['location']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.personalData['name']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.personalData['email']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.personalData['phone']??'',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
