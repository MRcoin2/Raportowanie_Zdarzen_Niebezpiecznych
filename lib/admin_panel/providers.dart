import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:raportowanie_zdarzen_niebezpiecznych/main_form/form.dart';

import '../main_form/database_communication.dart';

enum PageType { reportsPage, trashPage, archivePage }

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
  //database comunication
  List<Report> _reports = [];
  DocumentSnapshot? _lastReport;
  List<Report> _trash = [];
  DocumentSnapshot? _lastTrash;
  List<Report> _archivedReports = [];
  DocumentSnapshot? _lastArchivedReport;

  Future<bool> fetchReports({refresh = false}) async {
    print("fetching reports");
    //TODO handle limit and load more
    if (refresh || _reports.isEmpty) {
      print("clearing reports");
      _reports.clear();
      await FirebaseFirestore.instance
          .collection("reports")
          .orderBy("report timestamp", descending: true)
          .limit(50)
          .get()
          .then((QuerySnapshot querySnapshot) {
        print(querySnapshot.docs.length);
        addQuerySnapshotToList(querySnapshot, _reports);
        _lastReport = querySnapshot.docs.last;
        notifyListeners();
        return true;
      });
    }
    notifyListeners();
    return false;
  }

  Future<bool> fetchMoreReports({refresh = false}) async {
    await FirebaseFirestore.instance
        .collection("reports")
        .orderBy("report timestamp", descending: true)
        .startAfterDocument(_lastReport!)
        .limit(50)
        .get()
        .then((QuerySnapshot querySnapshot) {
      addQuerySnapshotToList(querySnapshot, _reports);
      _lastReport = querySnapshot.docs.last;
      notifyListeners();
      return true;
    });
    notifyListeners();
    return false;
  }

  Future fetchTrash({refresh = false}) async {
    if (refresh || _trash.isEmpty) {
      _trash.clear();
      await FirebaseFirestore.instance
          .collection("trash")
          .orderBy("date deleted", descending: true)
          .limit(50)
          .get()
          .then((QuerySnapshot querySnapshot) {
        addQuerySnapshotToList(querySnapshot, _trash);
        _lastTrash = querySnapshot.docs.last;
        notifyListeners();
        return true;
      });
    } else {
      notifyListeners();
      return false;
    }
  }
  Future<bool> fetchMoreTrash({refresh = false}) async {
    await FirebaseFirestore.instance
        .collection("trash")
        .orderBy("date deleted", descending: true)
        .startAfterDocument(_lastTrash!)
        .limit(50)
        .get()
        .then((QuerySnapshot querySnapshot) {
      addQuerySnapshotToList(querySnapshot, _trash);
      _lastTrash = querySnapshot.docs.last;
      notifyListeners();
      return true;
    });
    notifyListeners();
    return false;
  }

  Future fetchArchive({refresh = false}) async {
    if (refresh || _archivedReports.isEmpty) {
      print("fetching archive");
      _archivedReports.clear();
      await FirebaseFirestore.instance
          .collection("archive")
          .orderBy("report timestamp", descending: true)
          .limit(50)
          .get()
          .then((QuerySnapshot querySnapshot) {
        addQuerySnapshotToList(querySnapshot, _archivedReports);
        _lastArchivedReport = querySnapshot.docs.last;
        notifyListeners();
        return true;
      });
    } else {
      notifyListeners();
      return false;
    }
  }

  Future<bool> fetchMoreArchivedReports({refresh = false}) async {
    print("fetching more archive");
    await FirebaseFirestore.instance
        .collection("archive")
        .orderBy("report timestamp", descending: true)
        .startAfterDocument(_lastArchivedReport!)
        .limit(50)
        .get()
        .then((QuerySnapshot querySnapshot) {
      addQuerySnapshotToList(querySnapshot, _archivedReports);
      _lastArchivedReport = querySnapshot.docs.last;
      notifyListeners();
      return true;
    });
    notifyListeners();
    return false;
  }


  void addQuerySnapshotToList(QuerySnapshot querySnapshot, List<Report> list) {
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      list.add(Report(
          id: doc.id,
          reportTimestamp: DateTime.fromMillisecondsSinceEpoch(
              data["report timestamp"].seconds * 1000),
          personalData: data["personal data"],
          incidentData: data["incident data"]));
    }
  }

  //filtering and sorting
  Filters _filters = Filters(categories: [...categories]);

  Filters get filters => _filters;

  bool _isDateInRange(DateTime date, DateTimeRange? dateRange) {
    if (dateRange?.start != null && dateRange?.end != null) {
      print("===========");
      print(dateRange!.start);
      print(dateRange.end.add(const Duration(days: 1)));
      print(date.copyWith(
          hour: 0, minute: 0, second: 1, microsecond: 0, millisecond: 0));
      if (date
              .copyWith(
                  hour: 0, minute: 0, second: 1, microsecond: 0, millisecond: 0)
              .isAfter(dateRange.start) &&
          date
              .copyWith(
                  hour: 0, minute: 0, second: 1, microsecond: 0, millisecond: 0)
              .isBefore(dateRange.end.add(const Duration(days: 1)))) {
        print("true");
        return true;
      } else {
        print("false");
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
                DateTime incidentTimestamp =
                    DateTime.fromMillisecondsSinceEpoch(
                        report.incidentData["incident timestamp"].seconds *
                            1000);
                if (!_isDateInRange(incidentTimestamp, _filters.dateRange)) {
                  _selected.removeWhere((report) => report == report);
                  return false;
                }
              } else {
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
                DateTime incidentTimestamp =
                    DateTime.fromMillisecondsSinceEpoch(
                        report.incidentData["incident timestamp"].seconds *
                            1000);
                if (!_isDateInRange(incidentTimestamp, _filters.dateRange)) {
                  _selected.removeWhere((report) => report == report);
                  return false;
                }
              } else {
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
                DateTime incidentTimestamp =
                    DateTime.fromMillisecondsSinceEpoch(
                        report.incidentData["incident timestamp"].seconds *
                            1000);
                if (!_isDateInRange(incidentTimestamp, _filters.dateRange)) {
                  _selected.removeWhere((report) => report == report);
                  return false;
                }
              } else {
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
    _archivedReports
        .sort((a, b) => a.reportTimestamp.compareTo(b.reportTimestamp));
    if (reverse) {
      _reports = _reports.reversed.toList();
      _trash = _trash.reversed.toList();
      _archivedReports = _archivedReports.reversed.toList();
    }
    notifyListeners();
  }

  void sortReportsByIncidentTimestamp(bool reverse) {
    _reports.sort((a, b) => a.incidentData["incident timestamp"]
        .compareTo(b.incidentData["incident timestamp"]));
    _trash.sort((a, b) => a.incidentData["incident timestamp"]
        .compareTo(b.incidentData["incident timestamp"]));
    _archivedReports.sort((a, b) => a.incidentData["incident timestamp"]
        .compareTo(b.incidentData["incident timestamp"]));
    if (reverse) {
      _reports = _reports.reversed.toList();
      _trash = _trash.reversed.toList();
      _archivedReports = _archivedReports.reversed.toList();
    }
    notifyListeners();
  }

  void sortReportsByCategory(bool reverse) {
    _reports.sort((a, b) => a.incidentData["category"]
        .toUpperCase()
        .compareTo(b.incidentData["category"].toUpperCase()));
    _trash.sort((a, b) => a.incidentData["category"]
        .toUpperCase()
        .compareTo(b.incidentData["category"].toUpperCase()));
    _archivedReports.sort((a, b) => a.incidentData["category"]
        .toUpperCase()
        .compareTo(b.incidentData["category"].toUpperCase()));
    if (reverse) {
      _reports = _reports.reversed.toList();
      _trash = _trash.reversed.toList();
      _archivedReports = _archivedReports.reversed.toList();
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

  // Selections and highlighted
  final List<Report> _selected = [];

  UnmodifiableListView<Report> get selected => UnmodifiableListView(_selected);

  bool isEverythingSelected = false;

  void _updateSelectionStatus(PageType pageType) {
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

  void toggleSelectAll(PageType pageType) {
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

  void toggleSelection(Report report, PageType pageType) {
    if (_selected.contains(report)) {
      _selected.removeWhere((value) => value == report);
    } else {
      _selected.add(report);
    }
    _updateSelectionStatus(pageType);
    notifyListeners();
  }

  void clearSelections() {
    _selected.clear();
    isEverythingSelected = false;
    notifyListeners();
  }

  bool isSelected(Report report) {
    return _selected.contains(report);
  }

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

  //folder management

  //trash
  void moveReportToTrash(Report report, pageType) {
    report.moveToTrash(pageType);
    switch (pageType) {
      case PageType.reportsPage:
        _reports.remove(report);
        break;
      case PageType.archivePage:
        _archivedReports.remove(report);
        break;
    }
    _updateSelectionStatus(pageType);
    notifyListeners();
  }

  void moveSelectedToTrash(PageType pageType) {
    for (var report in _selected) {
      moveReportToTrash(report, pageType);
    }
    _selected.clear();
    _updateSelectionStatus(pageType);
    notifyListeners();
  }

  void restoreFromTrash(Report report) {
    report.restoreFromTrash();
    _trash.remove(report);
    _updateSelectionStatus(PageType.trashPage);
    notifyListeners();
  }

  void restoreSelectedFromTrash({PageType pageType = PageType.trashPage}) {
    for (var report in _selected) {
      restoreFromTrash(report);
    }
    _selected.clear();
    _updateSelectionStatus(pageType);
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

  //archive
  void archiveReport(Report report) {
    report.archive();
    _reports.remove(report);
    _updateSelectionStatus(PageType.reportsPage);
    notifyListeners();
  }

  void archiveSelected() {
    for (var report in _selected) {
      archiveReport(report);
    }
    _selected.clear();
    _updateSelectionStatus(PageType.reportsPage);
    notifyListeners();
  }

  void unarchiveReport(Report report) {
    report.unarchive();
    _archivedReports.remove(report);
    _updateSelectionStatus(PageType.archivePage);
    notifyListeners();
  }

  void unarchiveSelected() {
    for (var report in _selected) {
      unarchiveReport(report);
    }
    _selected.clear();
    _updateSelectionStatus(PageType.archivePage);
    notifyListeners();
  }

  //download all images in a zip file\
  Future<void> downloadImages() async {
    throw NoSuchMethodError;
  }
}
