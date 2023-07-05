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
