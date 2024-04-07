import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseServices {
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');

  // add notes
  Future<void> addNotes(String note) {
    return notes.add({
      'note': note,
      'timeStamp': Timestamp.now(),
    });
  }

  // get notes

  Stream<QuerySnapshot> getNotes() {
    final noteStream = notes.orderBy('timeStamp', descending: true).snapshots();
    return noteStream;
  }

  // update notes

  Future<void> updateNotes(String docId, String note) {
    return notes.doc(docId).update({
      'note': note,
      'timeStamp': Timestamp.now(),
    });
  }

  //delete notes

  Future<void> deleteNotes(String docID) {
    return notes.doc(docID).delete();
  }
}
