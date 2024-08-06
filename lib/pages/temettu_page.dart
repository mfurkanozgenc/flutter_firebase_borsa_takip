import 'package:flutter/material.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/public_pages/customAppBar.dart';
import 'package:project/public_pages/navbar.dart';
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
  }

  TextEditingController _date = TextEditingController();
  final _localStorageService = LocalStorageService();
  final _firebaseService = FirebaseService(DbConstants.portfoyTable);
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
    return Scaffold(
      drawer: const Navbar(),
      appBar: CustomAppBar(
        backgroundColor: ColorConstants.generalColor,
        titleColor: Colors.white,
        title: 'Temettüler',
        titleDescription:
            'Sadece ${DateTime.now().year} Bu Yılna Ait Temettüler Listelenir',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
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
              onTap: () {
                _selectYear();
              },
            ),
          )
        ],
      ),
    );
  }

  Future<void> _selectYear() async {
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        int selectedYear = DateTime.now().year;
        return AlertDialog(
          title: const Text('Yıl Seçiniz'),
          content: SizedBox(
            height: 200,
            width: 300,
            child: YearPicker(
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
              initialDate: DateTime.now(),
              selectedDate: DateTime.now(),
              onChanged: (DateTime dateTime) {
                selectedYear = dateTime.year;
                Navigator.pop(context, DateTime(selectedYear));
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      _date.text = picked.year.toString();
    }
  }
}
