import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'stripe_connect_page.dart';
import 'apps.dart';
import 'data.dart';

class FreeTrialPage extends StatelessWidget {
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
      // appBar: AppBar(
      //   title: Text('7 Days Free Trial'),
      //   backgroundColor: Colors.blueAccent,
      // ),
      body: Container(
        width: double.infinity, // Ensures the container takes up the full width
        color: Colors.white, // Set the background color to white
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text(
                    'Try Our Premium Features Free for 7 Days!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // Subheading
                  Text(
                    'No credit card required. Cancel anytime.',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Urbanist',
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: 24.0),

                  // Benefits
                  _buildBenefit(
                    icon: Icons.lock,
                    title: 'Access All Premium Features',
                    description:
                    'Unlock all advanced tools and features to boost your productivity.',
                  ),
                  SizedBox(height: 16.0),
                  _buildBenefit(
                    icon: Icons.cloud,
                    title: 'Cloud Sync',
                    description:
                    'Sync your data across all your devices with our secure cloud service.',
                  ),
                  SizedBox(height: 16.0),
                  _buildBenefit(
                    icon: Icons.support_agent,
                    title: 'Priority Support',
                    description:
                    'Get 24/7 priority support from our team of experts.',
                  ),
                  SizedBox(height: 32.0),

                  // Call to Action Button
                  Center(
                    child: SignInWithAppleButton(
                      style: SignInWithAppleButtonStyle.black,
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
                            MaterialPageRoute(
                                builder: (context) => MyHomePage()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(
      {required IconData icon,
        required String title,
        required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 32.0,
          color: Colors.blueAccent,
        ),
        SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4.0),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Urbanist',
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
