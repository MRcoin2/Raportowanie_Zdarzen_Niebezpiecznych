import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main_form/database_communication.dart';

class DataAndSelectionManager extends ChangeNotifier {
  //Data
  List<Submission> _submissions = [];

  UnmodifiableListView<Submission> get submissions =>
      UnmodifiableListView(_submissions);

  Future fetchSubmissions({refresh = false}) async {
    //TODO handle limit and load more
    if (refresh || _submissions.isEmpty) {
      _submissions.clear();
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
    } else {
      notifyListeners();
      return false;
    }}

    // Selections
    List< Submission> _selected = [];

    UnmodifiableListView<Submission> get selected =>
        UnmodifiableListView(_selected);

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

    void toggleSelection(Submission submission) {
      if (_selected.contains(submission)) {
        _selected.removeWhere((value) => value == submission);
      } else {
        _selected.add(submission);
      }
      _updateSelectionStatus();
      notifyListeners();
    }

    bool isSelected(Submission submission) {
      return _selected.contains(submission);
    }

    void deleteSubmission(Submission submission){
      submission.deleteFromDatabase();
      _submissions.remove(submission);
      _updateSelectionStatus();
      notifyListeners();
    }
    void deleteSelected() {
      for (var submission in _selected) {
        deleteSubmission(submission);
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