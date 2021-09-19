import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mytodo/config/config.dart';

import 'loginScree.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController taskController = TextEditingController();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  User user;

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    getUid();
    super.initState();
  }

  void getUid() async {
    User u = auth.currentUser;
    setState(() {
      user = u;
    });
  }

  void showAddTaskDialog() {
    showDialog(
        context: context,
        builder: (ctx) {
          return SimpleDialog(
            title: Text("Add Task"),
            children: [
              Container(
                  margin: EdgeInsets.all(10),
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Write your task here",
                        labelText: "Task"),
                  )),
              Container(
                margin: EdgeInsets.all(10),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: Text("Cancel"),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          String task = taskController.text.trim();
                          print(task);

                          db
                              .collection("users")
                              .doc(user.uid)
                              .collection("tasks")
                              .add({"task": task, "date": DateTime.now()});

                          Navigator.of(ctx).pop();
                        },
                        child: Text("Add"))
                  ],
                ),
              )
            ],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddTaskDialog();
          // taskController.text = "";
        },
        child: Icon(
          Icons.add,
          color: Colors.black,
        ),
        elevation: 4,
        backgroundColor: primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
            IconButton(
                onPressed: () async {
                  await auth.signOut();
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                  // Navigator.of(context).pop();
                },
                icon: Icon(Icons.person_outline))
          ],
        ),
      ),
      body: Container(
          margin: EdgeInsets.only(top: 100),
          child: StreamBuilder(
              stream: db
                  .collection("users")
                  .doc(user.uid)
                  .collection("tasks")
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.docs.isNotEmpty) {
                    return ListView(
                      children:
                          snapshot.data.docs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data = document.data();
                        return new ListTile(
                            title: new Text(data['task']),
                            onTap: () {},
                            trailing: IconButton(
                              onPressed: () {
                                // print(document.id);
                                db
                                    .collection("users")
                                    .doc(user.uid)
                                    .collection("tasks")
                                    .doc(document.id)
                                    .delete();
                              },
                              icon: Icon(Icons.delete_outline, color: Colors.red),
                            ));
                      }).toList(),
                    );
                  } else {
                    return Container(
                      child: Center(
                        child: Image(image: AssetImage("assets/no_task.png")),
                      ),
                    );
                  }
                }
                // if (snapshot.connectionState == ConnectionState.waiting) {
                //   return Center(child: CircularProgressIndicator());
                return Container(
                  child: Center(
                    child: Image(image: AssetImage("assets/no_task.png")),
                  ),
                );
                // }
              })),
    );
  }

}
