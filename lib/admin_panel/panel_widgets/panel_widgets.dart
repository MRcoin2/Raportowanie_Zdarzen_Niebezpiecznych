import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/pages/archive_page.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/pages/trash_page.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/panel_widgets/filter_panel.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/panel_widgets/sorting_menu.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/pdf_generation.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/providers.dart';

import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;
import '../../main_form/database_communication.dart';
import '../pages/admin_panel.dart';
import '../pages/raporting_page.dart';
import '../pages/settings_page.dart';

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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          border: context
                  .read<DataAndSelectionManager>()
                  .isHighlighted(widget.report)
              ? Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                )
              : null,
        ),
        child: Card(
          surfaceTintColor: context
                  .read<DataAndSelectionManager>()
                  .isHighlighted(widget.report)
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardTheme.color,
          elevation: context
                  .read<DataAndSelectionManager>()
                  .isHighlighted(widget.report)
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        widget.report.incidentData['description'],
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
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
                              tooltip: 'Zatwierdź',
                              onPressed: () {
                                context
                                    .read<DataAndSelectionManager>()
                                    .archiveReport(widget.report);
                              },
                              icon: const Icon(Icons.check)),
                          IconButton(
                              tooltip: 'Usuń',
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
                                                Navigator.of(context)
                                                    .pop(false);
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
                                        .moveReportToTrash(widget.report,
                                            PageType.reportsPage);
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
                                  .toggleSelection(
                                      widget.report, PageType.reportsPage);
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
      ),
    );
  }
}

class TrashListElement extends StatefulWidget {
  final Report report;

  const TrashListElement({super.key, required this.report});

  @override
  State<TrashListElement> createState() => _TrashListElementState();
}

class _TrashListElementState extends State<TrashListElement> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DataAndSelectionManager>().toggleHighlight(widget.report);
      },
      child: Container(
      decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      border: context
          .read<DataAndSelectionManager>()
          .isHighlighted(widget.report)
      ? Border.all(
      color: Theme.of(context).primaryColor,
      width: 2,
      )
          : null,
      ),
      child: Card(
        surfaceTintColor:
            context.read<DataAndSelectionManager>().isHighlighted(widget.report)
                ? Theme.of(context).primaryColor
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
                            tooltip: 'Przywróć',
                            onPressed: () {
                              context
                                  .read<DataAndSelectionManager>()
                                  .restoreFromTrash(widget.report);
                            },
                            icon: const Icon(Icons.restore_outlined)),
                        Checkbox(
                          value: context
                              .watch<DataAndSelectionManager>()
                              .isSelected(widget.report),
                          onChanged: (value) {
                            context
                                .read<DataAndSelectionManager>()
                                .toggleSelection(
                                    widget.report, PageType.trashPage);
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
      ),),
    );
  }
}

class ArchiveListElement extends StatefulWidget {
  final Report report;

  const ArchiveListElement({super.key, required this.report});

  @override
  State<ArchiveListElement> createState() => _ArchiveListElementState();
}

class _ArchiveListElementState extends State<ArchiveListElement> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<DataAndSelectionManager>().toggleHighlight(widget.report);
      },
      child: Container(
      decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      border: context
          .read<DataAndSelectionManager>()
          .isHighlighted(widget.report)
      ? Border.all(
      color: Theme.of(context).primaryColor,
      width: 2,
      )
          : null,
      ),
      child: Card(
        surfaceTintColor:
            context.read<DataAndSelectionManager>().isHighlighted(widget.report)
                ? Theme.of(context).primaryColor
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
                            tooltip: 'Przywróć',
                            onPressed: () {
                              context
                                  .read<DataAndSelectionManager>()
                                  .unarchiveReport(widget.report);
                            },
                            icon: const Icon(Icons.close_outlined)),
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
                                      .moveReportToTrash(
                                          widget.report, PageType.archivePage);
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
                                .toggleSelection(
                                    widget.report, PageType.archivePage);
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
      ),),
    );
  }
}

