import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/pages/create_page.dart';
import 'package:project/public_pages/footer.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/database_service.dart';
import 'package:project/services/firebase_service.dart';
import 'package:project/services/localStorage_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userName = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();
  final _localStorageService = LocalStorageService();
  final _firebaseService = FirebaseService(DbConstants.UserTable);
  var isPasswordVisibility = true;
  bool isChecked = false;
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      var result = await _firebaseService.login(_userName.text, _password.text);
      if (result.isNotEmpty) {
        if (result == 'success') {
          if (isChecked) {
            _localStorageService.WriteData('isChecked', 'true');
          } else {
            _localStorageService.DeleteData('isChecked');
          }
          context.goNamed('Portfoy');
        } else {
          AlertService.showToast(result, context);
        }
      }
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  void getUserData() async {
    var isCheckedString = _localStorageService.ReadData('isChecked');
    if (isCheckedString.isNotEmpty) {
      isChecked = bool.tryParse(isCheckedString) ?? false;
      if (isChecked) {
        var result = await _localStorageService.refreshPage();
        if (result != null) {
          _userName.text = result.userName;
          _password.text = result.password;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var heigth = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: heigth * .4,
            width: width,
            color: ColorConstants.generalColor,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Borsa Takip Uygulamasına Hoşgeldiniz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                ),
              ],
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
                                borderSide: BorderSide(color: Colors.black),
                              ),
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
                        child: TextFormField(
                          obscureText: _db.ButtonPasswordVisibility,
                          controller: _password,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Lütfen Şifre Giriniz';
                            }
                          },
                          decoration: InputDecoration(
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _db.ButtonPasswordVisibility =
                                          !_db.ButtonPasswordVisibility;
                                    });
                                  },
                                  icon: Icon(_db.ButtonPasswordVisibility
                                      ? Icons.visibility
                                      : Icons.visibility_off),
                                  color: Colors.black,
                                ),
                              ),
                              label: const Text('Şifre *'),
                              labelStyle: const TextStyle(color: Colors.black),
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(color: Colors.grey)),
                              errorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: ColorConstants.generalColor)),
                              focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: ColorConstants.generalColor))),
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                                value: isChecked,
                                activeColor: ColorConstants.generalColor,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isChecked = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.transparent,
                              backgroundColor: isChecked
                                  ? Colors.transparent
                                  : Colors.transparent,
                            ).copyWith(
                              overlayColor:
                                  WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                                  if (states.contains(WidgetState.hovered)) {
                                    return Colors.transparent.withOpacity(0.1);
                                  }
                                  return null;
                                },
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                isChecked = !isChecked;
                              });
                            },
                            child: const Text(
                              'Beni Hatırla',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              backgroundColor: ColorConstants.generalColor,
                              minimumSize: Size(width * .8, 50)),
                          child: const Text('Giriş Yap'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3),
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
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: footer(heigth: heigth, width: width),
    );
  }
}
