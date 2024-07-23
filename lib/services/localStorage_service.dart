import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:project/services/firebase_service.dart';

class LocalStorageService {
  LocalStorageService._privateConstructor();
  static final LocalStorageService _instance =
      LocalStorageService._privateConstructor();

  factory LocalStorageService() {
    return _instance;
  }
  final _myBox = Hive.box('myBox');

  void WriteData(String key, String data) {
    _myBox.put(key, data);
  }

  String ReadData(String key) {
    return _myBox.get(key);
  }

  void DeleteData(String key) {
    _myBox.delete(key);
  }

  Future<User?> refreshPage() async {
    Map<String, dynamic> userMap = jsonDecode(ReadData('LoginInfo'));
    return User.fromJson(userMap);
  }
}
