import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/form.dart';

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
                  flex: 3,
                  child: FilterPanel(
                    constrainSize: false,
                    showDateSwitch: false,
                    onUpdate: context
                        .read<DataAndSelectionManager>()
                        .updateNumberOfFilteredReportsForReportGeneration,
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "Wybrano:${context.read<DataAndSelectionManager>().numberOfReportsSelectedForReportGeneration}"),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    Map<String, int> categoryCounts = {};
                    for (String category in context
                        .read<DataAndSelectionManager>()
                        .filters.categories) {
                      categoryCounts[category] = await context
                          .read<DataAndSelectionManager>()
                          .numberOfFilteredReportsPerCategory(category);
                    }
                    print(categoryCounts);
                    printPeriodicReport(categoryCounts);
                  },
                  child: const Text('Generuj raport'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
