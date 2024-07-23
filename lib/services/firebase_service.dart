import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/constants/db_constants.dart';
import 'package:project/services/localStorage_service.dart';

class FirebaseService {
  late CollectionReference response;
  late CollectionReference userResponse;
  User? loginUser;
  static late LocalStorageService localStorageService;

  FirebaseService._privateConstructor();

  static final FirebaseService _instance =
      FirebaseService._privateConstructor();

  factory FirebaseService(String collectionName) {
    _instance.response = FirebaseFirestore.instance.collection(collectionName);
    _instance.userResponse =
        FirebaseFirestore.instance.collection(DbConstants.UserTable);
    localStorageService = LocalStorageService();
    return _instance;
  }

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
    try {
      var querySnapshot = await userResponse
          .where('userName', isEqualTo: userName)
          .where('password', isEqualTo: password)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        loginUser = User.fromFirestore(userDoc);
        String userJson = jsonEncode(loginUser!.toJson());
        localStorageService.WriteData('LoginInfo', userJson!);
        return 'success';
      } else {
        return 'Kullanıcı Bulunamadı';
      }
    } catch (error) {
      return 'Login failed: $error';
    }
  }

  Future<String> updateUser(String userName, String fullName) async {
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

  Future<String> updateUserPassword(String newPassword) async {
    try {
      var querySnapshot = await userResponse
          .where('userName', isEqualTo: currentUser!.userName)
          .get();

      if (querySnapshot.docs.isNotEmpty &&
          querySnapshot.docs.first.id != currentUser!.id) {
        return 'Bu Kullanıcı Adına Ait Kayıt Bulunmaktadır';
      } else {
        userResponse.doc(currentUser!.id).update({
          'userName': currentUser!.userName,
          'password': newPassword,
          'fullName': currentUser!.fullName,
        });
        return 'success';
      }
    } catch (error) {
      return 'Update User Password failed: $error';
    }
  }

  User? get currentUser => loginUser;

  Future<void> exit() async {
    // await _prefs?.remove('user');
    loginUser = null;
  }

  // Future<void> saveUserToPrefs(User user) async {
  //   print('Çalıştı2');
  //   try {
  //     String userJson = jsonEncode(user.toJson());
  //     await _prefs?.setString('user', userJson);
  //   } catch (e) {
  //     print('HATA2 $e');
  //   }
  // }

  // Future<User?> getUserFromPrefs() async {
  //   print('Çalıştı');
  //   try {
  //     String? userJson = _prefs?.getString('user');
  //     if (userJson != null) {
  //       Map<String, dynamic> userMap = jsonDecode(userJson);
  //       return User.fromJson(userMap);
  //     }
  //     return null;
  //   } catch (e) {
  //     print('HATA1 $e');
  //     return null;
  //   }
  // }
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
