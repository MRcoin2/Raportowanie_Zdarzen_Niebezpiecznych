import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/admin_panel/providers.dart';

import '../main_form/database_communication.dart';

class SubmissionListElement extends StatefulWidget {
  late final int index;

  SubmissionListElement({super.key, required this.index});

  @override
  State<SubmissionListElement> createState() => _SubmissionListElementState();
}

class _SubmissionListElementState extends State<SubmissionListElement> {
  late Submission submission;

  @override
  void initState() {
    super.initState();
    submission =
        context.read<DataAndSelectionManager>().submissions[widget.index];
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    submission.eventData['category'],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    submission.eventData['date'].toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    submission.eventData['description'],
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
                            submission.deleteFromDatabase();
                          },
                          icon: Icon(Icons.delete_outline)),
                      IconButton(
                          onPressed: () {
                            context
                                .read<DataAndSelectionManager>()
                                .toggleSelection(widget.index, submission);
                          },
                          icon: context
                                  .watch<DataAndSelectionManager>()
                                  .isSelected(widget.index)
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
                              .selected
                              .values
                              .toList()
                              .forEach((submission) {
                            submission.deleteFromDatabase();
                          });
                          context
                              .read<DataAndSelectionManager>()
                              .clearSelection();
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
