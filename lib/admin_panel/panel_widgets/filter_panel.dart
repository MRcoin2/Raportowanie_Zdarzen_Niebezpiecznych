import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../main_form/form.dart';
import '../providers.dart';

class FilterPanel extends StatefulWidget {
  FilterPanel({
    super.key,
  });

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  List<bool> toggleButtonsState = [true, false];

  DateTimeRange selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 31)),
      end: DateTime.now());

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
        widget.fromDateController.text =
            DateFormat('dd.MM.yyyy').format(selectedDateRange.start);
        widget.toDateController.text =
            DateFormat('dd.MM.yyyy').format(selectedDateRange.end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //menu for managing the filters
    return SizedBox(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.5,
      width: MediaQuery
          .of(context)
          .size
          .width * 0.3,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Form(
              onChanged: () {
                try {
                  context.read<DataAndSelectionManager>().setFilters(Filters(
                      categories: context
                          .read<DataAndSelectionManager>()
                          .filters
                          .categories,
                      dateRange: selectedDateRange,
                      useIncidentTimestamp: toggleButtonsState[0]
                  ),
                  );
                }
                catch (e) {
                  print(e);
                }
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DateTextFormField(
                            labelText: "Od",
                            dateController: widget.fromDateController),
                      ),
                      Expanded(
                        child: DateTextFormField(
                            labelText: "Do",
                            dateController: widget.toDateController),
                      ),
                      IconButton(
                        onPressed: () => _selectDateRange(context),
                        icon: const Icon(Icons.calendar_month),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Filtruj po:"),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: ToggleButtons(
                            isSelected: toggleButtonsState,
                            onPressed: (index) {
                              if (index == 0) {
                                setState(() {
                                  toggleButtonsState = [true, false];
                                });
                              } else {
                                setState(() {
                                  toggleButtonsState = [false, true];
                                });
                              }
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
                        ), Expanded(child: Container(),),
                        TextButton(
                          onPressed: () {
                            widget.fromDateController.clear();
                            widget.toDateController.clear();
                            context
                                .read<DataAndSelectionManager>()
                                .clearFilters();
                          },
                          child: const Text('Wyczyść filtry'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text("zaznacz wszystkie",
                            textAlign: TextAlign.right,),
                          trailing: Checkbox(
                            value: context
                                .read<DataAndSelectionManager>()
                                .isEveryCategoryFilterSelected,
                            onChanged: (value) {
                              context
                                  .read<DataAndSelectionManager>()
                                  .toggleFilterAllCategories();
                            },
                          ),
                        ),
                        ...categories.map(
                              (category) =>
                              ListTile(
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