class TopMenuBar extends StatefulWidget {
  final PageType pageType;
  final bool sortingEnabled;

  // sorting is currently broken and should not be used
  // maybe it should be removed entirely

  const TopMenuBar(
      {super.key,
      this.pageType = PageType.reportsPage,
      this.sortingEnabled = false});

  @override
  State<TopMenuBar> createState() => _TopMenuBarState();
}

class _TopMenuBarState extends State<TopMenuBar> {
  bool isFilterMenuOpen = false;
  bool isSortingMenuOpen = false;

  toggleFilterMenu() {
    setState(() {
      isFilterMenuOpen = !isFilterMenuOpen;
    });
  }

  toggleSortingMenu() {
    setState(() {
      isSortingMenuOpen = !isSortingMenuOpen;
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
                  widget.sortingEnabled
                      ? PortalTarget(
                          visible: isSortingMenuOpen,
                          portalFollower: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                isSortingMenuOpen = false;
                              });
                            },
                          ),
                          child: PortalTarget(
                            visible: isSortingMenuOpen,
                            anchor: const Aligned(
                              follower: Alignment.topLeft,
                              target: Alignment.topRight,
                            ),
                            portalFollower: const SortingMenu(),
                            child: IconButton(
                                onPressed: () {
                                  toggleSortingMenu();
                                },
                                icon: const Icon(Icons.sort)),
                          ),
                        )
                      : SizedBox.shrink(),
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
                      portalFollower: const FilterPanel(),
                      child: IconButton(
                          onPressed: () {
                            toggleFilterMenu();
                          },
                          icon: const Icon(Icons.filter_alt_outlined)),
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
                  widget.pageType == PageType.trashPage
                      ? Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Czy na pewno chcesz trwale usunąć wszystkie zaznaczone zgłoszenia?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
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
                                        .deleteSelectedPermanently();
                                  }
                                });
                              },
                              icon: const Icon(Icons.delete_forever_outlined),
                              tooltip: "Usuń trwale wszystkie zaznaczone",
                            ),
                            IconButton(
                              onPressed: () {
                                context
                                    .read<DataAndSelectionManager>()
                                    .restoreSelectedFromTrash();
                              },
                              icon: const Icon(Icons.restore_outlined),
                              tooltip: "Przywróć wszystkie zaznaczone",
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
                                      .toggleSelectAll(PageType.trashPage);
                                },
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            widget.pageType == PageType.reportsPage
                                ? IconButton(
                                    onPressed: () {
                                      context
                                          .read<DataAndSelectionManager>()
                                          .archiveSelected();
                                    },
                                    icon: const Icon(Icons.checklist_sharp),
                                    tooltip: "Zatwierdź wszystkie zaznaczone",
                                  )
                                : IconButton(
                                    onPressed: () {
                                      context
                                          .read<DataAndSelectionManager>()
                                          .unarchiveSelected();
                                    },
                                    icon: const Icon(Icons.close_outlined),
                                    tooltip:
                                        "Przywróć z zatwierdzonych wszystkie zaznaczone",
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
                                                Navigator.of(context)
                                                    .pop(false);
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
                                        .moveSelectedToTrash(widget.pageType);
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
                                      .toggleSelectAll(widget.pageType);
                                },
                              ),
                            ),
                          ],
                        ),
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
  final String? description;

  const SideMenuBar({super.key, this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Card(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: const Text("Strona główna"),
                      onTap: () {
                        context
                            .read<DataAndSelectionManager>()
                            .clearSelections();
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                MultiProvider(
                              providers: [
                                ChangeNotifierProvider(
                                  create: (context) =>
                                      DataAndSelectionManager(),
                                ),
                              ],
                              child: const AdminPanelPage(),
                            ),
                            transitionsBuilder: (_, a, __, c) =>
                                FadeTransition(opacity: a, child: c),
                            transitionDuration:
                                const Duration(milliseconds: 100),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 100),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.check),
                      title: const Text("Zatwierdzone"),
                      onTap: () {
                        context
                            .read<DataAndSelectionManager>()
                            .clearSelections();
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                      create: (context) =>
                                          DataAndSelectionManager(),
                                    ),
                                  ],
                                  child: const ArchivePage(),),
                            transitionsBuilder: (_, a, __, c) =>
                                FadeTransition(opacity: a, child: c),
                            transitionDuration:
                                const Duration(milliseconds: 100),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 100),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete_outline),
                      title: const Text("Kosz"),
                      onTap: () {
                        context
                            .read<DataAndSelectionManager>()
                            .clearSelections();
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                      create: (context) =>
                                          DataAndSelectionManager(),
                                    ),
                                  ],
                                  child: const TrashPage(),),
                            transitionsBuilder: (_, a, __, c) =>
                                FadeTransition(opacity: a, child: c),
                            transitionDuration:
                                const Duration(milliseconds: 100),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 100),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.document_scanner_outlined),
                      title: const Text("Generowanie raportu"),
                      onTap: () {
                        context
                            .read<DataAndSelectionManager>()
                            .clearSelections();
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                      create: (context) =>
                                          DataAndSelectionManager(),
                                    ),
                                  ],
                                  child: const ReportingPage(),),
                            transitionsBuilder: (_, a, __, c) =>
                                FadeTransition(opacity: a, child: c),
                            transitionDuration:
                                const Duration(milliseconds: 100),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 100),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: const Text("Ustawienia"),
                      onTap: () {
                        context
                            .read<DataAndSelectionManager>()
                            .clearSelections();
                        Navigator.of(context).pushReplacement(
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) =>
                                MultiProvider(
                                  providers: [
                                    ChangeNotifierProvider(
                                      create: (context) =>
                                          DataAndSelectionManager(),
                                    ),
                                  ],
                                  child: const SettingsPage(),),
                            transitionsBuilder: (_, a, __, c) =>
                                FadeTransition(opacity: a, child: c),
                            transitionDuration:
                                const Duration(milliseconds: 100),
                            reverseTransitionDuration:
                                const Duration(milliseconds: 100),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        description!.isNotEmpty
            ? Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Text(
                        description ?? "",
                        softWrap: true,
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

void downloadFile(String url) {
  html.AnchorElement anchorElement = html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
}

Future<void> downloadZippedImages(List<List<String>> urlsWithNames) async {
  // download all images and pack them into a zip file and download it
  List<ArchiveFile> files = [];
  Archive archive = Archive();
  ZipEncoder encoder = ZipEncoder();
  for (List<String> urlWithName in urlsWithNames) {
    await http.get(Uri.parse(urlWithName[0])).then((value) {
      files.add(
          ArchiveFile(urlWithName[1], value.bodyBytes.length, value.bodyBytes));
    });
  }
  for (ArchiveFile file in files) {
    archive.addFile(file);
  }
  Uint8List archiveBytes = Uint8List.fromList(encoder.encode(archive)!);
//download the file
  html.AnchorElement(
      href:
          "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(archiveBytes)}")
    ..setAttribute("download", "zdjecia.zip")
    ..click();
  return;
}

class ReportDisplayCard extends StatelessWidget {
  final Report report;

  const ReportDisplayCard(this.report, {super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Card(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  report.incidentData['category'] ?? '',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "Data zgłoszenia: ",
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      ' ${DateFormat("dd.MM.yyyy").format(DateTime.fromMillisecondsSinceEpoch(report.reportTimestamp.millisecondsSinceEpoch))}',
                      textAlign: TextAlign.right,
                    )
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dane osobowe:",
                            style: Theme.of(context).textTheme.titleLarge),
                        const Text(
                          "Imię Nazwisko:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Text(
                          "Status:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Text(
                          "Sąd:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Text(
                          "Adres e-mail:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Text(
                          "Numer telefonu:",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("", style: Theme.of(context).textTheme.titleLarge),
                        Text(
                            "${report.personalData['name']} ${report.personalData['surname']}"),
                        Text("${report.personalData['status']}"),
                        Text("${report.personalData['affiliation']}"),
                        Text("${report.personalData['email']}"),
                        Text("${report.personalData['phoneNumber'] ?? ''}"),
                      ],
                    )
                  ],
                ),
                // personal data
                const Text(""),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Dane zdarzenia:",
                            style: Theme.of(context).textTheme.titleLarge),
                        const Text(
                          "Lokalizacja:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Text(
                          "Data zdarzenia:",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Text(
                          "Opis:",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("", style: Theme.of(context).textTheme.titleLarge),
                        Text("${report.incidentData["location"]}"),
                        Text(
                            "${report.incidentData['date']} ${report.incidentData['time']}"),
                        const Text(""),
                      ],
                    )
                  ],
                ),
                Text(
                  "${report.incidentData['description']}",
                  textAlign: TextAlign.justify,
                ),
                const Text(""),
                const Text(
                  "Dodatkowe Informacje:",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  report.additionalInfo,
                  textAlign: TextAlign.justify,
                ),
                const Divider(),
                // grid of images from firebase storage linked to this report
                FutureBuilder(
                    future: report.getImageUrls(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return GridView.builder(
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 5),
                          itemCount: snapshot.data?.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 4,
                              child: GestureDetector(
                                  onTap: () => showDialog(
                                      context: context,
                                      builder: (context) => Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                child: Image.network(
                                                  snapshot.data![index][0],
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                              //card with image name and a button for downloading image
                                              Card(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Text(
                                                        snapshot.data![index]
                                                            [1],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge,
                                                      ),
                                                      IconButton(
                                                          onPressed: () async {
                                                            try {
                                                              downloadFile(
                                                                  snapshot.data![
                                                                          index]
                                                                      [0]);
                                                            } catch (e) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      const SnackBar(
                                                                content: Text(
                                                                    "Nie udało się pobrać pliku"),
                                                              ));
                                                            }
                                                          },
                                                          icon: const Icon(Icons
                                                              .download_outlined))
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          )),
                                  child:
                                      Image.network(snapshot.data![index][0])),
                            );
                          },
                        );
                      } else {
                        return const Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    }),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 4,
                        ),
                        onPressed: () async {
                          BuildContext? dialogContext;
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (context) {
                                dialogContext = context;
                                return const AlertDialog(
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                          "Generowanie raportu...\n(może to chwilę zająć, szczególnie w przypadku dużej ilości zdjęć)"),
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              });
                          try {
                            await printReport(report);
                            Navigator.of(dialogContext!).pop();
                          } catch (e) {
                            Navigator.of(dialogContext!).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Nie udało się wydrukować pliku")));
                          }
                        },
                        child: const Text("Drukuj"),
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 4,
                          ),
                          onPressed: () async {
                            BuildContext? dialogContext;
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  dialogContext = context;
                                  return const AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            "Generowanie raportu...\n(może to chwilę zająć, szczególnie w przypadku dużej ilości zdjęć)"),
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                            try {
                              await downloadReport(report);
                              Navigator.of(dialogContext!).pop();
                            } catch (e) {
                              Navigator.of(dialogContext!).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Nie udało się pobrać pliku")));
                            }
                          },
                          child: const Text("Pobierz plik PDF"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 4,
                          ),
                          onPressed: () async {
                            BuildContext? dialogContext;
                            showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  dialogContext = context;
                                  return const AlertDialog(
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                            "Pakowanie zdjęć do pliku zip...\n(może to chwilę zająć, szczególnie w przypadku dużej ilości zdjęć)"),
                                        SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                            try {
                              await downloadZippedImages(
                                  await report.getImageUrls());
                              Navigator.of(dialogContext!).pop();
                            } catch (e) {
                              Navigator.of(dialogContext!).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Nie udało się pobrać plików")));
                            }
                          },
                          child: const Text("Pobierz zdjęcia"),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
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
