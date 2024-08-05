import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/public_pages/footer.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/firebase_service.dart';
import 'package:project/services/localStorage_service.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  final _localStorageService = LocalStorageService();
  final _firebaseService = FirebaseService(DbConstants.portfoyTable);
  final _alertService = AlertService();
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
      ),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * .15,
                  child: UserAccountsDrawerHeader(
                      decoration: const BoxDecoration(
                        color: ColorConstants.generalColor,
                      ),
                      accountName: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      accountEmail: Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            _firebaseService.currentUser!.fullName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )),
                ),
                ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.black),
                  title: const Text(
                    'Grafik',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.goNamed('Chart');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.list, color: Colors.black),
                  title: const Text(
                    'Portföy',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.goNamed('Portfoy');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.map, color: Colors.black),
                  title: const Text(
                    'Hedefler',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.goNamed('Target');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.attach_money_outlined,
                      color: Colors.black),
                  title: const Text(
                    'Kasa',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.goNamed('Case');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.black),
                  title: const Text(
                    'Ayarlar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    context.goNamed('UpdateUser');
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
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
              style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.generalColor,
                  minimumSize: Size(MediaQuery.of(context).size.width * .7, 50),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)))),
              child: const Text(
                'Çıkış Yap',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void close() {
    _firebaseService.exit();
    var isCheckedString = _localStorageService.ReadData('isChecked');
    var isChecked = bool.tryParse(isCheckedString) ?? false;
    if (!isChecked) {
      _localStorageService.DeleteData('LoginInfo');
    }
    context.go('/loginPage');
  }
}
