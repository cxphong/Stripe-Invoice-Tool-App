import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:stripe_invoice/create_account_screen.dart';
import 'package:stripe_invoice/demo_manager.dart';
import 'package:stripe_invoice/renewal_transaction_screen.dart';
import 'package:stripe_invoice/stripe_connect_page.dart';
import 'package:stripe_invoice/views/CustomText.dart';
import 'package:url_launcher/url_launcher.dart';
import 'apple_store_products.dart';
import 'data.dart'; // Import your Data management classes
import 'settings.dart'; // Import SettingsProvider class
import 'package:http/http.dart' as http;

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

  Widget buildGroup(List<Widget> tiles) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        // side: BorderSide(color: Colors.black),
      ),
      child: Column(
        children: ListTile.divideTiles(
          context: context,
          tiles: tiles,
        ).toList(),
      ),
    );
  }

  void _launchURL(String _url) async {
    final Uri url = Uri.parse(_url);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String actionTitle,
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          // backgroundColor: Colors.white,
          title: CustomText(text: title),
          content: CustomText(text: description),
          actions: <Widget>[
            TextButton(
              child: const CustomText(
                  text: 'Cancel',
                  color: Color(0xFF29B6F6),
                  fontWeight: FontWeight.bold),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: CustomText(
                  text: actionTitle,
                  color: Colors.red,
                  fontWeight: FontWeight.bold),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onDelete(); // Call the delete callback
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount() async {
    _showConfirmDialog(context,
        title: "Delete account",
        description:
            "Are you sure you want to delete your account? This action cannot be undone.",
        actionTitle: "Delete", onDelete: () async {
      await _deleteAccount();
    });
  }

  Future<void> _deleteAccount() async {
    // Assuming you have an API endpoint for account deletion
    var apple_id = SharedData().apple_user_identifier;
    final response = await http.delete(
      Uri.parse(
          'https://8n5whw25p0.execute-api.us-east-1.amazonaws.com/default/stripe-admin-apple-users?apple_id=$apple_id'),
      // headers: {
      //   'Authorization': 'Bearer your_auth_token',
      // },
    );

    print(response.body);
    if (response.statusCode == 200) {
      await SharedData().clearAppleUserIdentifier();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => CreateAccountPage()),
        (Route<dynamic> route) => false,
      );
    } else {
      // Handle errors
      print("Failed to delete account: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF29B6F6),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title: Text('Settings',
              style: TextStyle(color: Colors.white, fontFamily: 'Urbanist')),
        ),
        body: Container(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.grey[200]
              : Colors.black26,
          child: ListView(
            children: [
              buildGroup([
                ListTile(
                  title:
                      Text('Theme', style: TextStyle(fontFamily: 'Urbanist')),
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
                        child: Text('Light',
                            style: TextStyle(fontFamily: 'Urbanist')),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark',
                            style: TextStyle(fontFamily: 'Urbanist')),
                      ),
                    ],
                  ),
                ),
              ]),
              if (AppleStoreProductManager().lastTransaction != null &&
                  AppleStoreProductManager().lastTransaction?.productId !=
                      "unlimited_time")
                buildGroup([
                  ListTile(
                    title: Text('Subscription',
                        style: TextStyle(fontFamily: 'Urbanist')),
                    subtitle: Text(AppleStoreProductManager()
                            .renewalTransaction
                            ?.productId ??
                        ""),
                    onTap: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RenewalTransactionScreen(
                              transaction: AppleStoreProductManager()
                                  .renewalTransaction)));
                    },
                  ),
                ]),
              buildGroup([
                ListTile(
                  title: Text(
                    'Disconnect Stripe',
                    style: TextStyle(fontFamily: 'Urbanist'),
                  ),
                  onTap: () async {
                    if (!DemoManager().demo) {
                      await SharedData().clearStripeAccessKey();
                      await SharedData().clearStripePublishableKey();
                    }

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => StripeConnectPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
                // ListTile(
                //   title: Text(
                //     'Sign Out',
                //     style: TextStyle(fontFamily: 'Urbanist'),
                //   ),
                //   onTap: () async {
                //     await SharedData().clearAppleUserIdentifier();
                //     Navigator.of(context).pushAndRemoveUntil(
                //       MaterialPageRoute(
                //           builder: (context) => CreateAccountPage()),
                //       (Route<dynamic> route) => false,
                //     );
                //   },
                // ),
                // ListTile(
                //   title: Text(
                //     'Delete your account',
                //     style: TextStyle(fontFamily: 'Urbanist', color: Colors.red),
                //   ),
                //   onTap: () async {
                //     await _confirmDeleteAccount();
                //     // await SharedData().clearAppleUserIdentifier();
                //     // Navigator.of(context).pushAndRemoveUntil(
                //     //   MaterialPageRoute(builder: (context) => CreateAccountPage()),
                //     //       (Route<dynamic> route) => false,
                //     // );
                //   },
                // ),
              ]),
              buildGroup([
                ListTile(
                  title: const Text(
                    'Term of use',
                    style: TextStyle(fontFamily: 'Urbanist'),
                  ),
                  onTap: () async {
                    _launchURL(
                        "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/");
                  },
                ),
                ListTile(
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontFamily: 'Urbanist'),
                  ),
                  onTap: () async {
                    _launchURL(
                        "https://stripeinvoice-app-public.s3.amazonaws.com/stripeinvoice-privacy-policy.html");
                  },
                ),
              ]),
              buildGroup([
                ListTile(
                  title: Text(
                    'iOS App version $_version+$_buildNumber',
                    style: const TextStyle(fontFamily: 'Urbanist'),
                  ),
                  onTap: () async {},
                ),
              ]),
              // Add more groups as needed
            ],
          ),
        ));
  }
}
