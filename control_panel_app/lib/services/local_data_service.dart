import 'package:shared_preferences/shared_preferences.dart';

/// LocalDataService placeholder after removing deleted features
class LocalDataService {
  // final SharedPreferences _prefs; // Unused field

  LocalDataService(SharedPreferences prefs);

	bool hasCachedData() => false;
	bool isDataValid() => false;
	Map<String, dynamic> getDataStats() => {};
	Future<bool> clearAllData() async => true;
}