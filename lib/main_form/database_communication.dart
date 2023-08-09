import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../admin_panel/providers.dart';

Future<void> submitForm(
    Map<String, dynamic> formData, List<XFile> images) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }
  FirebaseFirestore db = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  db.collection("reports").add(formData).then((docReference) async {
    for (var image in images) {
      storageRef
          .child("images/${docReference.id}/${image.name}")
          .putData((await image.readAsBytes()));
    }
    if (auth.currentUser?.isAnonymous ?? false) {
      auth.currentUser?.delete();
    }
  });
}

class Report {
  final String id;
  final DateTime reportTimestamp;
  final Map<String, dynamic> personalData;
  final Map<String, dynamic> incidentData;
  late final List<String> imageUrls = [];

  void moveToTrash(pageType) {
    switch (pageType) {
      case PageType.reportsPage:
        FirebaseFirestore.instance.collection("trash").doc(id).set(toMap());
        FirebaseFirestore.instance.collection("trash").doc(id).update({
          "date deleted": DateTime.now(),
        });
        FirebaseFirestore.instance.collection("reports").doc(id).delete();
        break;
      case PageType.archivePage:
        FirebaseFirestore.instance.collection("trash").doc(id).set(toMap());
        FirebaseFirestore.instance.collection("trash").doc(id).update({
          "date deleted": DateTime.now(),
        });
        FirebaseFirestore.instance.collection("archive").doc(id).delete();
        break;
    }
  }

  void restoreFromTrash() {
    FirebaseFirestore.instance.collection("reports").doc(id).set(toMap());
    FirebaseFirestore.instance.collection("trash").doc(id).delete();
    FirebaseFirestore.instance.collection("reports").doc(id).update({
      "date deleted": FieldValue.delete(),
    });
  }

  void deletePermanently() {
    FirebaseFirestore.instance.collection("trash").doc(id).delete();
    FirebaseStorage.instance.ref().child("images/$id").listAll().then((value) {
      for (var item in value.items) {
        item.delete();
      }
    });
  }

  void archive() {
    //Add the document to the "trash" collection and delete from "reports"
    FirebaseFirestore.instance.collection("archive").doc(id).set(toMap());
    FirebaseFirestore.instance.collection("reports").doc(id).delete();
  }

  void unarchive() {
    FirebaseFirestore.instance.collection("reports").doc(id).set(toMap());
    FirebaseFirestore.instance.collection("archive").doc(id).delete();
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

  Future<List<String>> getImageUrls() async {
    if (imageUrls.isNotEmpty) {
      return imageUrls;
    }
    else {
      ListResult imageRef = await FirebaseStorage.instance.ref().child("images/$id").listAll();
      for (var image in imageRef.items) {
        imageUrls.add(await image.getDownloadURL());
      }
      print(imageUrls);
      return imageUrls;
    }
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
