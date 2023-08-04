import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/panel_widgets/filter_panel.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/pdf_generation.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/providers.dart';

import '../../main_form/database_communication.dart';
class ReportListElement extends StatefulWidget {
  final Report report;

  const ReportListElement({super.key, required this.report});

  @override
  State<ReportListElement> createState() => _ReportListElementState();
}

class _ReportListElementState extends State<ReportListElement> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DataAndSelectionManager>().toggleHighlight(widget.report);
      },
      child: Card(
        surfaceTintColor:
            context.read<DataAndSelectionManager>().isHighlighted(widget.report)
                ? Colors.blue
                : Theme.of(context).cardTheme.color,
        elevation:
            context.read<DataAndSelectionManager>().isHighlighted(widget.report)
                ? 5
                : 2,
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      widget.report.incidentData['description'],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                            icon: const Icon(Icons.archive_outlined)),
                        IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'Czy na pewno chcesz usunąć to zgłoszenie?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text('Nie')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text('Tak')),
                                      ],
                                    );
                                  }).then((value) {
                                if (value) {
                                  context
                                      .read<DataAndSelectionManager>()
                                      .deleteReport(widget.report);
                                }
                              });
                            },
                            icon: const Icon(Icons.delete_outline)),
                        Checkbox(
                          value: context
                              .watch<DataAndSelectionManager>()
                              .isSelected(widget.report),
                          onChanged: (value) {
                            context
                                .read<DataAndSelectionManager>()
                                .toggleSelection(widget.report);
                          },
                        )
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
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
  bool isFilterMenuOpen = false;

  toggleMenu() {
    setState(() {
      isFilterMenuOpen = !isFilterMenuOpen;
    });
  }

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
                  IconButton(onPressed: () {}, icon: const Icon(Icons.sort)),
                  PortalTarget(
                    visible: isFilterMenuOpen,
                    portalFollower: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          isFilterMenuOpen = false;
                        });
                      },
                    ),
                    child: PortalTarget(
                      visible: isFilterMenuOpen,
                      anchor: const Aligned(
                        follower: Alignment.topLeft,
                        target: Alignment.topRight,
                      ),
                      portalFollower: FilterPanel(),
                      child: IconButton(
                          onPressed: () {
                            toggleMenu();
                          },
                          icon: Icon(Icons.filter_alt_outlined)),
                    ),
                  ),
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
                        icon: const Icon(Icons.archive_outlined),
                        tooltip: "Archiwizuj wszystkie zaznaczone",
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                      'Czy na pewno chcesz usunąć wszystkie zaznaczone zgłoszenia?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false);
                                        },
                                        child: const Text('Nie')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text('Tak')),
                                  ],
                                );
                              }).then((value) {
                            if (value) {
                              context
                                  .read<DataAndSelectionManager>()
                                  .deleteSelected();
                            }
                          });
                        },
                        icon: const Icon(Icons.delete_sweep_outlined),
                        tooltip: "Usuń wszystkie zaznaczone",
                      ),
                      Tooltip(
                        message: context
                                .watch<DataAndSelectionManager>()
                                .isEverythingSelected
                            ? "Odznacz wszystkie"
                            : "Zaznacz wszystkie",
                        child: Checkbox(
                          value: context
                              .watch<DataAndSelectionManager>()
                              .isEverythingSelected,
                          onChanged: (value) {
                            context
                                .read<DataAndSelectionManager>()
                                .toggleSelectAll();
                          },
                        ),
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text("Strona główna"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.document_scanner_outlined),
                title: const Text("Generowanie raportu"),
                onTap: () {
                  printReport(
                      context.read<DataAndSelectionManager>().highlighted!);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text("Archiwum"),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text("Kosz"),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text("Ustawienia"),
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.incidentData['category'] ?? '',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              report.incidentData['date'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.incidentData['description'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.incidentData['location'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.personalData['name'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.personalData['email'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              report.personalData['phone'] ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

//show a widget on top of the currently displayed page in the location of the widget that called this function
void showOverlayMenu(BuildContext context,
    {required Widget child, offsetX = 0.0, offsetY = 0.0}) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final position =
      button.localToGlobal(Offset(offsetX, offsetY), ancestor: overlay);

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => Stack(
      children: [
        GestureDetector(
          onTap: () {
            overlayEntry.remove();
          },
          child: Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
        Positioned(
          top: position.dy,
          left: position.dx,
          child: child,
        )
      ],
    ),
  );
  Overlay.of(context).insert(overlayEntry);
}
