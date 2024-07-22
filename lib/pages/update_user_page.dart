import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/constants/colors_constants.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/public_pages/footer.dart';
import 'package:project/services/alert_service.dart';
import 'package:project/services/firebase_service.dart';

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
  void getUserInfo() {
    if (_firebaseService.loginUser != null) {
      _fullName.text = _firebaseService.loginUser!.fullName;
      _userName.text = _firebaseService.loginUser!.userName;
      _password.text = _firebaseService.loginUser!.password;
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
            context.goNamed('Login');
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: ColorConstants.generalColor,
          ),
          onPressed: () {
            context.goNamed('Portfoy');
          },
        ),
        title: const Text(
          'Hesabım',
          style: TextStyle(color: ColorConstants.generalColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            height: height * .4,
            width: width,
            color: ColorConstants.generalColor,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bilgilerinizi Güncelleyin',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
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
                                  borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              errorBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFee403c))),
                              focusedErrorBorder: OutlineInputBorder(
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
                                  borderSide: BorderSide(color: Colors.black)),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ColorConstants.generalColor)),
                              focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: ColorConstants.generalColor))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: ElevatedButton(
                          onPressed: _update,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: ColorConstants.generalColor,
                              minimumSize: Size(width * .8, 50)),
                          child: const Text('Güncelle'),
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
}
