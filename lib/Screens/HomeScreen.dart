import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled1/Utils/styless.dart';
import '../group_chats/group_chat_room.dart';
import 'ChatRoom.dart';
import 'Quize.dart';

class HomeScreen extends StatefulWidget {
  List<dynamic> membersList;

  HomeScreen({required this.membersList, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  Map<String, dynamic>? userMap;
  List groupList = [];

  @override
  void initState() {
    super.initState();
    getGroupDetails();
    get();
  }

  get() async {
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        userMap = value.data();
        //    userMap = value.docs[0].data();
        isLoading = false;
      });
    }).then((value) async {
      if (widget.membersList.contains(userMap!['uid'])) {
        Utils().toastMessage('Welcome Back');
      } else {
        widget.membersList.add(userMap!);

        await _firestore.collection('groups').doc('12345').update({
          "members": widget.membersList,
        });

        await _firestore
            .collection('users')
            .doc(userMap!['uid'])
            .collection('groups')
            .doc('12345')
            .set({"name": 'Gas New', "id": '12345'});
      }

      /*     bool isAlreadyExist = false;

      for (int i = 0; i < widget.membersList.length; i++) {
        if (widget.membersList[i]['uid'] == userMap!['uid']) {
          isAlreadyExist = true;
        }
      }

      if (!isAlreadyExist) {
        setState(() {
          widget.membersList.add({
            "name": userMap!['name'],
            "uid": userMap!['uid'],
            "isAdmin": false,
          });

          userMap = null;
        });
        await _firestore
            .collection('users')
            .doc(userMap!['uid'])
            .collection('groups')
            .doc('12345')
            .set({"name": 'Gas New', "id": '12345'});
      }*/
      /*
      widget.membersList.add(userMap!);

      await _firestore.collection('groups').doc('12345').update({
        "members": widget.membersList,
      });

      await _firestore
          .collection('users')
          .doc(userMap!['uid'])
          .collection('groups')
          .doc('12345')
          .set({"name": 'Gas New', "id": '12345'});
          */
    }).then((value) async {
      String uid = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .get()
          .then((value) {
        setState(() {
          groupList = value.docs;
          isLoading = false;
        });
      });
    });
  }

  Future getGroupDetails() async {
    await _firestore.collection('groups').doc('12345').get().then((chatMap) {
      widget.membersList = chatMap['members'];
      isLoading = false;
      setState(() {});
    });
  }

  getQnA() {}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff3A8BB8),
        elevation: 0.0,
        title: Text('H o m e  P a g e'),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: const Color(0xff3A8BB8),
                    child: ListTile(
                      textColor: Colors.white,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => GroupChatRoom(
                            groupName: groupList[index]['name'],
                            groupChatId: groupList[index]['id'],
                          ),
                        ),
                      ),
                      leading: const Icon(
                        Icons.group,
                        color: Colors.white,
                      ),
                      title: Text(groupList[index]['name']),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xff3A8BB8),
          tooltip: 'Quizs',
          child: const Icon(Icons.quiz),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const QuizPage(),
            ));
          }),
    );
  }
}
