import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/add_customer.dart';
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/utils.dart';

class Customer {
  final String id;
  final String name;
  final String email;

  Customer({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

class CustomerScreen extends StatefulWidget {
  final bool isFromAddInvoice;

  const CustomerScreen({Key? key, this.isFromAddInvoice = false})
      : super(key: key);

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  List<Customer> _customers = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers({bool refresh = false}) async {
    if (!_isLoading || refresh) {
      if (!refresh) {
        setState(() => _isLoading = true);
      }
      final int limit = 10; // Set the limit to the desired value
      final String startingAfter = refresh
          ? ''
          : _customers.isNotEmpty
          ? _customers.last.id
          : ''; // Get the id of the last customer
      final response = await http.get(
        Uri.https('api.stripe.com', '/v1/customers', {
          'limit': '$limit',
          if (!refresh) 'starting_after': startingAfter,
        }),
        headers: {'Authorization': 'Bearer ${stripe_secret_key}'},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> customersData = jsonData['data'];
        setState(() {
          if (refresh) {
            _customers.clear();
          }
          _customers.addAll(
              customersData.map((data) => Customer.fromJson(data)).toList());
          _hasMore = jsonData['has_more'];
        });
      } else {
        print('Failed to fetch customers: ${response.statusCode}');
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCustomer(String customerId) async {
    final response = await http.delete(
      Uri.https('api.stripe.com', '/v1/customers/$customerId'),
      headers: {'Authorization': 'Bearer ${stripe_secret_key}'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      // Customer deleted successfully, you may want to update the UI or show a message
      print('Customer deleted successfully');
    } else {
      print('Failed to delete customer: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.blue[400],
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCustomerScreen()),
              );
            },
          ),
        ],
      ),
      body: _customers.isEmpty
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent &&
                !_isLoading) {
              _fetchCustomers();
            }
            return true;
          },
          child: RefreshIndicator(
            onRefresh: () =>
                _fetchCustomers(refresh: true)
            ,
            child: ListView.builder(
            itemCount: _customers.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _customers.length) {
                final customer = _customers[index];
                return Dismissible(
                  key: Key(customer.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    // This is where you can show a confirmation dialog
                    // if needed, return true to allow dismiss, false otherwise
                    return true;
                  },
                  onDismissed: (direction) {
                    // Remove the item from the data source
                    setState(() {
                      _customers.removeAt(index);
                    });

                    _deleteCustomer(customer.id);
                  },
                  child: ListTile(
                    title: Text(decodeText(customer.name)),
                    subtitle: Text(customer.email),
                    onTap: () {
                      // Return the selected customer to the previous screen
                      if (widget.isFromAddInvoice)
                        Navigator.pop(context, customer);
                    },
                  ),
                );
              } else if (_isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
              return const SizedBox(); // Placeholder for the loading indicator
              }
            },
          ),
        ),
      ),
    );
  }
}