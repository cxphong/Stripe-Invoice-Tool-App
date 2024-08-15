import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:stripe_invoice/stripe_connect_page.dart';
import 'package:stripe_invoice/data.dart';
import 'package:stripe_invoice/subscription.dart';
import 'package:stripe_invoice/subscription_list.dart';
import 'package:http/http.dart' as http;

import 'apps.dart';

class AppleSignInScreen extends StatefulWidget {
  const AppleSignInScreen({Key? key}) : super(key: key);

  @override
  State<AppleSignInScreen> createState() => _AppleSignInScreenState();
}

class _AppleSignInScreenState extends State<AppleSignInScreen> {
  SharedData data = SharedData();

  Future<void> createUser({
    required String appleId,
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    const String apiUrl =
        'https://8n5whw25p0.execute-api.us-east-1.amazonaws.com/default/stripe-admin-apple-users'; // Replace with your actual API Gateway URL

    final Map<String, dynamic> data = {
      'apple_id': appleId,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      print('User created successfully!');
    } else if (response.statusCode == 409) {
      print('User already exists.');
    } else {
      print('Failed to create user: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            // Ensures the container takes up the full width
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 100, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF29B6F6),
                    fontFamily: 'Urbanist',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 64, 0, 0),
                  child: SignInWithAppleButton(
                    onPressed: () async {
                      final credential =
                          await SignInWithApple.getAppleIDCredential(
                        scopes: [
                          AppleIDAuthorizationScopes.email,
                          AppleIDAuthorizationScopes.fullName,
                        ],
                      );

                      print(credential);
                      createUser(
                          appleId: credential.userIdentifier!,
                          email: "",
                          firstName: "",
                          lastName: "");

                      if (credential.userIdentifier != null) {
                        data.saveAppleUserIdentifier(
                            credential.userIdentifier!);
                      }

                      if (data.stripe_access_key.isEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StripeConnectPage()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      }

                      // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
                      // after they have been validated with Apple (see `Integration` section for more information on how to do this)
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50.0,
            left: 20.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close the screen
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26, // Circle color
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.white, // X icon color
                    size: 24.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
