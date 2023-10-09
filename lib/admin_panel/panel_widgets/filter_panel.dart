import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main_form/form.dart';
import '../providers.dart';

class FilterPanel extends StatefulWidget {
  final bool constrainSize;
  final bool showDateSwitch;
  final Function? onUpdate;

  FilterPanel({
    super.key,
    this.constrainSize = true,
    this.showDateSwitch = true,
    this.onUpdate,
  });

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  List<bool> toggleButtonsState = [false, true];

  late DateTimeRange? selectedDateRange;

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        locale: const Locale("pl", "PL"),
        initialDateRange: selectedDateRange,
        firstDate: DateTime(2020),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
        fromDateController.text =
            DateFormat('dd.MM.yyyy').format(selectedDateRange!.start);
        toDateController.text =
            DateFormat('dd.MM.yyyy').format(selectedDateRange!.end);
      });
    }
  }

  void updateDateRange() {
    try {
      selectedDateRange = DateTimeRange(
          start: DateFormat('dd.MM.yyyy').parse(fromDateController.text),
          end: DateFormat('dd.MM.yyyy').parse(toDateController.text));
    } catch (e) {
      if (kDebugMode) {
        print(
            "Filter Panel: incorrect date format / field empty (skipping setting date range)");
      }
    }
    widget.onUpdate!();
    context.read<DataAndSelectionManager>().setFilters(
          Filters(
              categories:
                  context.read<DataAndSelectionManager>().filters.categories,
              dateRange: selectedDateRange,
              useIncidentTimestamp: toggleButtonsState[0]),
        );
  }

  @override
  void initState() {
    selectedDateRange =
        context.read<DataAndSelectionManager>().filters.dateRange;
    if (selectedDateRange != null) {
      fromDateController.text =
          DateFormat('dd.MM.yyyy').format(selectedDateRange!.start);
      toDateController.text =
          DateFormat('dd.MM.yyyy').format(selectedDateRange!.end);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //menu for managing the filters
    return SizedBox(
      height: widget.constrainSize
          ? MediaQuery.of(context).size.height * 0.5
          : double.infinity,
      width: widget.constrainSize
          ? MediaQuery.of(context).size.width * 0.35
          : double.infinity,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Form(
              onChanged: () {
                updateDateRange();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DateTextFormField(
                            labelText: "Od",
                            dateController: fromDateController),
                      ),
                      Expanded(
                        child: DateTextFormField(
                            labelText: "Do", dateController: toDateController),
                      ),
                      IconButton(
                        onPressed: () => _selectDateRange(context),
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: widget.showDateSwitch? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                            const Text("Filtruj po:"),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ToggleButtons(
                                isSelected: toggleButtonsState,
                                onPressed: (index) {
                                  setState(() {
                                    if (index == 0) {
                                      toggleButtonsState = [true, false];
                                    } else {
                                      toggleButtonsState = [false, true];
                                    }
                                    updateDateRange();
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
                                  )
                                ],
                              ),
                            ),
                        Expanded(
                          child: Container(),
                        ),
                        TextButton(
                          onPressed: () {
                            fromDateController.clear();
                            toDateController.clear();
                            context
                                .read<DataAndSelectionManager>()
                                .clearFilters();
                          },
                          child: const Text('Wyczyść filtry'),
                        ),
                      ],
                    ):TextButton(
                      onPressed: () {
                        fromDateController.clear();
                        toDateController.clear();
                        context
                            .read<DataAndSelectionManager>()
                            .clearFilters();
                      },
                      child: const Text('Wyczyść filtry'),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: const Text(
                            "zaznacz wszystkie",
                            textAlign: TextAlign.right,
                          ),
                          trailing: Checkbox(
                            value: context
                                .read<DataAndSelectionManager>()
                                .isEveryCategoryFilterSelected,
                            onChanged: (value) {
                              context
                                  .read<DataAndSelectionManager>()
                                  .toggleFilterAllCategories();
                              print(context
                                  .read<DataAndSelectionManager>()
                                  .filters
                                  .categories);
                              widget.onUpdate!();
                            },
                          ),
                        ),
                        ...categories.map(
                          (category) => ListTile(
                            title: Text(
                              category,
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis),
                            ),
                            trailing: Checkbox(
                              value: context
                                  .read<DataAndSelectionManager>()
                                  .filters
                                  .categories
                                  .contains(category),
                              onChanged: (value) {
                                context
                                    .read<DataAndSelectionManager>()
                                    .toggleFilterCategory(category);
                                widget.onUpdate!();
                              },
                            ),
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
      ),
    );
  }
}

class DateTextFormField extends StatefulWidget {
  final TextEditingController dateController;
  final String labelText;

  const DateTextFormField(
      {super.key, required this.dateController, required this.labelText});

  @override
  State<DateTextFormField> createState() => _DateTextFormFieldState();
}

class _DateTextFormFieldState extends State<DateTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: widget.dateController,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintStyle: const TextStyle(overflow: TextOverflow.ellipsis),
          hintText: "DD.MM.RRRR",
        ),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null ||
              value.isEmpty ||
              !RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(value)) {
            return 'Proszę wprowadzić datę w formacie DD.MM.RRRR';
          }
          //catch an error parsing the date
          try {
            DateFormat('dd.MM.yyyy').parseStrict(value);
          } catch (e) {
            return 'Proszę wprowadzić datę w formacie DD.MM.RRRR';
          }
          if (DateFormat('dd.mm.yyyy')
              .parseStrict(value)
              .isAfter(DateTime.now())) {
            return 'Data zdarzenia nie może być późniejsza niż dzisiejsza';
          } else if (DateFormat('dd.mm.yyyy')
              .parseStrict(value)
              .isBefore(DateTime(2020))) {
            return 'Data zdarzenia nie może być wcześniejsza niż 01.01.2020';
          }
          return null;
        },
      ),
    );
  }
}
