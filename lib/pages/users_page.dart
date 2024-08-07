import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/public_pages/customAppBar.dart';
import 'package:project/public_pages/navbar.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/firebase_service.dart';
import 'package:project/services/localStorage_service.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  initState() {
    getUserInfo();
    super.initState();
  }

  final _alertService = AlertService();
  final _firebaseService = FirebaseService(DbConstants.portfoyTable);
  final _name = TextEditingController();
  final _note = TextEditingController();
  final _localStorageService = LocalStorageService();
  final _formKey = GlobalKey<FormState>();
  late Future<QuerySnapshot> targetsFuture;
  Future<void> getUserInfo() async {
    var result = await _localStorageService.refreshPage();
    if (result != null) {
      setState(() {
        _firebaseService.loginUser = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _firebaseService.currentUser;
    final currentUserId = currentUser != null ? currentUser!.id : '';
    return Scaffold(
        drawer: const Navbar(),
        appBar: const CustomAppBar(
          title: 'Kullanıcılar',
          backgroundColor: ColorConstants.generalColor,
          titleColor: Colors.white,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(DbConstants.UserTable)
              .snapshots(),
          builder: (context, snapshots) {
            if (snapshots.hasError) {
              return Center(child: Text('Error: ${snapshots.error}'));
            }
            if (!snapshots.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshots.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot documentSnapshot =
                          snapshots.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 80,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: ColorConstants.generalColor),
                          child: Row(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "İsim : ${documentSnapshot['fullName']}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        "Kullanıcı Adı : ${documentSnapshot['userName']}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        "Şifre : ${documentSnapshot['password']}",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w100,
                                            fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ));
  }
}
