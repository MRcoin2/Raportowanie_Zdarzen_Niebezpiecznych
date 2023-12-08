import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/form_widgets/form.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generowanie raportów'),
      ),
      body: Consumer<DataAndSelectionManager>(
        builder: (context, provider, child) => Row(
          children: [
            const Expanded(
                flex: 1,
                child: SideMenuBar(
                  description:
                      "Strona generowania raportów zbiorczych\n\nNa tej stronie można wygenerować raport zliczający ilość zdarzeń z danych kategorii w danym okresie czasu.",
                )),
            Expanded(
                flex: 4,
                child: FilterPanel(
                  constrainSize: false,
                  showDateSwitch: false,
                  elevation: 1,
                  onUpdate: context
                      .read<DataAndSelectionManager>()
                      .updateNumberOfFilteredReportsForReportGeneration,
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
                          "Wybrano:${context.read<DataAndSelectionManager>().numberOfReportsSelectedForReportGeneration}",
                          style: const TextStyle(fontSize: 20),
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
                                  .numberOfFilteredReportsPerCategory(category);
                            }
                            printPeriodicReport(
                                categoryCounts,
                                DateFormat('dd.MM.yyyy').format(context
                                    .read<DataAndSelectionManager>()
                                    .filters
                                    .dateRange!
                                    .start),
                                DateFormat('dd.MM.yyyy').format(context
                                    .read<DataAndSelectionManager>()
                                    .filters
                                    .dateRange!
                                    .end));
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
                            int sum = 0;
                            print(categories);
                            for (String category in context
                                .read<DataAndSelectionManager>()
                                .filters
                                .categories) {
                              categoryCounts[category] = await context
                                  .read<DataAndSelectionManager>()
                                  .numberOfFilteredReportsPerCategory(category);
                              if (category != "inne...") {
                                sum += categoryCounts[category]!;
                              }
                            }
                            categoryCounts["inne..."] = categoryCounts["inne..."]! - sum;
                            downloadPeriodicReport(
                                categoryCounts,
                                DateFormat('dd.MM.yyyy').format(context
                                    .read<DataAndSelectionManager>()
                                    .filters
                                    .dateRange!
                                    .start),
                                DateFormat('dd.MM.yyyy').format(context
                                    .read<DataAndSelectionManager>()
                                    .filters
                                    .dateRange!
                                    .end));
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
    );
  }
}
