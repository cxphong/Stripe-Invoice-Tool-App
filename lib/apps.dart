import 'package:flutter/material.dart';
import 'package:stripe_invoice/main.dart';
import 'package:stripe_invoice/customer.dart';
import 'package:stripe_invoice/invoice.dart';
import 'package:stripe_invoice/payment.dart';
import 'package:stripe_invoice/payment_intent.dart';
import 'package:stripe_invoice/product.dart';
import 'package:stripe_invoice/scan_credit_card.dart';
import 'package:stripe_invoice/settings.dart';
import 'package:provider/provider.dart';
import 'package:stripe_invoice/taxrate.dart';


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
      bottomNavigationBar: Container(
        // decoration: BoxDecoration(
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.grey.withOpacity(0.2), // Shadow color
        //       spreadRadius: 4, // Spread radius
        //       blurRadius: 4, // Blur radius
        //       // offset: Offset(0, 0), // Offset in the negative Y direction
        //     ),
        //   ],
        // ),
        child: BottomNavigationBar(
          // backgroundColor: ThemeData.light(),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_document),
              label: 'Invoice',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Customer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Taxrate',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF5469d4),
          onTap: _onItemTapped,
        ),
      ),
    );
  }

}

final List<Widget> _screens = <Widget>[
  InvoiceScreen(),
  CustomerScreen(),
  // TaxRateScreen(),
  PaymentScreen(),
  // ConnectPage()

];