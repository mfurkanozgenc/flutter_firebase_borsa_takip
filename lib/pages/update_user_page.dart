import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/pages/create_page.dart';
import 'package:project/services/firebase_service.dart';

class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _fullName = TextEditingController();
  final _userName = TextEditingController();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();

  Future<void> getUserInfo() async {
    User? user = await FirebaseService.getUserFromPrefs();
    if (user != null) {
      _fullName.text = user.fullName;
      _userName.text = user!.userName;
    }
  }

  @override
  Widget build(BuildContext context) {
    getUserInfo();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portföy'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        leading: IconButton(
            onPressed: () {
              context.goNamed('Portfoy');
            },
            icon: const Icon(Icons.arrow_back)),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(50),
            child: Expanded(
              flex: 3,
              child: Text(
                'Bilgilerinizi Düzenleyin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _fullName,
                      decoration: const InputDecoration(
                          label: Text('Ad - Soyad'),
                          labelStyle: TextStyle(color: Colors.black),
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
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _userName,
                      decoration: const InputDecoration(
                          label: Text('Kullanıcı Adı'),
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.deepOrange))),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(10),
                  //   child: TextField(
                  //     controller: _oldPassword,
                  //     decoration: const InputDecoration(
                  //         label: Text('Eski Şifre'),
                  //         labelStyle: TextStyle(color: Colors.black),
                  //         border: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.grey)),
                  //         enabledBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.grey)),
                  //         focusedBorder: OutlineInputBorder(
                  //             borderSide:
                  //                 BorderSide(color: Colors.deepOrange))),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(10),
                  //   child: TextField(
                  //     controller: _newPassword,
                  //     decoration: const InputDecoration(
                  //         label: Text('Eski Şifre'),
                  //         labelStyle: TextStyle(color: Colors.black),
                  //         border: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.grey)),
                  //         enabledBorder: OutlineInputBorder(
                  //             borderSide: BorderSide(color: Colors.grey)),
                  //         focusedBorder: OutlineInputBorder(
                  //             borderSide:
                  //                 BorderSide(color: Colors.deepOrange))),
                  //   ),
                  // ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_fullName.text.isEmpty || _userName.text.isEmpty) {
                        showToast('Lütfen Tüm Alanları Doldurunuz', context);
                        return;
                      }
                      if (_fullName.text.length < 3) {
                        showToast(
                            'Ad-Soyad En Az 3 Karakter Olmalıdır', context);
                        return;
                      }
                      if (_userName.text.length < 3) {
                        showToast('Kullanıcı Adı En Az 3 Karakter Olmalıdır',
                            context);
                        return;
                      }
                      var result = await FirebaseService.updateUser(
                          _userName.text, _fullName.text);
                      if (result.isNotEmpty) {
                        if (result == 'success') {
                          if (_userName.text !=
                              FirebaseService.currentUser!.userName) {
                            showToast(
                                'Bilgileriniz Güncellendi.Lütfen Tekrar Giriş Yapınız',
                                context);
                            FirebaseService.exit();
                            context.goNamed('Login');
                          } else {
                            showToast('Bilgileriniz Güncellendi.', context);
                            if (FirebaseService.currentUser != null) {
                              User user = User(
                                  fullName: _fullName.text,
                                  userName: _userName.text,
                                  password:
                                      FirebaseService.currentUser!.password,
                                  id: FirebaseService.currentUser!.id);
                              FirebaseService.saveUserToPrefs(user);
                              FirebaseService.loginUser =
                                  await FirebaseService.getUserFromPrefs();
                            }
                          }
                        } else {
                          showToast(result, context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        minimumSize: Size(
                            MediaQuery.of(context).size.width * .8,
                            MediaQuery.of(context).size.height * 0.05)),
                    child: const Text('Güncelle'),
                  )
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
