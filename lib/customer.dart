import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/add_customer.dart';
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/customer_detail.dart';
import 'package:stripe_invoice/settings-page.dart';
import 'package:stripe_invoice/utils.dart';
import 'package:stripe_invoice/data.dart';

class Customer {
  final String id;
  final String name;
  final String email;
  final String? description;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? phone;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    this.description,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      description: json['description'],
      addressLine1: json['address'] != null ? json['address']['line1'] : null,
      addressLine2: json['address'] != null ? json['address']['line2'] : null,
      city: json['address'] != null ? json['address']['city'] : null,
      state: json['address'] != null ? json['address']['state'] : null,
      postalCode:
      json['address'] != null ? json['address']['postal_code'] : null,
      country: json['address'] != null ? json['address']['country'] : null,
      phone: json['phone'],
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
  String? _nextPage;
  String _searchQuery = '';
  String _searchType = 'name'; // Default search type
  bool _isSearching = false; // For showing/hiding search field
  final TextEditingController _searchController = TextEditingController();
  SharedData sharedData = SharedData();

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
        headers: {'Authorization': 'Bearer ${sharedData.stripe_access_key}'},
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

  Future<void> _searchCustomers(String query, {bool refresh = false}) async {
    if (!_isLoading && (_hasMore || refresh)) {
      if (!refresh) {
        setState(() => _isLoading = true);
      }
      final response = await http.get(
        Uri.https('api.stripe.com', '/v1/customers/search', {
          'query': query,
          'limit': '10',
          if (!refresh && _nextPage != null) 'page': _nextPage!,
        }),
        headers: {'Authorization': 'Bearer ${sharedData.stripe_access_key}'},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> customersData = jsonData['data'];
        setState(() {
          if (refresh) {
            _customers.clear();
            _nextPage = null; // Reset pagination cursor
          }
          _customers.addAll(
              customersData.map((data) => Customer.fromJson(data)).toList());
          _hasMore = jsonData['has_more'];
          _nextPage = jsonData['next_page']; // Update next_page cursor
        });
      } else {
        print('Failed to search customers: ${response.statusCode}');
      }
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      _searchCustomers("$_searchType:'$query'", refresh: true);
    } else {
      _fetchCustomers(refresh: true);
    }
  }

  Future<void> _deleteCustomer(String customerId) async {
    final response = await http.delete(
      Uri.https('api.stripe.com', '/v1/customers/$customerId'),
      headers: {'Authorization': 'Bearer ${sharedData.stripe_access_key}'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      print('Customer deleted successfully');
    } else {
      print('Failed to delete customer: ${response.statusCode}');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back indicator
        ),
        title: const Text('Customers', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist'),),
        backgroundColor: Color(0xFF29B6F6),
        leading: IconButton(
          icon: Icon(Icons.settings),
          color: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        actions: <Widget>[
          if (_isSearching)
            Expanded(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by $_searchType',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                    prefixIcon: Icon(Icons.search, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged();
                      },
                    ),
                  ),
                  style: TextStyle(fontSize: 14, fontFamily: 'Urbanist'),
                  onChanged: (value) {
                    _onSearchChanged();
                  },
                ),
              ),
            ),
          IconButton(
            color: Colors.white,
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _onSearchChanged();
                }
              });
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCustomerScreen()),
              ).then((value) => _fetchCustomers(refresh: true));
            },
          ),
        ],
        bottom: _isSearching
            ? PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ChoiceChip(
                  label: Text('Name', style: TextStyle(fontFamily: 'Urbanist'),),
                  selected: _searchType == 'name',
                  onSelected: (bool selected) {
                    setState(() {
                      _searchType = 'name';
                    });
                    _onSearchChanged();
                  },
                ),
                SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Email', style: TextStyle(fontFamily: 'Urbanist'),),
                  selected: _searchType == 'email',
                  onSelected: (bool selected) {
                    setState(() {
                      _searchType = 'email';
                    });
                    _onSearchChanged();
                  },
                ),
              ],
            ),
          ),
        )
            : null,
      ),
      body: _customers.isEmpty
          ? const Center(
        child: Text("No customer data"),
      )
          : NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels ==
              scrollInfo.metrics.maxScrollExtent &&
              !_isLoading) {
            if (_isSearching && _hasMore) {
              _searchCustomers("$_searchType:'${_searchController.text.trim()}'");
            } else if (!_isSearching) {
              _fetchCustomers();
            }
          }
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () async {
            if (_isSearching) {
              await _searchCustomers("$_searchType:'${_searchController.text.trim()}'", refresh: true);
            } else {
              await _fetchCustomers(refresh: true);
            }
          },
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
                    return true;
                  },
                  onDismissed: (direction) {
                    setState(() {
                      _customers.removeAt(index);
                    });

                    _deleteCustomer(customer.id);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(decodeText(customer.name), style: TextStyle(fontFamily: 'Urbanist'),),
                        subtitle: Text(customer.email, style: TextStyle(fontFamily: 'Urbanist'),),
                        onTap: () {
                          if (widget.isFromAddInvoice) {
                            Navigator.pop(context, customer);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DetailCustomerScreen(
                                        customer: customer),
                              ),
                            ).then((value) =>
                                _fetchCustomers(refresh: true));
                          }
                        },
                      ),
                      Divider(
                        thickness: 1,
                      ),
                    ],
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
