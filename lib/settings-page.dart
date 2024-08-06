import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_invoice/subscription_screen.dart';
import 'data.dart';
import 'settings.dart'; // Import SettingsProvider class
import 'main.dart'; // Import MyApp class for navigation

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF29B6F6),
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back indicator
        ),
        title: Text('Settings', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist')),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Theme', style: TextStyle(fontFamily: 'Urbanist')),
            subtitle: Text('Select App Theme', style: TextStyle(fontFamily: 'Urbanist')),
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
                  child: Text('System Default', style: TextStyle(fontFamily: 'Urbanist'),),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light', style: TextStyle(fontFamily: 'Urbanist')),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark', style: TextStyle(fontFamily: 'Urbanist')),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              'Subscription',
                style: TextStyle(fontFamily: 'Urbanist')
              // style: TextStyle(color: Colors.s),
            ),
            onTap: () async {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SubscriptionScreen()));
            },
          ),
          ListTile(
            title: Text(
              'Disconnect Stripe Account',
              style: TextStyle(color: Colors.red, fontFamily: 'Urbanist'),
            ),
            onTap: () async {
                  await SharedData().clearStripeAccessKey();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => ConnectPage()),
                    (Route<dynamic> route) => false,
                  );
            },
          ),
          // Add more settings options here
        ],
      ),
    );
  }
}
