import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> createTestSharedPreferences() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}
