import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main_form/database_communication.dart';

class DataAndSelectionManager extends ChangeNotifier {
  //Data
  List<Submission> _submissions = [];

  UnmodifiableListView<Submission> get submissions => UnmodifiableListView(_submissions);

  Future fetchSubmissions() async {
    //TODO handle limit and load more
    if (_submissions.isNotEmpty) {
      return false;
    }
    await FirebaseFirestore.instance
        .collection("submissions")
        .orderBy("submission timestamp", descending: true)
        .limit(100)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _submissions.add(Submission(
            id: doc.id,
            submissionTimestamp: DateTime.fromMillisecondsSinceEpoch(
                data["submission timestamp"].seconds * 1000),
            personalData: data["personal data"],
            eventData: data["event data"]));
      });
      notifyListeners();
      return true;
    });
  }

  // Selections
  Map<int, Submission> _selected = {};

  UnmodifiableMapView<int, Submission> get selected => UnmodifiableMapView(_selected);

  bool isEverythingSelected = false;

  void _updateSelectionStatus() {
    if (_selected.length == _submissions.length) {
      isEverythingSelected = true;
    } else {
      isEverythingSelected = false;
    }
  }

  void toggleSelectAll() {
    if (_selected.length == _submissions.length) { //
      _selected.clear();
    } else {
      _selected.clear();
      for (int i = 0; i < _submissions.length; i++) {
        _selected[i] = _submissions[i];
      }
    }
    _updateSelectionStatus();
    notifyListeners();
  }

  void toggleSelection(int index, Submission submission) {
    if (_selected.containsKey(index)) {
      _selected.remove(index);
    } else {
      _selected[index] = submission;
    }
    _updateSelectionStatus();
    notifyListeners();
  }

  bool isSelected(int index) {
    return _selected.containsKey(index);
  }

  void clearSelection() {
    _selected.clear();
    _updateSelectionStatus();
    notifyListeners();
  }
}