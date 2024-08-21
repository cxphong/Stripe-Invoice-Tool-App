import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:stripe_invoice/apple_store_products.dart';
import 'package:stripe_invoice/renewal_transaction_screen.dart';
import 'package:stripe_invoice/apple_signin.dart';
import 'package:stripe_invoice/stripe_connect_page.dart';
import 'package:stripe_invoice/subscription_screen.dart';
import 'data.dart';
import 'settings.dart'; // Import SettingsProvider class
import 'main.dart'; // Import MyApp class for navigation

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  Future<void> _initPackageInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();

    setState(() {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF29B6F6),
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back indicator
        ),
        title: Text('Settings',
            style: TextStyle(color: Colors.white, fontFamily: 'Urbanist')),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Theme', style: TextStyle(fontFamily: 'Urbanist')),
            subtitle: Text('Select App Theme',
                style: TextStyle(fontFamily: 'Urbanist')),
            trailing: DropdownButton<ThemeMode>(
              value: Provider.of<SettingsProvider>(context).themeMode,
              onChanged: (ThemeMode? newTheme) {
                if (newTheme != null) {
                  Provider.of<SettingsProvider>(context, listen: false)
                      .setThemeMode(newTheme);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(
                    'System Default',
                    style: TextStyle(fontFamily: 'Urbanist'),
                  ),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child:
                      Text('Light', style: TextStyle(fontFamily: 'Urbanist')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark', style: TextStyle(fontFamily: 'Urbanist')),
                ),
              ],
            ),
          ),
          if (AppleStoreProductManager().lastTransaction != null &&
              AppleStoreProductManager().lastTransaction?.productId !=
                  "unlimited_time")
            ListTile(
              title:
                  Text('Subscription', style: TextStyle(fontFamily: 'Urbanist')
                      // style: TextStyle(color: Colors.s),
                      ),
              subtitle: Text(
                  AppleStoreProductManager().renewalTransaction?.productId ??
                      ""),
              onTap: () async {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => RenewalTransactionScreen(
                        transaction:
                            AppleStoreProductManager().renewalTransaction)));
              },
            ),
          ListTile(
            title: Text(
              'Disconnect Stripe',
              style: TextStyle(fontFamily: 'Urbanist'),
            ),
            onTap: () async {
              await SharedData().clearStripeAccessKey();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => StripeConnectPage()),
                (Route<dynamic> route) => false,
              );
            },
          ),
          ListTile(
            title: Text(
              'iOS App version ${_version}+${_buildNumber}',
              style: TextStyle(fontFamily: 'Urbanist'),
            ),
            onTap: () async {},
          ),
          //
          // ListTile(
          //   title: Text(
          //     'Sign in with Apple',
          //     style: TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
          //   ),
          //   onTap: () async {
          //     await SharedData().clearStripeAccessKey();
          //     Navigator.of(context).pushAndRemoveUntil(
          //       MaterialPageRoute(builder: (context) => AppleSignInScreen()),
          //           (Route<dynamic> route) => false,
          //     );
          //   },
          // ),
          // Add more settings options here
        ],
      ),
    );
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}
