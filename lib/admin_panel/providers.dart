import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/form.dart';

import '../main_form/database_communication.dart';

enum PageType {reportsPage, trashPage, archivePage}

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
  List<Report> _trash = [];
  List<Report> _archivedReports = [];
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
            if (_filters.dateRange != null) {
            if (_filters.useIncidentTimestamp) {
              DateTime incidentTimestamp = DateTime.fromMillisecondsSinceEpoch(
                  report.incidentData["incident timestamp"].seconds * 1000);
                if (!_isDateInRange(incidentTimestamp, _filters.dateRange)) {
                  _selected.removeWhere((report) => report == report);
                  return false;
                }
              }
            else {
              if (!_isDateInRange(
                    report.reportTimestamp, _filters.dateRange)) {
                _selected.removeWhere((report) => report == report);
                  return false;
                }
              }
            }
            if (_filters.categories.isEmpty) {
              _selected.removeWhere((report) => report == report);
              return false;
            } else {
              if (_filters.categories.contains("inne...") &&
                  !categories.contains(report.incidentData["category"])) {
                return true;
              }
              if (_filters.categories
                  .contains(report.incidentData["category"])) {
                return true;
              }
              _selected.removeWhere((report) => report == report);
              return false;
            }
          },
        ),
      );

  UnmodifiableListView<Report> get trash => UnmodifiableListView(
    _trash.where(
          (report) {
        if (_filters.dateRange != null) {
          if (_filters.useIncidentTimestamp) {
            DateTime incidentTimestamp = DateTime.fromMillisecondsSinceEpoch(
                report.incidentData["incident timestamp"].seconds * 1000);
            if (!_isDateInRange(incidentTimestamp, _filters.dateRange)) {
              _selected.removeWhere((report) => report == report);
              return false;
            }
          }
          else {
            if (!_isDateInRange(
                report.reportTimestamp, _filters.dateRange)) {
              _selected.removeWhere((report) => report == report);
              return false;
            }
          }
        }
        if (_filters.categories.isEmpty) {
          _selected.removeWhere((report) => report == report);
          return false;
        } else {
          if (_filters.categories.contains("inne...") &&
              !categories.contains(report.incidentData["category"])) {
            return true;
          }
          if (_filters.categories
              .contains(report.incidentData["category"])) {
            return true;
          }
          _selected.removeWhere((report) => report == report);
          return false;
        }
      },
    ),
  );

  UnmodifiableListView<Report> get archivedReports => UnmodifiableListView(
    _archivedReports.where(
          (report) {
        if (_filters.dateRange != null) {
          if (_filters.useIncidentTimestamp) {
            DateTime incidentTimestamp = DateTime.fromMillisecondsSinceEpoch(
                report.incidentData["incident timestamp"].seconds * 1000);
            if (!_isDateInRange(incidentTimestamp, _filters.dateRange)) {
              _selected.removeWhere((report) => report == report);
              return false;
            }
          }
          else {
            if (!_isDateInRange(
                report.reportTimestamp, _filters.dateRange)) {
              _selected.removeWhere((report) => report == report);
              return false;
            }
          }
        }
        if (_filters.categories.isEmpty) {
          _selected.removeWhere((report) => report == report);
          return false;
        } else {
          if (_filters.categories.contains("inne...") &&
              !categories.contains(report.incidentData["category"])) {
            return true;
          }
          if (_filters.categories
              .contains(report.incidentData["category"])) {
            return true;
          }
          _selected.removeWhere((report) => report == report);
          return false;
        }
      },
    ),
  );

  void sortReportsByReportTimestamp(bool reverse) {
    _reports.sort((a, b) => a.reportTimestamp.compareTo(b.reportTimestamp));
    _trash.sort((a, b) => a.reportTimestamp.compareTo(b.reportTimestamp));
    if (reverse) {
      _reports = _reports.reversed.toList();
      _trash = _trash.reversed.toList();
    }
    notifyListeners();
  }

  void sortReportsByIncidentTimestamp(bool reverse) {
    _reports.sort((a, b) => a.incidentData["incident timestamp"].compareTo(b.incidentData["incident timestamp"]));
    _trash.sort((a, b) => a.incidentData["incident timestamp"].compareTo(b.incidentData["incident timestamp"]));
    if (reverse) {
      _reports = _reports.reversed.toList();
      _trash = _trash.reversed.toList();
    }
    notifyListeners();
  }

  void sortReportsByCategory(bool reverse) {
    _reports.sort((a, b) => a.incidentData["category"].toUpperCase().compareTo(b.incidentData["category"].toUpperCase()));
    _trash.sort((a, b) => a.incidentData["category"].toUpperCase().compareTo(b.incidentData["category"].toUpperCase()));
    if (reverse) {
      _reports = _reports.reversed.toList();
      _trash = _trash.reversed.toList();
    }
    notifyListeners();
  }

  bool get isEveryCategoryFilterSelected {
    return _filters.categories.length == categories.length;
  }

  void setFilters(Filters filters) {
    _filters = filters;
    notifyListeners();
  }

  void clearFilters() {
    _filters = Filters(
        useIncidentTimestamp: false,
        dateRange: null,
        categories: [...categories]);
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

  void _updateSelectionStatus(pageType) {
    switch (pageType) {
      case PageType.reportsPage:
        if (_selected.length == _reports.length) {
          isEverythingSelected = true;
        } else {
          isEverythingSelected = false;
        }
        break;
      case PageType.trashPage:
        if (_selected.length == _trash.length) {
          isEverythingSelected = true;
        } else {
          isEverythingSelected = false;
        }
        break;
      case PageType.archivePage:
        if (_selected.length == _archivedReports.length) {
          isEverythingSelected = true;
        } else {
          isEverythingSelected = false;
        }
        break;
    }

  }

  void toggleSelectAll(pageType) {
    switch (pageType) {
      case PageType.reportsPage:
        if (_selected.length == _reports.length) {
          _selected.clear();
        } else {
          _selected.clear();
          _selected.addAll(_reports);
        }
        break;
      case PageType.trashPage:
        if (_selected.length == _trash.length) {
          _selected.clear();
        } else {
          _selected.clear();
          _selected.addAll(_trash);
        }
        break;
      case PageType.archivePage:
        if (_selected.length == _archivedReports.length) {
          _selected.clear();
        } else {
          _selected.clear();
          _selected.addAll(_archivedReports);
        }
        break;
    }
    _updateSelectionStatus(pageType);
    notifyListeners();
  }

  void toggleSelection(Report report, pageType) {
    if (_selected.contains(report)) {
      _selected.removeWhere((value) => value == report);
    } else {
      _selected.add(report);
    }
    _updateSelectionStatus(pageType);
    notifyListeners();
  }

  bool isSelected(Report report) {
    return _selected.contains(report);
  }

  void moveReportToTrash(Report report, pageType) {
    report.moveToTrash();
    _reports.remove(report);
    _updateSelectionStatus(pageType);
    notifyListeners();
  }

  void moveSelectedToTrash(pageType) {
    for (var report in _selected) {
      moveReportToTrash(report, pageType);
    }
    _selected.clear();
    _updateSelectionStatus(pageType);
    notifyListeners();
  }

  void clearSelections() {
    _selected.clear();
    isEverythingSelected = false;
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

  Future fetchTrash({refresh = false}) async {
    if (refresh || _trash.isEmpty) {
      _trash.clear();
      await FirebaseFirestore.instance
          .collection("trash")
          .orderBy("report timestamp", descending: true)
          .limit(100)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _trash.add(Report(
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

  void restoreFromTrash(Report report) {
    report.restoreFromTrash();
    _trash.remove(report);
    _updateSelectionStatus(PageType.trashPage);
    notifyListeners();
  }

  void restoreSelectedFromTrash() {
    for (var report in _selected) {
      restoreFromTrash(report);
    }
    _selected.clear();
    _updateSelectionStatus(PageType.trashPage);
    notifyListeners();
  }

  void deletePermanently(Report report) {
    report.deletePermanently();
    _trash.remove(report);
    _updateSelectionStatus(PageType.trashPage);
    notifyListeners();
  }

  void deleteSelectedPermanently() {
    for (var report in _selected) {
      deletePermanently(report);
    }
    _selected.clear();
    _updateSelectionStatus(PageType.trashPage);
    notifyListeners();
  }

}
