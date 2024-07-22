import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/firebase_service.dart';

class PortfoyPage extends StatefulWidget {
  const PortfoyPage({super.key});

  @override
  State<PortfoyPage> createState() => _PortfoyPageState();
}

class _PortfoyPageState extends State<PortfoyPage> {
  @override
  void clearTexts() {
    _name.clear();
    _quantity.clear();
    _unitPrice.clear();
    _targetPrice.clear();
  }

  void close() {
    clearTexts();
    FirebaseService.exit();
    context.goNamed('Login');
  }

  final _alertService = AlertService();
  final _firebaseService = FirebaseService(DbConstants.portfoyTable);
  final _name = TextEditingController();
  final _quantity = TextEditingController();
  final _unitPrice = TextEditingController();
  final _targetPrice = TextEditingController();
  Widget build(BuildContext context) {
    final currentUser = FirebaseService.currentUser;
    final currentUserId = currentUser != null ? currentUser!.id : '';
    return Scaffold(
        appBar: AppBar(
          title: const Text('Portföy'),
          centerTitle: true,
          backgroundColor: Colors.deepOrange,
          leading: IconButton(
              onPressed: () async {
                _alertService.openModal(
                    context,
                    () {},
                    () => close(),
                    DialogType.warning,
                    'Dikkat !',
                    'Çıkış Yapmak İstediğinize Emin Misiniz ?',
                    'İptal',
                    'Çıkış Yap');
              },
              icon: const Icon(Icons.arrow_back)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () {
                        clearTexts();
                        _addOrUpdateModal(context, 'Hisse Ekle', false, '',
                            null, currentUserId);
                      },
                      icon: const Icon(Icons.add)),
                  IconButton(
                      onPressed: () async {
                        context.goNamed('UpdateUser');
                      },
                      icon: const Icon(Icons.person_2_sharp)),
                ],
              ),
            )
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection(DbConstants.portfoyTable)
              .where('userId', isEqualTo: currentUserId)
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
                      var datas = snapshots.data!.docs;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                                child: _SampleCard(
                              name: documentSnapshot['name'],
                              quantity: documentSnapshot['quantity'].toString(),
                              unitPrice:
                                  documentSnapshot['unitPrice'].toString(),
                              targetprice:
                                  documentSnapshot['targetPrice'].toString(),
                              id: documentId,
                              addOrUpdate: () => _addOrUpdateModal(
                                  context,
                                  'Hisse Düzenle',
                                  true,
                                  documentId,
                                  documentSnapshot,
                                  currentUserId),
                            )),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.deepOrange,
                  child: Column(
                    children: [
                      Text(
                          'Toplam Hisse Sayısı : ${snapshots.data!.docs.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      Text(
                        'Toplam Asıl Tutar : ${formatCurrency(generalTotalPrice(snapshots.data!.docs))}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Text(
                          'Toplam Hedef Tutar : ${formatCurrency(generalTargetTotalPrice(snapshots.data!.docs))}',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold))
                    ],
                  ),
                )
              ],
            );
          },
        ));
  }

  Future<dynamic> _addOrUpdateModal(BuildContext context, String title,
      bool isEdit, String id, DocumentSnapshot? model, String userId) {
    if (model != null) {
      _name.text = model['name'];
      _quantity.text = model['quantity'].toString();
      _unitPrice.text = model['unitPrice'].toString();
      _targetPrice.text = model['targetPrice'].toString();
    }
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 0, left: 15, right: 15, bottom: 15),
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                        label: Text('İsim *'),
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _quantity,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) => newValue.copyWith(
                          text: newValue.text.replaceAll(',', '.'),
                        ),
                      ),
                    ],
                    decoration: const InputDecoration(
                        label: Text('Adet *'),
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _unitPrice,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) => newValue.copyWith(
                          text: newValue.text.replaceAll(',', '.'),
                        ),
                      ),
                    ],
                    decoration: const InputDecoration(
                        label: Text('Birim Fiyat *'),
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _targetPrice,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9]+[,.]{0,1}[0-9]*')),
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) => newValue.copyWith(
                          text: newValue.text.replaceAll(',', '.'),
                        ),
                      ),
                    ],
                    decoration: const InputDecoration(
                        label: Text('Hedef Fiyat *'),
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.deepOrange))),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.grey)),
                  onPressed: () {
                    clearTexts();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: Colors.white),
                  )),
              !isEdit
                  ? TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.deepOrange)),
                      onPressed: () {
                        if (_name.text.isEmpty ||
                            _quantity.text.isEmpty ||
                            _unitPrice.text.isEmpty) {
                          showToast(
                              'Lütfen zorunlu alanları doldurunuz!', context);
                          return;
                        }
                        _firebaseService.add(
                            _name.text,
                            num.parse(_unitPrice.text),
                            num.parse(_quantity.text),
                            userId,
                            num.parse(_targetPrice.text));
                        Navigator.pop(context);
                      },
                      child: const Text('Ekle',
                          style: TextStyle(color: Colors.white)))
                  : TextButton(
                      style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.all(Colors.deepOrange)),
                      onPressed: () {
                        if (_name.text.isEmpty ||
                            _quantity.text.isEmpty ||
                            _unitPrice.text.isEmpty) {
                          showToast(
                              'Lütfen zorunlu alanları doldurunuz!', context);
                          return;
                        }
                        _firebaseService.update(
                            id,
                            _name.text,
                            num.parse(_unitPrice.text),
                            num.parse(_quantity.text),
                            userId,
                            num.parse(_targetPrice.text));
                        Navigator.pop(context);
                      },
                      child: const Text('Güncelle',
                          style: TextStyle(color: Colors.white))),
            ],
          );
        });
  }
}

