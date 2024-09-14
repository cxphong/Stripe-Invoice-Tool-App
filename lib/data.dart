import 'package:jwt_decoder/jwt_decoder.dart';
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
  String _stripeUserId = '';

  // Getter for stripe_access_key
  String get stripe_access_key => _stripeAccessKey;
  String get stripe_publishable_key => _stripePublishableKey;
  String get stripe_user_id => _stripeUserId;
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

  ///
  Future<void> saveStripeUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('stripe_user_id', id);
    _stripeUserId = id;
  }

  Future<void> loadStripeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _stripeUserId = prefs.getString('stripe_user_id') ?? _stripeUserId;
  }

  Future<void> clearStripeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('stripe_user_id');
    _stripeUserId = '';
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
