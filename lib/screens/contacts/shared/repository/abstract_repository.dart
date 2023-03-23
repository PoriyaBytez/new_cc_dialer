import 'package:sqflite/sqflite.dart';
import '../../../../utils/ContactsApplication.dart';

abstract class AbstractRepository {
  Database? _db;
  String get dbname;
  int get dbversion;

  Future<Database?> init() async {
    if (_db == null) {
      var databasesPath = await getDatabasesPath();
      String path = databasesPath + dbname;

      _db = await openDatabase(path, version: dbversion,
          onCreate: (Database db, int version) async {
        dbCreate.forEach((String sql) {
          db.execute(sql);
        });
      });
    }
    return _db;
  }

  Future<Database?> getDb() async {
    return await init();
  }

  Future<List<Map>> list();

  Future<Map> getItem(int id);

  Future<int> insert(Map<String, dynamic> values);

  Future<bool> update(Map<String, dynamic> values, dynamic where);

  Future<bool> delete(int id);

  Future<bool> deleteall(int id);

  void close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
