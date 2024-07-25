import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/public_pages/customAppBar.dart';
import 'package:project/public_pages/footer.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/firebase_service.dart';
import 'package:project/services/localStorage_service.dart';

class UpdateUserPage extends StatefulWidget {
  const UpdateUserPage({super.key});

  @override
  State<UpdateUserPage> createState() => _UpdateUserPageState();
}

class _UpdateUserPageState extends State<UpdateUserPage> {
  final _fullName = TextEditingController();
  final _userName = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService(DbConstants.portfoyTable);
  final _localStorageService = LocalStorageService();
  Future<void> getUserInfo() async {
    var result = await _localStorageService.refreshPage();
    if (result != null) {
      _fullName.text = result!.fullName;
      _userName.text = result!.userName;
      _password.text = result!.password;
      _firebaseService.loginUser = result;
    }
  }

  Future<void> _update() async {
    if (_formKey.currentState!.validate()) {
      var result =
          await _firebaseService.updateUser(_userName.text, _fullName.text);
      if (result.isNotEmpty) {
        if (result == 'success') {
          if (_userName.text != _firebaseService.loginUser!.userName) {
            AlertService.showToast(
                'Bilgileriniz Güncellendi.Lütfen Tekrar Giriş Yapınız',
                context);
            _firebaseService.exit();
            context.go('/loginPage');
          } else {
            AlertService.showToast('Bilgileriniz Güncellendi.', context);
            if (_firebaseService.loginUser != null) {
              User user = User(
                  fullName: _fullName.text,
                  userName: _userName.text,
                  password: _firebaseService.loginUser!.password,
                  id: _firebaseService.loginUser!.id);
            }
          }
        } else {
          AlertService.showToast(result, context);
        }
      }
    }
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Hesabım',
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            context.go('/portfoyPage');
          },
        ),
        titleColor: Colors.white,
        backgroundColor: ColorConstants.generalColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 0.5),
            child: Container(
              height: height * .4,
              width: width,
              color: Colors.transparent,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bilgilerinizi Güncelleyin',
                    style: TextStyle(
                        color: ColorConstants.generalColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _fullName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen Ad-Soyad Giriniz';
                            }
                          },
                          decoration: const InputDecoration(
                              label: Text('Ad-Soyad *'),
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.grey)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFee403c))),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide:
                                      BorderSide(color: Color(0xFFee403c)))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextFormField(
                          controller: _userName,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen Kullanıcı Adını Giriniz';
                            }
                          },
                          decoration: const InputDecoration(
                              label: Text('Kullanıcı Adı *'),
                              labelStyle: TextStyle(color: Colors.black),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.grey)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: ColorConstants.generalColor)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: ColorConstants.generalColor))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: _update,
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              backgroundColor: ColorConstants.generalColor,
                              minimumSize: Size(width * .8, 50)),
                          child: const Text('Güncelle'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: TextButton(
                          onPressed: () {
                            _showPasswordChangeDialog(
                              context,
                            );
                          },
                          child: const Text(
                            'Şifre Değiştir',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: footer(heigth: height, width: width),
    );
  }

  void _showPasswordChangeDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _oldPasword = TextEditingController();
    final _newPassword = TextEditingController();
    final _newPasswordAgain = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Şifre Değiştir'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _oldPasword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen Mevcut Şifreyi Giriniz';
                        }
                        if (value != _firebaseService.loginUser!.password) {
                          return 'Mevcut Şifre Hatalı';
                        }
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Mevcut Şifre',
                          labelStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorConstants.generalColor))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _newPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen Yeni Şifreyi Giriniz';
                        }
                        if (value.length < 6) {
                          return 'Şifre En Az 6 Karakter Olmalıdır';
                        }
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Yeni Şifre',
                          labelStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorConstants.generalColor))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _newPasswordAgain,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lütfen Yeni Şifre Tekrar Giriniz';
                        }
                        if (value != _newPassword.text) {
                          return 'Şifre Tekrarı Eşleşmedi';
                        }
                      },
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: ' Şifre Tekrar',
                          labelStyle: TextStyle(color: Colors.black),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: ColorConstants.generalColor))),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('İptal', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  var result = await _firebaseService
                      .updateUserPassword(_newPassword.text);
                  if (result.isNotEmpty) {
                    if (result == 'success') {
                      AlertService.showToast(
                          'Şifreniz Başarılı Şekilde Değiştirildi.Lütfen Tekrar Giriş Yapınız',
                          context);
                      Navigator.of(context).pop();
                      context.go('Login');
                      _firebaseService.exit();
                      var isCheckedString =
                          _localStorageService.ReadData('isChecked');
                      var isChecked = bool.tryParse(isCheckedString) ?? false;
                      if (!isChecked) {
                        _localStorageService.DeleteData('LoginInfo');
                      }
                    } else {
                      AlertService.showToast(result, context);
                    }
                  }
                }
              },
              child: const Text(
                'Değiştir',
                style: TextStyle(color: ColorConstants.generalColor),
              ),
            ),
          ],
        );
      },
    );
  }
}
