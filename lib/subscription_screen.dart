import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stripe_invoice/subscription.dart';
import 'package:stripe_invoice/subscription_list.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            // Ensures the container takes up the full width
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Start your free 7 days trial',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 24,
                    color: const Color(0xFF29B6F6),
                  ),
                ),
                Padding(padding: EdgeInsets.all(24.0)),
                SubscriptionList(),
                Padding(padding: EdgeInsets.all(24.0)),
                FractionallySizedBox(
                  widthFactor: 0.65, // 65% of the width
                  child: ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'SUBSCRIBE',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Urbanist',),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29B6F6),
                    ),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26, // Circle color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
