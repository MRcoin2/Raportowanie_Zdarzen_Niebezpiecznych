import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main_form/database_communication.dart';

class DataAndSelectionManager extends ChangeNotifier {
  //Data
  List<Report> _reports = [];

  UnmodifiableListView<Report> get reports =>
      UnmodifiableListView(_reports);

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
        querySnapshot.docs.forEach((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _reports.add(Report(
              id: doc.id,
              reportTimestamp: DateTime.fromMillisecondsSinceEpoch(
                  data["report timestamp"].seconds * 1000),
              personalData: data["personal data"],
              incidentData: data["event data"]));
        });
        notifyListeners();
        return true;
      });
    } else {
      notifyListeners();
      return false;
    }}

    // Selections
    List< Report> _selected = [];

    UnmodifiableListView<Report> get selected =>
        UnmodifiableListView(_selected);

    bool isEverythingSelected = false;

    void _updateSelectionStatus() {
      if (_selected.length == _reports.length) {
        isEverythingSelected = true;
      } else {
        isEverythingSelected = false;
      }
    }

    void toggleSelectAll() {
      if (_selected.length == _reports.length) { //
        _selected.clear();
      } else {
        _selected.clear();
        for (int i = 0; i < _reports.length; i++) {
          _selected[i] = _reports[i];
        }
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

    void deleteReport(Report report){
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
  }