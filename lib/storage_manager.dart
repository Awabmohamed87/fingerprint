import 'package:fingerprint/dbhelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  Future<bool> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var res = await prefs.getBool('isSignedIn') ?? false;
    return res;
  }

  Future<String> getSignTime() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String res = await prefs.getString('signTime') ?? '';
    return res;
  }

  sign() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('signTime', DateTime.now().toString());
    await prefs.setBool('isSignedIn', true);
    await DBHelper.SignIn_db(await prefs.getString('signTime')!);
  }

  leave() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSignedIn', false);
    await prefs.setString('signTime', '');
    await DBHelper.update(DateTime.now().toString());
  }
}
