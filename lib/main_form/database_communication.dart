import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> submitForm(
    Map<String, dynamic> formData, List<XFile> images) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  if (_auth.currentUser == null) {
    await _auth.signInAnonymously();
  }
  FirebaseFirestore db = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  db.collection("reports").add(formData).then((docReference) async {
    print(docReference.id);
    for (var image in images) {
      storageRef
          .child("images/${docReference.id}/${image.name}")
          .putData((await image.readAsBytes()));
    }
    if (_auth.currentUser?.isAnonymous ?? false) {
      _auth.currentUser?.delete();
    }
  });
}

class Report {
  final String id;
  final DateTime reportTimestamp;
  final Map<String, dynamic> personalData;
  final Map<String, dynamic> incidentData;

  void deleteFromDatabase() {
    FirebaseFirestore.instance.collection("reports").doc(id).delete();
    FirebaseStorage.instance.ref().child("images/$id").listAll().then((value) {
      for (var item in value.items) {
        item.delete();
      }
    });
  }

  Report(
      {required this.id,
      required this.reportTimestamp,
      required this.personalData,
      required this.incidentData});

  Map<String, dynamic> toMap() {
    return {
      "report timestamp": reportTimestamp,
      "personal data": personalData,
      "incident data": incidentData,
    };
  }
}

class PersonalData {
  final String name;
  final String surname;
  final String email;
  final String? phone;
  final String affiliation;
  final String status;

  PersonalData(
      {required this.name,
      required this.surname,
      required this.email,
      this.phone,
      required this.affiliation,
      required this.status});

  factory PersonalData.fromMap(Map<String, dynamic> map) {
    return PersonalData(
      name: map["name"],
      surname: map["surname"],
      email: map["email"],
      phone: map["phone"],
      affiliation: map["affiliation"],
      status: map["status"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "surname": surname,
      "email": email,
      "phone": phone,
      "affiliation": affiliation,
      "status": status,
    };
  }
}

class IncidentData {
  final DateTime incidentTimestamp;
  final String date;
  final String time;
  final String location;
  final String category;
  final String description;

  IncidentData(
      {required this.incidentTimestamp,
      required this.date,
      required this.time,
      required this.location,
      required this.category,
      required this.description});

  Map<String, dynamic> fromMap(Map<String, dynamic> map) {
    return {
      "incident timestamp": map["incident timestamp"],
      "date": map["date"],
      "time": map["time"],
      "location": map["location"],
      "category": map["category"],
      "description": map["description"],
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "incident timestamp": incidentTimestamp,
      "date": date,
      "time": time,
      "location": location,
      "category": category,
      "description": description,
    };
  }
}
