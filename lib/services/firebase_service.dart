import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/constants/db_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  late CollectionReference response;
  late CollectionReference userResponse;
  static User? loginUser;

  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService(String collectionName) {
    _instance.response = FirebaseFirestore.instance.collection(collectionName);
    _instance.userResponse =
        FirebaseFirestore.instance.collection(DbConstants.UserTable);
    return _instance;
  }

  FirebaseService._internal();

  Future<bool> add(String name, num unitPrice, num quantity, String userId,
      num targetPrice) async {
    try {
      await response.add({
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'targetPrice': targetPrice,
        'userId': userId
      });
      print('Kayıt Ekleme Başarılı');
      return true;
    } catch (error) {
      print('Kayıt Eklenemedi : $error');
      return false;
    }
  }

  Future<bool> update(String id, String name, num unitPrice, num quantity,
      String userId, num targetPrice) async {
    try {
      await response.doc(id).update({
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'targetPrice': targetPrice,
        'userId': userId
      });
      print('Güncelleme İşlemi Başarılı');
      return true;
    } catch (error) {
      print('Güncellemi İşlemi Başarısız : $error');
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await response.doc(id).delete();
      print('Silme İşlemi Başarılı');
      return true;
    } catch (error) {
      print('Silme İşlemi Başarısız : $error');
      return false;
    }
  }

  Future<String?> createUser(
      String userName, String password, String fullName) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference userResponse = firestore.collection('users');

    try {
      var querySnapshot =
          await userResponse.where('userName', isEqualTo: userName).get();

      if (querySnapshot.docs.isNotEmpty) {
        return 'Kullanıcı Adı Daha Önce Alınmıştır';
      }
      await userResponse.add({
        'userName': userName,
        'password': password,
        'fullName': fullName,
      });
      return 'success';
    } catch (error) {
      return 'User creation failed: $error';
    }
  }

  Future<String> login(String userName, String password) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference userResponse = firestore.collection('users');

    try {
      var querySnapshot = await userResponse
          .where('userName', isEqualTo: userName)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        loginUser = User.fromFirestore(userDoc);
        saveUserToPrefs(loginUser!);
        return 'success';
      } else {
        return 'Kullanıcı Bulunamadı';
      }
    } catch (error) {
      return 'Login failed: $error';
    }
  }

  static Future<String> updateUser(String userName, String fullName) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference userResponse = firestore.collection('users');

    try {
      var querySnapshot =
          await userResponse.where('userName', isEqualTo: userName).get();

      if (querySnapshot.docs.isNotEmpty &&
          querySnapshot.docs.first.id != currentUser!.id) {
        return 'Bu Kullanıcı Adına Ait Kayıt Bulunmaktadır';
      } else {
        userResponse.doc(currentUser!.id).update({
          'userName': userName,
          'password': currentUser!.password,
          'fullName': fullName,
        });
        return 'success';
      }
    } catch (error) {
      return 'Update User failed: $error';
    }
  }

  static User? get currentUser => loginUser;

  static Future<void> exit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    loginUser = null;
  }

  static Future<void> saveUserToPrefs(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toJson());
    await prefs.setString('user', userJson);
  }

  static Future<User?> getUserFromPrefs() async {
    print('Çalıştı');
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user');
      if (userJson != null) {
        Map<String, dynamic> userMap = jsonDecode(userJson);
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('HATA1 $e');
    }
  }
}

class User {
  final String userName;
  final String fullName;
  final String password;
  final String id;

  User({
    required this.userName,
    required this.fullName,
    required this.password,
    required this.id,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      userName: data['userName'] ?? '',
      fullName: data['fullName'] ?? '',
      password: data['password'] ?? '',
      id: doc.id,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: json['userName'],
      fullName: json['fullName'],
      password: json['password'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'fullName': fullName,
      'password': password,
      'id': id,
    };
  }
}
