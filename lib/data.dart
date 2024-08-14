import 'package:shared_preferences/shared_preferences.dart';

class SharedData {
  static final SharedData _singleton = SharedData._internal();

  factory SharedData() {
    return _singleton;
  }

  SharedData._internal();

  // Shared variable
  String _stripeAccessKey = '';
  String _stripePublishableKey = '';
  String _appleUserIdentifier = '';

  // Getter for stripe_access_key
  String get stripe_access_key => _stripeAccessKey;
  String get stripe_publishable_key => _stripePublishableKey;
  String get apple_user_identifier => _appleUserIdentifier;

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

  // Method to save stripe_access_key
  Future<void> saveStripePublishableKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stripe_publishable_key', key);
    _stripePublishableKey = key;
  }

  // Method to load stripe_access_key
  Future<void> loadStripePublishableKey() async {
    final prefs = await SharedPreferences.getInstance();
    _stripePublishableKey = prefs.getString('stripe_publishable_key') ?? _stripePublishableKey;
  }

  Future<void> clearStripePublishableKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stripe_publishable_key');
    _stripePublishableKey = '';
  }

  // Method to save stripe_access_key
  Future<void> saveAppleUserIdentifier(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apple_user_identifier', key);
    _appleUserIdentifier = key;
  }

  // Method to load stripe_access_key
  Future<void> loadAppleUserIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    _appleUserIdentifier = prefs.getString('apple_user_identifier') ?? _appleUserIdentifier;
  }

  Future<void> clearAppleUserIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('apple_user_identifier');
    _appleUserIdentifier = '';
  }

}
