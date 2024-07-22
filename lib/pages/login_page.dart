import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/services/firebase_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userName = TextEditingController();
  final _password = TextEditingController();
  final _firebaseService = FirebaseService(DbConstants.portfoyTable);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 9,
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    flex: 3, // %30
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: const Text(
                        'BORSA TAKİP UYGULAMASINA HOŞGELDİNİZ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7, // %70
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 20, top: 80, left: 20, right: 20),
                          child: TextField(
                            controller: _userName,
                            decoration: const InputDecoration(
                                label: Text(
                                  'Kullanıcı Adı',
                                  style: TextStyle(color: Colors.black),
                                ),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.deepOrange))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 20, top: 5, left: 20, right: 20),
                          child: TextField(
                            controller: _password,
                            decoration: const InputDecoration(
                                label: Text(
                                  'Şifre',
                                  style: TextStyle(color: Colors.black),
                                ),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.deepOrange))),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (_userName.text.isEmpty ||
                                _password.text.isEmpty) {
                              showToast('Gerekli Bilgileri Giriniz', context);
                              return;
                            }
                            var result = await _firebaseService.login(
                                _userName.text, _password.text);
                            if (result.isNotEmpty) {
                              if (result == 'success') {
                                context.goNamed('Portfoy');
                              } else {
                                showToast(result, context);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              minimumSize: Size(
                                  MediaQuery.sizeOf(context).width * .8,
                                  MediaQuery.sizeOf(context).height * .05)),
                          child: const Text('Giriş Yap'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextButton(
                              onPressed: () {
                                context.goNamed('Create');
                              },
                              child: const Text(
                                'Kayıt Ol',
                                style: TextStyle(color: Colors.black),
                              )),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: const Text(
              'ÖZGENÇ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}

void showToast(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message, textAlign: TextAlign.center),
  ));
}
