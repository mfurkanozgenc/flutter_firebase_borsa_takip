import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/services/firebase_service.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _fullName = TextEditingController();
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
                        'BORSA TAKİP UYGULAMASINA KAYIT OLUN',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7, // %70
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 20, top: 80, left: 20, right: 20),
                          child: TextField(
                            controller: _fullName,
                            decoration: const InputDecoration(
                                label: Text(
                                  'Ad-Soyad *',
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
                            controller: _userName,
                            decoration: const InputDecoration(
                                label: Text(
                                  'Kullanıcı Adı *',
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
                                  'Şifre *',
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
                            if (_fullName.text.isEmpty ||
                                _userName.text.isEmpty ||
                                _password.text.isEmpty) {
                              showToast(
                                  'Lütfen Tüm Alanları Doldurunuz', context);
                              return;
                            }
                            if (_password.text.length < 6) {
                              showToast(
                                  'Şifre En Az 6 Karakter Olmalıdır', context);
                              return;
                            }
                            if (_fullName.text.length < 3) {
                              showToast('Ad Soyad En Az 3 Karakter Olmalıdır',
                                  context);
                              return;
                            }
                            if (_userName.text.length < 3) {
                              showToast(
                                  'Kullanıcı Adı En Az 3 Karakter Olmalıdır',
                                  context);
                              return;
                            }
                            var result = await _firebaseService.createUser(
                                _userName.text, _password.text, _fullName.text);
                            if (result!.isNotEmpty) {
                              if (result == 'success') {
                                context.goNamed('Login');
                                showToast(
                                    'Kullancı Oluşturma Başarılı.Lütfen Giriş Yapınız',
                                    context);
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
                          child: const Text('Kayıt Ol'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: TextButton(
                              onPressed: () {
                                context.goNamed('Login');
                              },
                              child: const Text(
                                'Giriş Ekranına Geri Dön',
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
