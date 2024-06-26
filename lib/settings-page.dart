import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'settings.dart'; // Import SettingsProvider class
import 'main.dart'; // Import MyApp class for navigation

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Theme'),
            subtitle: Text('Select App Theme'),
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
                  child: Text('System Default'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text('Log Out', style: TextStyle(color: Colors.red),),
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
