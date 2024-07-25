import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/firebase_service.dart';
import 'package:project/services/localStorage_service.dart';

class TargetPage extends StatefulWidget {
  const TargetPage({super.key});

  @override
  State<TargetPage> createState() => _TargetPageState();
}

class _TargetPageState extends State<TargetPage> {
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

  Future<void> deleteTarget(String id) async {
    await _firebaseService.deleteTarget(id);
  }

  void clearTexts() {
    _name.clear();
    _note.clear();
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _firebaseService.currentUser;
    final currentUserId = currentUser != null ? currentUser!.id : '';
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              context.go('/portfoyPage');
            },
          ),
          title: const Text(
            'Hedefler',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: ColorConstants.generalColor,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () {
                        clearTexts();
                        addTarget(context);
                      },
                      icon: const Icon(Icons.add)),
                ],
              ),
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(DbConstants.TargetTable)
              .where('userId', isEqualTo: currentUserId)
              .orderBy('date')
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
                      String documentId = documentSnapshot.id;
                      var status = bool.tryParse(
                              documentSnapshot['status'].toString()) ??
                          false;
                      var datas = snapshots.data!.docs;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 60,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: ColorConstants.generalColor),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    fillColor: WidgetStateProperty.all<Color>(
                                        Colors.white),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(5))),
                                    value: status,
                                    activeColor: Colors.white,
                                    checkColor: ColorConstants.generalColor,
                                    onChanged: (bool? value) {
                                      setState(() async {
                                        status = value!;
                                        await _firebaseService
                                            .updateTargetStatus(
                                                documentSnapshot, status);
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      documentSnapshot['name'],
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                    ),
                                    documentSnapshot['note']
                                            .toString()
                                            .isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Text(
                                              documentSnapshot['note'],
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          )
                                        : const Padding(
                                            padding: EdgeInsets.all(1)),
                                  ],
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _alertService.openModal(
                                          context,
                                          () {},
                                          () => deleteTarget(documentId),
                                          DialogType.warning,
                                          'Dikkat !',
                                          'Seçili Hedef Silinecektir.Onaylıyor musunuz ?',
                                          'İptal',
                                          'Sil');
                                    },
                                  )),
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

  Future<dynamic> addTarget(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 15),
                child: Text('Hedef Ekle',
                    style: TextStyle(
                        color: ColorConstants.generalColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.sizeOf(context).width * .4,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen Hedef Giriniz';
                          }
                          if (value.length > 50) {
                            return 'En Fazla 50 karakter girilebilir';
                          }
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        controller: _name,
                        decoration: const InputDecoration(
                            label: Text('Hedef *'),
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorConstants.generalColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _note,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length > 50) {
                            return 'En Fazla 50 karakter girilebilir';
                          }
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        decoration: const InputDecoration(
                            label: Text('Hedef Not'),
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.grey)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.black)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorConstants.generalColor),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.grey),
                  minimumSize:
                      WidgetStateProperty.all<Size>(const Size(80, 40)),
                  maximumSize:
                      WidgetStateProperty.all<Size>(const Size(80, 40)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'İptal',
                  style: TextStyle(color: Colors.white),
                )),
            TextButton(
                style: ButtonStyle(
                    minimumSize:
                        WidgetStateProperty.all<Size>(const Size(80, 40)),
                    maximumSize:
                        WidgetStateProperty.all<Size>(const Size(80, 40)),
                    backgroundColor:
                        WidgetStateProperty.all(ColorConstants.generalColor)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    var result = await _firebaseService.createTarget(
                        _name.text, _note.text, DateTime.now());
                    if (result!.isNotEmpty && result == 'success') {
                      clearTexts();
                      Navigator.pop(context);
                    }
                  }
                },
                child:
                    const Text('Ekle', style: TextStyle(color: Colors.white)))
          ],
        );
      },
    );
  }
}
