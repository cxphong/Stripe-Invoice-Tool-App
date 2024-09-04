import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/stripe_connect_page.dart';
import 'package:stripe_invoice/subscription_screen.dart';
import 'apple_store_products.dart';
import 'apps.dart';
import 'data.dart';
import 'dart:convert';

class CreateAccountPage extends StatelessWidget {
  SharedData data = SharedData();

  retrieveTextColor(context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF29B6F6)
        : Colors.white;
  }

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
      // appBar: AppBar(
      //   title: Text('Create an Account'),
      //   backgroundColor: Colors.blueAccent,
      // ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome to Invoice & Payment for Stripe',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: "Urbanist",
                  fontWeight: FontWeight.bold,
                  color: retrieveTextColor(context),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Easily create and manage your Stripe invoices, payments, and more with our powerful tools.',
                style: TextStyle(
                    fontFamily: "Urbanist",
                    fontSize: 18,
                    color: retrieveTextColor(context)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  'To get started, please create an account. You can sign in with your Apple ID for a quick and secure setup.',
                  style: TextStyle(
                      fontFamily: "Urbanist",
                      fontSize: 16,
                      color: retrieveTextColor(context)),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16, 0),
                child: Center(
                  child: SignInWithAppleButton(
                    style: Theme.of(context).brightness == Brightness.light
                        ? SignInWithAppleButtonStyle.black
                        : SignInWithAppleButtonStyle.white,
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

                      if (AppleStoreProductManager().lastTransaction == null &&
                          AppleStoreProductManager().renewalTransaction ==
                              null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SubscriptionScreen()),
                        );
                        return;
                      }

                      if (AppleStoreProductManager().renewalTransaction !=
                              null &&
                          AppleStoreProductManager()
                                  .renewalTransaction!
                                  .expirationIntent !=
                              0) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SubscriptionScreen()),
                        );
                      } else {
                        if (SharedData().stripe_access_key.isEmpty) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const StripeConnectPage()),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyHomePage()),
                          );
                        }
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
