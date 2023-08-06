import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/form.dart';

import '../main_form/database_communication.dart';

class Filters {
  bool useIncidentTimestamp = false;
  List<String> categories;
  DateTimeRange? dateRange;
  Filters(
      {this.dateRange,
      required this.categories,
      this.useIncidentTimestamp = false});
}

class DataAndSelectionManager extends ChangeNotifier {
  //Data

  List<Report> _reports = [];
  Filters _filters = Filters(categories: [...categories]);

  Filters get filters => _filters;

  bool _isDateInRange(DateTime date, DateTimeRange? dateRange) {
    if (dateRange?.start != null && dateRange?.end != null) {
      if (date.compareTo(dateRange!.start) > 0 &&
          date.compareTo(dateRange.end) < 0) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  UnmodifiableListView<Report> get reports => UnmodifiableListView(
        _reports.where(
          (report) {
            if (_filters.dateRange?.start != null &&
                _filters.dateRange?.end != null) {
            if (_filters.useIncidentTimestamp) {
              DateTime incidentTimestamp = DateTime.fromMillisecondsSinceEpoch(
                  report.incidentData["incident timestamp"].seconds * 1000);
                if (!_isDateInRange(incidentTimestamp, _filters.dateRange)) {
                  return false;
                }
              }
            else {
              if (!_isDateInRange(
                  report.reportTimestamp, _filters.dateRange)) {
                return false;
              }
            }
            }
            if (_filters.categories.isNotEmpty) {
              if (_filters.categories.contains("inne...") &&
                  !categories.contains(report.incidentData["category"])) {
                return true;
              }
              if (_filters.categories
                  .contains(report.incidentData["category"])) {
                return true;
              }
              return false;
            } else {
              return false;
            }
          },
        ),
      );

  void sortReportsByReportTimestamp(bool reverse) {
    _reports.sort((a, b) => a.reportTimestamp.compareTo(b.reportTimestamp));
    if (reverse) {
      _reports = _reports.reversed.toList();
    }
    notifyListeners();
  }

  void sortReportsByIncidentTimestamp(bool reverse) {
    _reports.sort((a, b) => a.incidentData["incident timestamp"].compareTo(b.incidentData["incident timestamp"]));
    if (reverse) {
      _reports = _reports.reversed.toList();
    }
    notifyListeners();
  }

  void sortReportsByCategory(bool reverse) {
    _reports.sort((a, b) => a.incidentData["category"].toUpperCase().compareTo(b.incidentData["category"].toUpperCase()));
    if (reverse) {
      _reports = _reports.reversed.toList();
    }
    notifyListeners();
  }

  bool get isEveryCategoryFilterSelected {
    return _filters.categories.length == categories.length;
  }

  void setFilters(Filters filters) {
    //TODO remember to remove filtered out entries from _selected
    _filters = filters;
    notifyListeners();
  }

  void clearFilters() {
    print("before clear:");
    print(_filters.categories);
    _filters = Filters(
        useIncidentTimestamp: false,
        dateRange: null,
        categories: [...categories]);
    print("after clear:");
    print(_filters.categories);
    notifyListeners();
  }

  void toggleFilterCategory(String category) {
    if (_filters.categories.contains(category)) {
      _filters.categories.remove(category);
    } else {
      _filters.categories.add(category);
    }
    notifyListeners();
  }

  void toggleFilterAllCategories() {
    if (_filters.categories.length == categories.length) {
      _filters.categories.clear();
    } else {
      _filters.categories.clear();
      _filters.categories.addAll(categories);
    }
    notifyListeners();
  }

  Future fetchReports({refresh = false}) async {
    //TODO handle limit and load more
    if (refresh || _reports.isEmpty) {
      _reports.clear();
      await FirebaseFirestore.instance
          .collection("reports")
          .orderBy("report timestamp", descending: true)
          .limit(100)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _reports.add(Report(
              id: doc.id,
              reportTimestamp: DateTime.fromMillisecondsSinceEpoch(
                  data["report timestamp"].seconds * 1000),
              personalData: data["personal data"],
              incidentData: data["incident data"]));
        }
        notifyListeners();
        return true;
      });
    } else {
      notifyListeners();
      return false;
    }
  }

  // Selections
  final List<Report> _selected = [];

  UnmodifiableListView<Report> get selected => UnmodifiableListView(_selected);

  bool isEverythingSelected = false;

  void _updateSelectionStatus() {
    if (_selected.length == _reports.length) {
      isEverythingSelected = true;
    } else {
      isEverythingSelected = false;
    }
  }

  void toggleSelectAll() {
    if (_selected.length == _reports.length) {
      _selected.clear();
    } else {
      _selected.clear();
      _selected.addAll(_reports);
    }
    _updateSelectionStatus();
    notifyListeners();
  }

  void toggleSelection(Report report) {
    if (_selected.contains(report)) {
      _selected.removeWhere((value) => value == report);
    } else {
      _selected.add(report);
    }
    _updateSelectionStatus();
    notifyListeners();
  }

  bool isSelected(Report report) {
    return _selected.contains(report);
  }

  void deleteReport(Report report) {
    report.deleteFromDatabase();
    _reports.remove(report);
    _updateSelectionStatus();
    notifyListeners();
  }

  void deleteSelected() {
    for (var report in _selected) {
      deleteReport(report);
    }
    _selected.clear();
    _updateSelectionStatus();
    notifyListeners();
  }

  void clearSelections() {
    _selected.clear();
    _updateSelectionStatus();
    notifyListeners();
  }

  //highlighted

  Report? _highlighted;

  Report? get highlighted => _highlighted;

  void toggleHighlight(Report report) {
    if (isHighlighted(report)) {
      _highlighted = null;
    } else {
      _highlighted = report;
    }
    notifyListeners();
  }

  bool isHighlighted(Report report) {
    return _highlighted == report;
  }
}
