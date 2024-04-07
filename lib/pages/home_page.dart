import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_notes/firebase/firebase_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseServices firebaseServices = FirebaseServices();
  final TextEditingController controller = TextEditingController();

  void openDialogBox(String? docID) {
    String action;

    if (docID == null) {
      action = 'Save';
    } else {
      action = 'Update';
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: controller,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                firebaseServices.addNotes(controller.text);
              } else {
                firebaseServices.updateNotes(docID, controller.text);
              }
              controller.clear();
              Navigator.pop(context);
            },
            child: Text(action),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Notes',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 24),)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openDialogBox(null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: firebaseServices.getNotes(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;

              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document = notesList[index];
                  String? docID = document.id;

                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String notesText = data['note'];
                  var time = data['timeStamp'].toDate();
                  //var date = DateTime.fromMillisecondsSinceEpoch(time * 1000);
                  String formattedDate = DateFormat('yyyy-MM-dd').format(time);
                  String formattedTime = DateFormat('HH:mm:ss').format(time);

                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade300),
                      child: ListTile(
                          title: Text(notesText,style: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                          subtitle: Text('$formattedDate / $formattedTime'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => openDialogBox(docID),
                                icon: const Icon(Icons.settings),
                              ),
                              IconButton(
                                onPressed: () =>
                                    firebaseServices.deleteNotes(docID),
                                icon: const Icon(Icons.delete),
                              )
                            ],
                          )),
                    ),
                  );
                },
              );
            } else {
              return const Text("no notes found");
            }
          }),
    );
  }
}
