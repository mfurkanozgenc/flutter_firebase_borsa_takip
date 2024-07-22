class DatabaseService {
  DatabaseService._privateConstructor();

  static final DatabaseService _instance =
      DatabaseService._privateConstructor();

  factory DatabaseService() {
    return _instance;
  }

  String Name = 'Furkan';
  bool ButtonPasswordVisibility = true;
}
