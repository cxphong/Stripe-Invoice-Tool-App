import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stripe_invoice/settings.dart';

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
          // SwitchListTile(
          //   title: Text('Enable Notifications'),
          //   value: Provider.of<SettingsProvider>(context).notificationsEnabled,
          //   onChanged: (bool value) {
          //     Provider.of<SettingsProvider>(context, listen: false)
          //         .setNotificationsEnabled(value);
          //   },
          // ),
          // Add more settings options here
        ],
      ),
    );
  }
}
