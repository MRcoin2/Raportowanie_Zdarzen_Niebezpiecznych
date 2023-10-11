
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../main_form/database_communication.dart';
import '../panel_widgets/filter_panel.dart';
import '../panel_widgets/panel_widgets.dart';
import '../pdf_generation.dart';
import '../providers.dart';

class ReportingPage extends StatefulWidget {
  const ReportingPage({super.key});

  @override
  State<ReportingPage> createState() => _ReportingPageState();
}

class _ReportingPageState extends State<ReportingPage> {
  List<Report> reports = [];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DataAndSelectionManager()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Generowanie raportów'),
        ),
        body: Consumer<DataAndSelectionManager>(
          builder: (context, provider, child) => Row(
            children: [
              Expanded(flex: 1, child: SideMenuBar()),
              Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: FilterPanel(
                          constrainSize: false,
                          showDateSwitch: false,
                          elevation: 1,
                          onUpdate: context
                              .read<DataAndSelectionManager>()
                              .updateNumberOfFilteredReportsForReportGeneration,
                        ),
                      ),
                      const Expanded(
                          flex: 1,
                          child: Card(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text("Lorem ipsum"),
                                )
                              ],
                            ),
                          )),
                    ],
                  )),
              Expanded(
                flex: 1,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              "Wybrano:${context.read<DataAndSelectionManager>().numberOfReportsSelectedForReportGeneration}", style: TextStyle(fontSize: 20),),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                            ),
                            onPressed: () async {
                              Map<String, int> categoryCounts = {};
                              for (String category in context
                                  .read<DataAndSelectionManager>()
                                  .filters
                                  .categories) {
                                categoryCounts[category] = await context
                                    .read<DataAndSelectionManager>()
                                    .numberOfFilteredReportsPerCategory(
                                        category);
                              }
                              print(categoryCounts);
                              printPeriodicReport(categoryCounts, DateFormat('dd.MM.yyyy').format(context.read<DataAndSelectionManager>().filters.dateRange!.start), DateFormat('dd.MM.yyyy').format(context.read<DataAndSelectionManager>().filters.dateRange!.end));
                            },
                            child: const Text('Drukuj raport'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                            ),
                            onPressed: () async {
                              Map<String, int> categoryCounts = {};
                              for (String category in context
                                  .read<DataAndSelectionManager>()
                                  .filters
                                  .categories) {
                                categoryCounts[category] = await context
                                    .read<DataAndSelectionManager>()
                                    .numberOfFilteredReportsPerCategory(
                                        category);
                              }
                              print(categoryCounts);
                              downloadPeriodicReport(categoryCounts, DateFormat('dd.MM.yyyy').format(context.read<DataAndSelectionManager>().filters.dateRange!.start), DateFormat('dd.MM.yyyy').format(context.read<DataAndSelectionManager>().filters.dateRange!.end));
                            },
                            child: const Text('Pobierz raport'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
