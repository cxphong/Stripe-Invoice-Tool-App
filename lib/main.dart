import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:stripe_invoice/apple_signin.dart';
import 'package:stripe_invoice/settings.dart';
import 'package:stripe_invoice/subscription.dart';
import 'package:stripe_invoice/subscription_list.dart';
import 'package:stripe_invoice/subscription_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:stripe_invoice/data.dart';
import 'package:provider/provider.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';
import 'apps.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedData().loadStripeAccessKey();
  await SharedData().loadStripePublishableKey();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: ConnectPage(),
    ),
  );
}

class ConnectPage extends StatelessWidget {
  ConnectPage({Key? key}) : super(key: key);
  SharedData sharedData = SharedData();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
      return MaterialApp(
        title: 'Flutter Demo',
        home: sharedData.stripe_access_key.isEmpty
            ? _ConnectPage()
            : MyHomePage(),
        // theme: ThemeData.light(),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedLabelStyle: TextStyle(
              fontFamily: 'Urbanist', // Set the font family for selected label
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily:
                  'Urbanist', // Set the font family for unselected label
            ),
          ),
        ),
        themeMode: settingsProvider.themeMode,
        theme: ThemeData(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedLabelStyle: TextStyle(
              fontFamily: 'Urbanist', // Set the font family for selected label
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily:
                  'Urbanist', // Set the font family for unselected label
            ),
          ),
        ),
      );
    });
  }
}

class _ConnectPage extends StatefulWidget {
  const _ConnectPage({Key? key}) : super(key: key);

  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<_ConnectPage> {
  StreamSubscription? _sub;
  SharedData sharedData = SharedData();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _launchURL() async {
    // test
    const url =
        "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_QGyQGNJXP9thoJSAjHI6qrJVsdmXGSFy&scope=read_write";
    // const url = 'https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_QXRvRNoljHiCK1Tr3GYqOyZlxrpUutdB&scope=read_write';

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
                // _launchURL();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SubscriptionScreen()),
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
                'Connect with Stripe',
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Color(0xFF29B6F6),
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
