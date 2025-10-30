import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stripe_invoice/data.dart';

class DemoManager {
  static final DemoManager _singleton =
  DemoManager._internal();

  factory DemoManager() {
    return _singleton;
  }

  DemoManager._internal();

  bool demo = false;

  Future<void> checkDemoMode() async {
    String version = '';
    String buildNumber = '';
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;

    final url = Uri.parse('https://gbkdhcz3lk.execute-api.us-east-1.amazonaws.com/default/stripeinvoice-app-demo-mode');

    // Create the POST request body
    final body = jsonEncode({'version': "$version+$buildNumber"});

    // Perform the POST request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      final jsonResponse = jsonDecode(response.body);
      print (jsonResponse);

      demo = jsonResponse['demo'] as bool;
      if (demo) {
        SharedData().saveStripePublishableKey(jsonResponse['stripe_publish_key']);
        SharedData().saveStripeAccessKey(jsonResponse['stripe_secret_key']);
        SharedData().saveStripeUserId(jsonResponse['stripe_user_id']);
      }
    } else {
      // Handle error response
      print('Failed to load demo mode status');
      demo = false;
    }
  }
}
