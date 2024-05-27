import 'package:flutter/material.dart';
import 'package:stripe_invoice/customer.dart';
import 'package:stripe_invoice/invoice.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const MyHomePage(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(),
        textTheme: Typography.material2018().black.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
          fontFamily: 'Urbanist', // San Francisco font family
        ).copyWith(
          // Adjust font weight for all text styles
          bodyLarge: TextStyle(
            fontWeight: FontWeight.w500,
            fontFamily: "Urbanist"
          ),
          bodyMedium: TextStyle(
            fontWeight: FontWeight.w400, // Increase font weight for body text
              fontFamily: "Urbanist"
          ),
          bodySmall: TextStyle(
            fontWeight: FontWeight.w300, // Increase font weight for headline text
              fontFamily: "Urbanist"
          )
          // Add more text styles as needed
        ),
      ),
    );

  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('BottomNavigationBar Sample'),
      // ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue[400],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_document),
            label: 'Invoice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Customer',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.school),
          //   label: 'Product',
          // ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

final List<Widget> _screens = <Widget>[
  InvoiceScreen(),
  CustomerScreen(),
  // ProductScreen(),
];