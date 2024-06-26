import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:stripe_invoice/settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import 'package:stripe_invoice/data.dart';
import 'package:provider/provider.dart';

import 'apps.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedData().loadStripeAccessKey();

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
        builder: (context, settingsProvider, child)
        {
          return MaterialApp(
            title: 'Flutter Demo',
            home:  sharedData.stripe_access_key.isEmpty ?  _ConnectPage() : MyHomePage(),
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: settingsProvider.themeMode,
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _launchURL() async {
    const url = 'https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_QGyQGNJXP9thoJSAjHI6qrJVsdmXGSFy&scope=read_write';

    // Start the authentication flow
    final result = await FlutterWebAuth.authenticate(
      url: url,
      callbackUrlScheme: "myapp",
    );

    final uri = Uri.parse(result);
    final accessToken = uri.queryParameters['access_token'];

    // Extract the authorization code from the result URL
    // final access_key = Uri.parse(result).queryParameters['access_key'];
    print (accessToken);
    await sharedData.saveStripeAccessKey(accessToken!);
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
        color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Text(
              'Infinium',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Payments for Stripe',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 30),
            Icon(
              Icons.credit_card,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {_launchURL();},
              // style: ElevatedButton.styleFrom(
              //   primary: Colors.white,
              //   onPrimary: Colors.blue,
              // ),
              child: Text(
                'Connect with Stripe',
                style: TextStyle(color: Colors.blue),
              ),
            ),

            Spacer(),
          ],
        ),
      ),
    );
  }
}
