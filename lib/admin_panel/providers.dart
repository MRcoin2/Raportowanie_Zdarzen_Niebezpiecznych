import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../main_form/database_communication.dart';

class SelectionManager extends ChangeNotifier {
  Map<int, String> _selected = {};

  Map<int, String> get selected => _selected;

  void addSelection(int index, String id) {
    _selected[index] = id;
    notifyListeners();
  }

  void toggleSelection(int index, String id) {
    if (_selected.containsKey(index)) {
      _selected.remove(index);
    } else {
      _selected[index] = id;
    }
    notifyListeners();
  }

  bool isSelected(int index) {
    return _selected.containsKey(index);
  }

  void clearSelection() {
    _selected.clear();
    notifyListeners();
  }
}

// provider for getting the data from the database from firestore /submissions/ collection and storing it in a list
class SubmissionData extends ChangeNotifier {
  List<Submission> _submissions = [];

  List<Submission> get submissions => _submissions;

  Future fetchSubmissions() async {
    //TODO handle limit and load more
    await FirebaseFirestore.instance
        .collection("submissions")
        .orderBy("submission timestamp", descending: true)
        .limit(5)
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        _submissions.add(Submission(
            id: doc.id,
            submissionTimestamp: DateTime.fromMillisecondsSinceEpoch(data["submission timestamp"].seconds * 1000),
            personalData: data["personal data"],
            eventData: data["event data"]));
      });
      notifyListeners();
      return true;
    });
  }

  Future deleteSubmissions(List<String> ids) async {
    for (var id in ids) {
      await FirebaseFirestore.instance
          .collection("submissions")
          .doc(id)
          .delete();
    }
    _submissions.removeWhere((element) => ids.contains(element.id));
    notifyListeners();
  }

  //declare fields visible in the debugger

}
