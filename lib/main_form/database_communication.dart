import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

void submitForm(Map<String, dynamic> formData, List<XFile> images) {
  FirebaseFirestore db = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  db.collection("submissions").add(formData).then((docReference) async {
    print(docReference.id);
    for (var image in images) {
      storageRef
          .child("images/${docReference.id}/${image.name}")
          .putData((await image.readAsBytes()));
    }
  });
}

// {
// "submission timestamp": DateTime.now(),
// "personal data": {
// "name": _nameController.text,
// "surname": _surnameController.text,
// "email": _emailController.text,
// "phone": _phoneController.text,
// "affiliation": _affiliationController.text,
// "status": _chosenStatus,
// },
// "event data": {
// //parse date and time to DateTime
// "event timestamp": DateFormat('dd.MM.yyyy hh:mm').parse(
// "${_dateController.text} ${_timeController.text}"),
// "date": _dateController.text,
// "time": _timeController.text,
// "place": _placeController.text,
// "category": _chosenCategory == "inne..."
// ? _otherCategoryController.text
//     : _chosenCategory,
// "description": _descriptionController.text,
// },
// class based on the above map
class Submission {
  final String id;
  final DateTime submissionTimestamp;
  final Map<String, dynamic> personalData;
  final Map<String, dynamic> eventData;

  Submission(
      {required this.id,
        required this.submissionTimestamp,
      required this.personalData,
      required this.eventData});

  Map<String, dynamic> toMap() {
    return {
      "submission timestamp": submissionTimestamp,
      "personal data": personalData,
      "event data": eventData,
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

class EventData {
  final DateTime eventTimestamp;
  final String date;
  final String time;
  final String place;
  final String category;
  final String description;

  EventData(
      {required this.eventTimestamp,
      required this.date,
      required this.time,
      required this.place,
      required this.category,
      required this.description});

  Map<String, dynamic> fromMap(Map<String, dynamic> map) {
    return {
      "event timestamp": map["event timestamp"],
      "date": map["date"],
      "time": map["time"],
      "place": map["place"],
      "category": map["category"],
      "description": map["description"],
    };
  }

  Map<String, dynamic> toMap() {
    return {
      "event timestamp": eventTimestamp,
      "date": date,
      "time": time,
      "place": place,
      "category": category,
      "description": description,
    };
  }
}
