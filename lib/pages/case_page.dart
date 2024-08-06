import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/public_pages/customAppBar.dart';
import 'package:project/public_pages/navbar.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/firebase_service.dart';
import 'package:project/services/localStorage_service.dart';

class CasePage extends StatefulWidget {
  const CasePage({super.key});

  @override
  State<CasePage> createState() => _CasePageState();
}

class _CasePageState extends State<CasePage> {
  final _alertService = AlertService();
  final _firebaseService = FirebaseService(DbConstants.portfoyTable);
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _localStorageService = LocalStorageService();
  final _formKey = GlobalKey<FormState>();

  @override
  void clearTexts() {
    _name.clear();
    _amount.clear();
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

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
      appBar: CustomAppBar(
        backgroundColor: ColorConstants.generalColor,
        titleColor: Colors.white,
        title: 'Kasa',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    clearTexts();
                    _addOrUpdateModal(
                        context, 'Kasaya Birim Ekle', '', null, currentUserId);
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(DbConstants.CaseTable)
            .where('userId', isEqualTo: currentUserId)
            .orderBy('date')
            .snapshots(),
        builder: (context, snapshots) {
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
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: _SampleCard(
                          name: documentSnapshot['name'],
                          amount: documentSnapshot['amount'].toString(),
                          id: documentId,
                          addOrUpdate: null,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<dynamic> _addOrUpdateModal(BuildContext context, String title,
      String id, DocumentSnapshot? model, String userId) {
    if (model != null) {
      _name.text = model['name'];
      _amount.text = model['quantity'].toString();
    }
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 15, right: 15, bottom: 15),
                child: Text(title,
                    style: const TextStyle(
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
                            return 'Lütfen Birim İsmi Giriniz';
                          }
                        },
                        inputFormatters: [LengthLimitingTextInputFormatter(50)],
                        controller: _name,
                        decoration: const InputDecoration(
                          label: Text('Birim İsmi *'),
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: ColorConstants.generalColor),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Lütfen Tutar Giriniz';
                          }
                          return null;
                        },
                        controller: _amount,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^-?\d*(,\d*)?$'),
                          ),
                          TextInputFormatter.withFunction(
                            (oldValue, newValue) => newValue.copyWith(
                              text: newValue.text.replaceAll('.', ','),
                            ),
                          ),
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: const InputDecoration(
                          label: Text(
                              'Tutar (Giderler İçin Eksili Tutar Giriniz (-) ) *'),
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
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
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                backgroundColor: WidgetStateProperty.all(Colors.grey),
                minimumSize: WidgetStateProperty.all<Size>(const Size(80, 40)),
                maximumSize: WidgetStateProperty.all<Size>(const Size(80, 40)),
              ),
              onPressed: () {
                clearTexts();
                Navigator.pop(context);
              },
              child: const Text(
                'İptal',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              style: ButtonStyle(
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                minimumSize: WidgetStateProperty.all<Size>(const Size(80, 40)),
                maximumSize: WidgetStateProperty.all<Size>(const Size(80, 40)),
                backgroundColor:
                    WidgetStateProperty.all(ColorConstants.generalColor),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _firebaseService.addCase(
                      _name.text, num.parse(_amount.text));
                  Navigator.pop(context);
                }
              },
              child: const Text('Ekle', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ).then((value) => null);
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard(
      {required this.name,
      required this.amount,
      required this.id,
      this.addOrUpdate});
  final String name;
  final String amount;
  final String id;
  final Future<void> Function()? addOrUpdate;

  @override
  Widget build(BuildContext context) {
    final _firebaseService = FirebaseService(DbConstants.portfoyTable);
    final _alertService = AlertService();
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Birim : $name',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                      Text(
                        'Tutar : $amount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_forever_outlined,
                          size: 30,
                        ),
                        onPressed: () {
                          _alertService.openModal(
                            context,
                            () {},
                            () => _firebaseService.deleteCase(id),
                            DialogType.error,
                            'Dikkat !',
                            'Seçili Kasa İşlemi Silinecektir.Onaylıyor Musunuz ?',
                            'İptal',
                            'Sil',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String formatCurrency(num amount) {
  final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  return formatter.format(amount);
}
