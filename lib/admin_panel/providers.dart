import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main_form/database_communication.dart';

class Filters {
  bool useIncidentTimestamp = false;
  DateTime? from;
  DateTime? to;
  List<String>? categories;

  Filters(
      {this.from, this.to, this.categories, this.useIncidentTimestamp = false});
}

class DataAndSelectionManager extends ChangeNotifier {
  //Data
  final List<Report> _reports = [];
  Filters _filters = Filters();

  UnmodifiableListView<Report> get reports => UnmodifiableListView(
        _reports.where(
          (report) {
            if (_filters.useIncidentTimestamp) {
              if (_filters.from != null && _filters.to != null) {
                if (report.incidentData["incident timestamp"]
                        .compareTo(_filters.from!) <
                    0) {
                  return false;
                }
                if (report.incidentData["incident timestamp"]
                        .compareTo(_filters.to!) >
                    0) {
                  return false;
                }
              } else if (_filters.from != null) {
                if (report.incidentData["incident timestamp"]
                        .compareTo(_filters.from!) <
                    0) {
                  return false;
                }
              } else if (_filters.to != null) {
                if (report.incidentData["incident timestamp"]
                        .compareTo(_filters.to!) >
                    0) {
                  return false;
                }
              }
            } else {
              if (_filters.from != null && _filters.to != null) {
                if (report.reportTimestamp.compareTo(_filters.from!) < 0) {
                  return false;
                }
                if (report.reportTimestamp.compareTo(_filters.to!) > 0) {
                  return false;
                }
              } else if (_filters.from != null) {
                if (report.reportTimestamp.compareTo(_filters.from!) < 0) {
                  return false;
                }
              } else if (_filters.to != null) {
                if (report.reportTimestamp.compareTo(_filters.to!) > 0) {
                  return false;
                }
              }
            }
            if (_filters.categories != null) {
              if (!_filters.categories!.contains(
                  report.incidentData["category"])) {
                return false;
              }
            }
            return true;
          },
        ),
      );

  void setFilters(Filters filters) {
    _filters = filters;
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
