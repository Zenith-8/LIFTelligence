import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static const _kHost = 'server_host';
  static const _kPort = 'server_port';
  static const _kMachine = 'machine_name';
  static const _kUid = 'last_uid';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<String> getServerHost({String fallback = '127.0.0.1'}) async {
    final prefs = await _prefs;
    return prefs.getString(_kHost) ?? fallback;
  }

  Future<int> getServerPort({int fallback = 5001}) async {
    final prefs = await _prefs;
    return prefs.getInt(_kPort) ?? fallback;
  }

  Future<String> getMachineName({String fallback = 'Bench-01'}) async {
    final prefs = await _prefs;
    return prefs.getString(_kMachine) ?? fallback;
  }

  Future<String> getLastUid({String fallback = ''}) async {
    final prefs = await _prefs;
    return prefs.getString(_kUid) ?? fallback;
  }

  Future<void> setServerHost(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_kHost, value);
  }

  Future<void> setServerPort(int value) async {
    final prefs = await _prefs;
    await prefs.setInt(_kPort, value);
  }

  Future<void> setMachineName(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_kMachine, value);
  }

  Future<void> setLastUid(String value) async {
    final prefs = await _prefs;
    await prefs.setString(_kUid, value);
  }
}

