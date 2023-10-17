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
      height: 210,
      width: 450,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text("Sortuj po: "),
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
                                  .sortReportsByReportTimestamp(
                                      isSortingReversed);
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
                const Divider(),
                ListTile(
                  title: const Text("Sortuj A → Z"),
                  onTap: () {
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
                  title: const Text("Sortuj Z → A"),
                  onTap: () {
                    setState(() {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
