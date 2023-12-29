import 'package:fingerprint/models/SignProfile.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static const int _version = 1;
  static const String tasksTableName = 'TASKS';
  static const String medicinesTableName = 'MEDS';
  static Database? _db;

  static Future<void> initDB() async {
    if (_db == null) {
      try {
        String _path = getDatabasesPath().toString() + 'sign_history_db.db';
        // open the database
        _db = await openDatabase(_path, version: _version,
            onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute('''
              CREATE TABLE SignHistory (id INTEGER PRIMARY KEY AUTOINCREMENT,
              signin_t DateTime, signout_t DateTime)
             ''');
        });
      } catch (e) {
        rethrow;
      }
    }
  }

  static Future<List<SignProfile>> GetAll({DateTime? from}) async {
    // Insert some records in a transaction
    List<Map<String, Object?>> result;
    if (from == null) {
      result = await _db!.query('SignHistory');
    } else {
      final sql =
          '''Select * from SignHistory where signin_t between '${from.toString().split(' ')[0]} 00:00:00' and '${from.toString().split(' ')[0]} 23:59:59' ''';

      result = await _db!.rawQuery(sql);
    }
    try {
      List<SignProfile> res = result
          .map((e) => SignProfile(int.parse(e['id'].toString()),
              e['signin_t'].toString(), e['signout_t'].toString()))
          .toList();
      res.insert(0, SignProfile(0, 'SignIn', 'SignOut'));
      return res;
    } catch (e) {
      rethrow;
    }
  }

  static Future<int> SignIn_db(String SignIn_time) async {
    // Insert some records in a transaction
    return await _db!.insert('SignHistory', {'signin_t': SignIn_time});
  }

  static Future<int> update(String signout_time) async {
    List<Map<String, Object?>> result =
        await _db!.query('SignHistory', orderBy: 'id desc', limit: 1);
    var id = int.parse(result[0]['id'].toString());
    return await _db!.rawUpdate('''
    UPDATE SignHistory
    SET signout_t = ?
    WHERE id = ?
    ''', [signout_time, id]);
  }

  static Future<int> empty() async {
    return await _db!.rawDelete('DELETE FROM SignHistory');
  }
}
