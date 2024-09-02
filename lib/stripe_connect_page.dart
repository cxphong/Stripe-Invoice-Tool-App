import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:stripe_invoice/demo_manager.dart';
import 'package:stripe_invoice/subscription_screen.dart';

import 'apps.dart';
import 'data.dart';

class StripeConnectPage extends StatefulWidget {
  const StripeConnectPage({Key? key}) : super(key: key);

  _StripeConnectPageState createState() => _StripeConnectPageState();
}

class _StripeConnectPageState extends State<StripeConnectPage> {
  StreamSubscription? _sub;
  SharedData sharedData = SharedData();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  void _launchURL() async {
    // test
    // const url =
    //     "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_QGyQGNJXP9thoJSAjHI6qrJVsdmXGSFy&scope=read_write";
    const url =
        'https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_QXRvRNoljHiCK1Tr3GYqOyZlxrpUutdB&scope=read_write';
    https: //connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_QXRvRNoljHiCK1Tr3GYqOyZlxrpUutdB&scope=read_write

    // Start the authentication flow
    final result = await FlutterWebAuth.authenticate(
      url: url,
      callbackUrlScheme: "myapp",
    );

    final uri = Uri.parse(result);
    print(uri);
    final accessToken = uri.queryParameters['access_token'];
    final stripePublishableKey = uri.queryParameters['stripe_publishable_key'];

    await sharedData.saveStripeAccessKey(accessToken!);
    await sharedData.saveStripePublishableKey(stripePublishableKey!);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity, // Ensures the container takes up the full width
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'PaymentGlide',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF29B6F6),
                fontFamily: 'Urbanist',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Payments for Stripe',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF29B6F6),
                fontFamily: 'Urbanist',
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: Image.asset(
                'assets/payment-icon.png',
                width: 100.0,
                height: 100.0,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                _launchURL();
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (context) => SubscriptionScreen()),
                // );
              },
              // style: ElevatedButton.styleFrom(
              //   primary: Colors.white,
              //   onPrimary: Color(0xFF29B6F6),
              // ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF29B6F6), // Background color
              ),
              child: Text(
                'Connect with Stripe',
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Color(0xFF29B6F6),
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
            if (DemoManager().demo)
              Padding(padding: const EdgeInsets.all(18.0),
                child:
              Container(
                color: Colors.grey,
                child: Column(
                  children: [
                    Text("Available only for the build version under review."),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyHomePage()),
                        );
                      },
                      // style: ElevatedButton.styleFrom(
                      //   primary: Colors.white,
                      //   onPrimary: Color(0xFF29B6F6),
                      // ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF29B6F6), // Background color
                      ),
                      child: Text(
                        'Demonstration mode',
                        style: TextStyle(
                          color: Colors.white,
                          backgroundColor: Color(0xFF29B6F6),
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ],
                ),
              ), ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
