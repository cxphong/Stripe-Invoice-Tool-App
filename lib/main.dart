import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:stripe_invoice/apple_store_products.dart';
import 'package:stripe_invoice/apple_signin.dart';
import 'package:stripe_invoice/freetrial.dart';
import 'package:stripe_invoice/launcher.dart';
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

void main()  {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: ConnectPage(),
    ),
  );
}

class ConnectPage extends StatelessWidget {
  ConnectPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
      return MaterialApp(
        // title: 'Flutter Demo',
        home: LauncherScreen(),
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
