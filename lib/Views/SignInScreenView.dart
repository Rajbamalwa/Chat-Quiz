import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../Screens/HomeScreen.dart';
import '../Utils/styless.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreenView extends StatefulWidget {
  const SignInScreenView({Key? key}) : super(key: key);

  @override
  State<SignInScreenView> createState() => _SignInScreenViewState();
}

class _SignInScreenViewState extends State<SignInScreenView> {
  TextEditingController controller = TextEditingController();
  bool loading = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance.currentUser;
  List membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();

    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore.collection('groups').doc('12345').get().then((chatMap) {
      membersList = chatMap['members'];
      print(membersList);
      isLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff3A8BB8),
      appBar: AppBar(
        backgroundColor: const Color(0xff3A8BB8),
        title: const Text('Welcome to Gas'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: Styles.friendsBox(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          child: Text(
                            'Sign In',
                            style: Styles.h1()
                                .copyWith(color: const Color(0xff3A8BB8)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TextFormField(
                            controller: controller,
                            maxLines: 1,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.drive_file_rename_outline),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.grey,
                                      style: BorderStyle.solid)),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(
                                      color: Colors.grey,
                                      style: BorderStyle.none)),
                              labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 21),
                              label: const Text('UserName'),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(10, 20, 20, 1),
                              child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    if (controller.text.isEmpty) {
                                      Utils()
                                          .toastMessage('Please Type UserName');
                                    } else {
                                      FirebaseAuth.instance.currentUser!
                                          .updateDisplayName(
                                              controller.text.toString())
                                          .then((value) async {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(_auth!.uid)
                                            .set({
                                          "name": controller.text.toString(),
                                          "status": "unavailable",
                                          "uid": _auth!.uid,
                                        }).then((value) async {});
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => HomeScreen(
                                                      membersList: membersList,
                                                    )));
                                      });
                                    }
                                  },
                                  child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      height: 60,
                                      child: Card(
                                        color: Color(0xff3A8BB8),
                                        child: Center(
                                            child: loading
                                                ? const CircularProgressIndicator(
                                                    color: Colors.white)
                                                : const Text(
                                                    'Next',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 22),
                                                  )),
                                      )))),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
