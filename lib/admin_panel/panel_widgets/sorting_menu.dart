import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers.dart';

enum SortingType { byIncidentDate, byReportDate, byCategory }

class SortingMenu extends StatefulWidget {
  const SortingMenu({super.key});

  @override
  State<SortingMenu> createState() => _SortingMenuState();
}

class _SortingMenuState extends State<SortingMenu> {
  SortingType sortingType = SortingType.byIncidentDate;
  bool isSortingReversed = false;
  List<bool> toggleButtonsState = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width * 0.2,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ListTile(
                  title: const Text("Sortowanie"),
                  trailing: Container(
                    width: 100,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.sort_by_alpha_outlined),
                        Icon(Icons.arrow_downward_outlined),
                      ],
                    ),
                  ),
                  onTap: () {
                    print(sortingType);
                    setState(
                      () {
                        isSortingReversed = false;
                        switch (sortingType) {
                          case SortingType.byIncidentDate:
                            context
                                .read<DataAndSelectionManager>()
                                .sortReportsByIncidentTimestamp(
                                    isSortingReversed);
                            break;
                          case SortingType.byReportDate:
                            context
                                .read<DataAndSelectionManager>()
                                .sortReportsByReportTimestamp(
                                    isSortingReversed);
                            break;
                          case SortingType.byCategory:
                            context
                                .read<DataAndSelectionManager>()
                                .sortReportsByCategory(isSortingReversed);
                            break;
                          default:
                        }
                      },
                    );
                  },
                ),
                ListTile(
                  title: const Text("Sortowanie"),
                  trailing: Container(
                    width: 100,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.sort_by_alpha_outlined),
                        Icon(Icons.arrow_upward_outlined),
                      ],
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      print(sortingType);
                      isSortingReversed = true;
                      switch (sortingType) {
                        case SortingType.byIncidentDate:
                          context
                              .read<DataAndSelectionManager>()
                              .sortReportsByIncidentTimestamp(
                                  isSortingReversed);
                          break;
                        case SortingType.byReportDate:
                          context
                              .read<DataAndSelectionManager>()
                              .sortReportsByReportTimestamp(isSortingReversed);
                          break;
                        case SortingType.byCategory:
                          context
                              .read<DataAndSelectionManager>()
                              .sortReportsByCategory(isSortingReversed);
                          break;
                        default:
                      }
                    });
                  },
                ),
                const Divider(),
                ToggleButtons(
                  isSelected: toggleButtonsState,
                  onPressed: (index) {
                    setState(() {
                      switch (index) {
                        case 0:
                          sortingType = SortingType.byIncidentDate;
                          toggleButtonsState = [true, false, false];
                          context
                              .read<DataAndSelectionManager>()
                              .sortReportsByIncidentTimestamp(
                              isSortingReversed);
                          break;
                        case 1:
                          sortingType = SortingType.byReportDate;
                          toggleButtonsState = [false, true, false];
                          context
                              .read<DataAndSelectionManager>()
                              .sortReportsByReportTimestamp(isSortingReversed);
                          break;
                        case 2:
                          sortingType = SortingType.byCategory;
                          toggleButtonsState = [false, false, true];
                          context
                              .read<DataAndSelectionManager>()
                              .sortReportsByCategory(isSortingReversed);
                          break;
                        default:
                          break;

                      }
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Data zdażenia"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Data zgłoszenia"),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Kategoria"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
