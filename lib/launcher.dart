import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:stripe_invoice/freetrial.dart';
import 'package:stripe_invoice/stripe_connect_page.dart';
import 'package:stripe_invoice/subscription_screen.dart';

import 'apps.dart';
import 'data.dart';

import 'package:stripe_invoice/apple_store_products.dart';

class LauncherScreen extends StatefulWidget {
  const LauncherScreen({Key? key}) : super(key: key);

  _LauncherScreenState createState() => _LauncherScreenState();
}

class _LauncherScreenState extends State<LauncherScreen> {
  bool _isLoading = true;

  // sharedData.apple_user_identifier.isEmpty
  // ? FreeTrialPage()
  //     : (AppleStoreProductManager().renewalTransaction?.expirationIntent != null) ? SubscriptionScreen(): MyHomePage(),
  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await SharedData().loadStripeAccessKey();
    await SharedData().loadStripePublishableKey();
    await SharedData().loadAppleUserIdentifier();
    await AppleStoreProductManager().loadInappPurchase();
    await AppleStoreProductManager().loadSubscriptionStatus();

    if (SharedData().apple_user_identifier.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FreeTrialPage()),
      );
    } else {
      if (AppleStoreProductManager().lastTransaction == null &&
          AppleStoreProductManager().renewalTransaction == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SubscriptionScreen()),
        );
        return;
      }

      // Purchased unlimited
      if (AppleStoreProductManager().lastTransaction != null &&
          AppleStoreProductManager().lastTransaction?.productId ==
              "unlimited_time") {
        if (SharedData().stripe_access_key.isEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StripeConnectPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }
      } else {
        if (AppleStoreProductManager().renewalTransaction != null &&
            AppleStoreProductManager().renewalTransaction!.expirationIntent !=
                0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SubscriptionScreen()),
          );
        } else {
          if (SharedData().stripe_access_key.isEmpty) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StripeConnectPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          }
        }
      }
    }
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
            Spacer(),
          ],
        ),
      ),
    );
  }
}
