import 'package:shared_preferences/shared_preferences.dart';

class SharedData {
  static final SharedData _singleton = SharedData._internal();

  factory SharedData() {
    return _singleton;
  }

  SharedData._internal();

  // Shared variable
  String _stripeAccessKey = '';

  // Getter for stripe_access_key
  String get stripe_access_key => _stripeAccessKey;

  // Method to save stripe_access_key
  Future<void> saveStripeAccessKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stripe_access_key', key);
    _stripeAccessKey = key;
  }

  // Method to load stripe_access_key
  Future<void> loadStripeAccessKey() async {
    final prefs = await SharedPreferences.getInstance();
    _stripeAccessKey = prefs.getString('stripe_access_key') ?? _stripeAccessKey;
  }

  Future<void> clearStripeAccessKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stripe_access_key');
    _stripeAccessKey = '';
  }

}
