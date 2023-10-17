import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../admin_panel/providers.dart';

Future<String> submitForm(
    Map<String, dynamic> formData, List<XFile> images) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    throw Exception("not verified");
  }
  FirebaseFirestore db = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  late DocumentReference<Map<String, dynamic>> docReference;

  await db.collection("reports").add(formData).then((_docReference) async {
    docReference = _docReference;
    for (var image in images) {
      await storageRef
          .child("images/${_docReference.id}/${image.name}")
          .putData((await image.readAsBytes()));
    }
  });
  return docReference.id;
}

Future<void> updateReport(
    Map<String, dynamic> formData, List<XFile> images, String reportId) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  if (auth.currentUser == null) {
    throw Exception("not verified");
  }
  // DocumentReference docRef = await findReportById(reportId);
  List<String> collectionNames = ["reports", "archive", "trash"];

  for (String collectionName in collectionNames) {
    try{
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(reportId)
          .update(formData).then((value) => print("updated successfully")).onError((error, stackTrace) => print("update failed"));
    }
    catch(e){
      collectionNames.remove(collectionName);
    }
    if (collectionNames.isEmpty){
      throw Exception("Report not found");
    }
  }

  try {
    final storageRef = FirebaseStorage.instance.ref();
    for (var image in images) {
      await storageRef
          .child("images/$reportId/${image.name}")
          .putData((await image.readAsBytes()));
    }
  } catch (e) {
    rethrow;
  }
}

class Report {
  String id;
  bool hasBeenEdited;
  final String additionalInfo;
  final DateTime reportTimestamp;
  final Map<String, dynamic> personalData;
  final Map<String, dynamic> incidentData;
  late List<List<String>> imageUrls = [];

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
        required this.additionalInfo,
      required this.hasBeenEdited,
      required this.reportTimestamp,
      required this.personalData,
      required this.incidentData});

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "hasBeenEdited": hasBeenEdited,
      "additionalInfo": additionalInfo,
      "report timestamp": reportTimestamp,
      "personal data": personalData,
      "incident data": incidentData,
    };
  }

  Future<List<List<String>>> getImageUrls() async {
    //returns a list of tuples (url, name)
    if (imageUrls.isNotEmpty) {
      return imageUrls;
    } else {
      try {
        ListResult imageRef =
            await FirebaseStorage.instance.ref().child("images/$id").listAll();
        for (var image in imageRef.items) {
          imageUrls.add([await image.getDownloadURL(), image.name]);
        }
      } catch (e) {
        return [];
      }
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
      required this.description,});

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

Future<DocumentReference> findReportById(String reportId) async {
  //search three collections for a report
  DocumentReference? docRef;
  docRef = await FirebaseFirestore.instance
      .collection("reports")
      .doc(reportId)
      .get()
      .then((document) {
    if (document.exists) {
      return document.reference;
    } else {
      return null;
    }
  });
  docRef ??= await FirebaseFirestore.instance
      .collection("archive")
      .doc(reportId)
      .get()
      .then((document) {
    if (document.exists) {
      return document.reference;
    } else {
      return null;
    }
  });
  docRef ??= await FirebaseFirestore.instance
      .collection("trash")
      .doc(reportId)
      .get()
      .then((document) {
    if (document.exists) {
      return document.reference;
    } else {
      return null;
    }
  });
  if (docRef == null) {
    throw Exception("Report not found");
  }
  return docRef;
}

Future<bool> hasReportBeenEdited(String reportId) async {
  //login anonymous user
  FirebaseAuth.instance.setPersistence(Persistence.NONE);
  FirebaseAuth.instance.signInAnonymously();
  return false; //TODO create a rule in firebase to access the document here and check if it exists
  DocumentReference docRef = await findReportById(reportId);
  try {
    return docRef.get().then((document) {
      return document["hasBeenEdited"];
    });
  } catch (e) {
    rethrow;
  }
}
