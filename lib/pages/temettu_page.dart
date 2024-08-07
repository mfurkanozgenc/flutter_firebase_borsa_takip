import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/public_pages/customAppBar.dart';
import 'package:project/public_pages/navbar.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/firebase_service.dart';
import 'package:project/services/localStorage_service.dart';

class TemettuPage extends StatefulWidget {
  const TemettuPage({super.key});

  @override
  State<TemettuPage> createState() => _TemettuPageState();
}

class _TemettuPageState extends State<TemettuPage> {
  @override
  initState() {
    getUserInfo();
    super.initState();
    _selectedYear = DateTime.now().year;
    _date.text = _selectedYear.toString();
  }

  final TextEditingController _date = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final _alertService = AlertService();
  final _formKey = GlobalKey<FormState>();
  num totalPrice = 0;
  double _total = 0;
  int? _selectedYear;
  final _localStorageService = LocalStorageService();
  final _firebaseService = FirebaseService(DbConstants.portfoyTable);
  Future<void> getUserInfo() async {
    var result = await _localStorageService.refreshPage();
    var total = await getTotalPrice(0);
    if (result != null) {
      setState(() {
        _firebaseService.loginUser = result;
        _total = total;
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
        title: 'Temettüler',
        titleDescription:
            'Sadece ${DateTime.now().year} Yılına Ait Temettüler Listelenir',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      _name.text = "";
                      _price.text = "";
                      _addTemettu();
                    },
                    icon: const Icon(Icons.add)),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _date,
              decoration: const InputDecoration(
                  labelText: 'Yıl',
                  labelStyle: TextStyle(color: Colors.black),
                  filled: true,
                  prefixIcon: Icon(Icons.calendar_month),
                  prefixIconColor: Colors.black,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  focusedBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: ColorConstants.generalColor))),
              readOnly: true,
              onTap: () async {
                _selectYear();
                var total = await getTotalPrice(0);
                setState(() {
                  _total = total;
                });
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('temettus')
                .where('userId', isEqualTo: currentUserId)
                .where('year', isEqualTo: _selectedYear)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Bir hata oluştu: ${snapshot.error}');
              }

              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Center(child: CircularProgressIndicator());
                default:
                  return Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 20.0,
                        mainAxisSpacing: 20.0,
                      ),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot document = snapshot.data!.docs[index];
                        return Card(
                          elevation: 10,
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      document['name'].toString().toUpperCase(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        "${document['price']} ₺",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: -8,
                                top: -8,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: ColorConstants.generalColor,
                                  ),
                                  onPressed: () {
                                    _alertService.openModal(
                                      context,
                                      () {},
                                      () async {
                                        _firebaseService
                                            .deletrTemettu(document.id);
                                        ;
                                        var result = await getTotalPrice(0);
                                        setState(() {
                                          _total = result;
                                        });
                                      },
                                      DialogType.error,
                                      'Dikkat !',
                                      'Seçili Hisse Silinecektir.Onaylıyor Musunuz ?',
                                      'İptal',
                                      'Sil',
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
              }
            },
          ),
          Container(
            decoration: const BoxDecoration(
                color: ColorConstants.generalColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
            height: MediaQuery.of(context).size.height * 0.17,
            width: MediaQuery.of(context).size.width * 0.9,
            child: FutureBuilder<double>(
              future: getTotalPrice(0),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('');
                } else if (snapshot.hasError) {
                  return const Text('');
                } else {
                  double totalPrice = snapshot.data ?? 0;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Toplam Temettü Tutarı :",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${_total.toStringAsFixed(2)} ₺",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Aylık Miktar (Toplam / 12) :",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${(_total / 12).toStringAsFixed(2)} ₺",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Haftalık Miktar (Toplam / 52) :",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${(_total / 52).toStringAsFixed(2)} ₺",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Günlük Miktar (Toplam / 365) :",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${(_total / 365).toStringAsFixed(2)} ₺",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }

  Future<double> getTotalPrice(int? year) async {
    double totalPrice = 0;
    final currentUser = _firebaseService.currentUser;
    final currentUserId = currentUser != null ? currentUser!.id : '';
    var listNew = FirebaseFirestore.instance
        .collection('temettus')
        .where('userId', isEqualTo: currentUserId)
        .where('year', isEqualTo: year! > 0 ? year : _selectedYear)
        .snapshots();
    await for (var snapshot in listNew) {
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        double price = (data['price'] as num?)?.toDouble() ?? 0;
        totalPrice += price;
      }
      break;
    }
    return await totalPrice;
  }

  Future<void> _selectYear() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = _selectedYear ?? DateTime.now().year;
        return AlertDialog(
          title: const Text('Yıl Seçiniz'),
          content: SizedBox(
            height: 200,
            width: 300,
            child: YearPicker(
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              currentDate: DateTime(_selectedYear ?? 2024),
              selectedDate: DateTime(selectedYear),
              onChanged: (DateTime dateTime) async {
                var total = await getTotalPrice(dateTime.year);
                setState(() {
                  selectedYear = dateTime.year;
                  _total = total;
                });

                Navigator.pop(context, dateTime);
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
        _date.text = picked.year.toString();
      });
    }
  }

  Future<dynamic> _addTemettu() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: const Column(
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(top: 0, left: 15, right: 15, bottom: 15),
                  child: Text('Temettü Ekle',
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
                color: Colors.transparent,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen İsim Giriniz';
                            }
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(20)
                          ],
                          controller: _name,
                          decoration: const InputDecoration(
                              label: Text('Hisse Adı*'),
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen Tutar Giriniz';
                            }
                          },
                          controller: _price,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) => newValue.copyWith(
                                text: newValue.text.replaceAll(',', '.'),
                              ),
                            ),
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                              label: Text('Tutar *'),
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
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
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
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10))),
                      minimumSize:
                          WidgetStateProperty.all<Size>(const Size(80, 40)),
                      maximumSize:
                          WidgetStateProperty.all<Size>(const Size(80, 40)),
                      backgroundColor:
                          WidgetStateProperty.all(ColorConstants.generalColor)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await _firebaseService.addTemettu(
                          _name.text, num.parse(_price.text));
                      var result = await getTotalPrice(0);
                      setState(() {
                        _total = result;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child:
                      const Text('Ekle', style: TextStyle(color: Colors.white)))
            ],
          );
        });
  }
}