class _SampleCard extends StatelessWidget {
  const _SampleCard(
      {required this.name,
      required this.quantity,
      required this.unitPrice,
      required this.targetprice,
      required this.id,
      this.addOrUpdate});
  final String name;
  final String quantity;
  final String unitPrice;
  final String targetprice;
  final String id;
  final Future<void> Function()? addOrUpdate;
  @override
  Widget build(BuildContext context) {
    final _firebaseService = FirebaseService(DbConstants.portfoyTable);
    final _alertService = AlertService();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () async {
        if (addOrUpdate != null) {
          await addOrUpdate!();
        }
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 150,
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
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                            'Birim Fiyat : ${formatCurrency(num.parse(unitPrice))}'),
                        Text('Toplam Adet : $quantity'),
                        Text(
                          'Toplam Tutar: ${formatCurrency(totalPrice(quantity, unitPrice))}',
                        ),
                        Text(
                          'Hedef Fiyat: ${formatCurrency(num.parse(targetprice))}',
                        ),
                        Text(
                          'Toplam Hedef Tutar: ${formatCurrency(totalTargetPrice(quantity, targetprice))}',
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
                                () => _firebaseService.delete(id),
                                DialogType.warning,
                                'Dikkat !',
                                'Seçili Hisse Silinecektir.Onaylıyor Musunuz ?',
                                'İptal',
                                'Sil',
                              );
                            },
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

num totalPrice(String quantity, String unitPrice) {
  var _quantitiy = num.tryParse(quantity) ?? 0;
  var _unitPrice = num.tryParse(unitPrice) ?? 0;
  var total = _quantitiy * _unitPrice;
  return total;
}

num totalTargetPrice(String quantity, String targetPrice) {
  var _quantitiy = num.tryParse(quantity) ?? 0;
  var _unitPrice = num.tryParse(targetPrice) ?? 0;
  var total = _quantitiy * _unitPrice;
  return total;
}

String formatCurrency(num amount) {
  final formatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
  return formatter.format(amount);
}

void showToast(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, textAlign: TextAlign.center),
  ));
}

num generalTotalPrice(List<QueryDocumentSnapshot<Object?>> data) {
  num total = 0;
  for (var i = 0; i < data.length; i++) {
    var document = data[i].data() as Map<String, dynamic>;
    var quantity = document['quantity'] ?? 0;
    var unitPrice = document['unitPrice'] ?? 0;
    total += quantity * unitPrice;
  }
  return total;
}

num generalTargetTotalPrice(List<QueryDocumentSnapshot<Object?>> data) {
  num total = 0;
  for (var i = 0; i < data.length; i++) {
    var document = data[i].data() as Map<String, dynamic>;
    var quantity = document['quantity'] ?? 0;
    var unitPrice = document['targetPrice'] ?? 0;
    total += quantity * unitPrice;
  }
  return total;
}
