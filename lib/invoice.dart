import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/add_invoice.dart';
import 'package:stripe_invoice/invoice_detail.dart';
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/settings-page.dart';
import 'package:stripe_invoice/data.dart';
import 'package:stripe_invoice/views/CustomText.dart';

class LineItem {
  final String? description;
  final int quantity;
  final double unitPrice;
  final double amount;

  LineItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  factory LineItem.fromJson(Map<String, dynamic> json) {
    return LineItem(
      description: json['description'],
      quantity: json['quantity'],
      unitPrice: json['amount'] / json['quantity'] / 100.0,
      amount: json['amount'] / 100.0,
    );
  }
}

class Invoice {
  final String id;
  final String customerName;
  final DateTime periodEnd;
  final String status;
  final double amountDue;
  final String currency;
  final String? hostedInvoiceUrl;
  final List<LineItem> lineItems;
  final String? invoicePdf;
  final String? number;

  Invoice({
    required this.id,
    required this.customerName,
    required this.periodEnd,
    required this.status,
    required this.amountDue,
    required this.currency,
    required this.hostedInvoiceUrl,
    required this.lineItems,
    required this.invoicePdf,
    required this.number,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    var lineItemsJson = json['lines']['data'] as List;
    List<LineItem> lineItemsList =
        lineItemsJson.map((i) => LineItem.fromJson(i)).toList();

    return Invoice(
      id: json['id'],
      customerName: json['customer_name'],
      periodEnd: DateTime.fromMillisecondsSinceEpoch(json['period_end'] * 1000),
      status: json['status'],
      amountDue: (json['amount_due'] / 100.0),
      currency: json['currency'],
      hostedInvoiceUrl: json['hosted_invoice_url'],
      lineItems: lineItemsList,
      invoicePdf: json['invoice_pdf'],
      number: json['number'],
    );
  }
}

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  late List<Invoice> _invoices = [];
  bool _isLoading = false;
  bool _hasMore = true;
  SharedData sharedData = SharedData();
  bool _isSearching = false; // For showing/hiding search field
  String _searchType = 'customer'; // Default search type
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'draft'; // Default status for dropdown
  String? _nextPage; // Pagination cursor for search

  final List<String> _statuses = [
    'draft',
    'open',
    'paid',
    'uncollectible',
    'void'
  ];

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices({bool isRefreshing = false}) async {
    if (!_isLoading) {
      if (!isRefreshing) {
        setState(() => _isLoading = true);
      }

      final response = await http.get(
        Uri.https('api.stripe.com', '/v1/invoices', {
          'limit': '10',
          'starting_after': isRefreshing
              ? ''
              : (_invoices.isNotEmpty ? _invoices.last.id : '')
        }),
        headers: {'Authorization': 'Bearer ${sharedData.stripe_access_key}'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> invoicesData = jsonData['data'];
        setState(() {
          if (isRefreshing) {
            _invoices.clear(); // Clear existing invoices if refreshing
          }
          _invoices.addAll(
              invoicesData.map((data) => Invoice.fromJson(data)).toList());
          _hasMore = jsonData['has_more'];
        });
      } else {
        print('Failed to fetch invoices: ${response.statusCode}');
      }
      if (!isRefreshing) {
        setState(() => _isLoading = false);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    }
  }

  Future<void> _searchInvoices(String query,
      {bool isRefreshing = false}) async {
    if (!_isLoading && (_hasMore || isRefreshing)) {
      if (!isRefreshing) {
        setState(() => _isLoading = true);
      }

      final response = await http.get(
        Uri.https('api.stripe.com', '/v1/invoices/search', {
          'query': query,
          'limit': '10',
          if (!isRefreshing && _nextPage != null) 'page': _nextPage!,
        }),
        headers: {'Authorization': 'Bearer ${sharedData.stripe_access_key}'},
      );
      print (response.body);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> invoicesData = jsonData['data'];
        setState(() {
          if (isRefreshing) {
            _invoices.clear(); // Clear existing invoices if refreshing
            _nextPage = null; // Reset the pagination cursor
          }
          _invoices.addAll(
              invoicesData.map((data) => Invoice.fromJson(data)).toList());
          _hasMore = jsonData['has_more'];
          _nextPage = jsonData['next_page']; // Update next_page cursor
        });
      } else {
        print('Failed to search invoices: ${response.statusCode}');
      }
      if (!isRefreshing) {
        setState(() => _isLoading = false);
      } else {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty || _searchType == 'status') {
      final searchQuery = _searchType == 'status' ? _selectedStatus : query;
      _searchInvoices("$_searchType:'$searchQuery'", isRefreshing: true);
    } else {
      _fetchInvoices(isRefreshing: true);
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
        title: const CustomText(text: 'Invoices', color: Colors.white,),
        backgroundColor: Color(0xFF29B6F6),
        leading: IconButton(
          color: Colors.white,
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        actions: <Widget>[
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
                MaterialPageRoute(builder: (context) => AddInvoiceScreen()),
              ).then((value) async => await _fetchInvoices(isRefreshing: true));
            },
          ),
        ],
        bottom: _isSearching
            ? PreferredSize(
                preferredSize: Size.fromHeight(100.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _searchType == 'status'
                          ? DropdownButton<String>(
                              value: _selectedStatus,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStatus = newValue!;
                                });
                                _onSearchChanged();
                              },
                              items: _statuses.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: CustomText(text: value),
                                );
                              }).toList(),
                              isExpanded: true,
                              underline: Container(
                                height: 2,
                                color: Colors.white,
                              ),
                            )
                          : TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search by $_searchType',
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                isDense: true,
                                // Added to make the TextField smaller
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 8.0),
                                // Adjust padding
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
                              // Adjust font size to make it smaller
                              onChanged: (value) {
                                _onSearchChanged();
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: CustomText(text: 'Customer'),
                            selected: _searchType == 'customer',
                            onSelected: (bool selected) {
                              setState(() {
                                _searchType = 'customer';
                              });
                              _onSearchChanged();
                            },
                          ),
                          SizedBox(width: 8),
                          ChoiceChip(
                            label: CustomText(text: 'Status'),
                            selected: _searchType == 'status',
                            onSelected: (bool selected) {
                              setState(() {
                                _searchType = 'status';
                              });
                              _onSearchChanged();
                            },
                          ),
                          SizedBox(width: 8),
                          ChoiceChip(
                            label: CustomText(text: 'Amount'),
                            selected: _searchType == 'amount',
                            onSelected: (bool selected) {
                              setState(() {
                                _searchType = 'amount';
                              });
                              _onSearchChanged();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
      body: Stack(
        children: [
          _invoices.isEmpty
              ? const Center(
                  child: CustomText(text: "No invoice data"),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent &&
                        !_isLoading) {
                      if (_isSearching && _hasMore) {
                        final query = _searchType == 'status'
                            ? _selectedStatus
                            : _searchController.text.trim();
                        _searchInvoices("$_searchType:'$query'");
                      } else if (!_isSearching) {
                        _fetchInvoices();
                      }
                    }
                    return true;
                  },
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (_isSearching) {
                        final query = _searchType == 'status'
                            ? _selectedStatus
                            : _searchController.text.trim();
                        await _searchInvoices("$_searchType:'$query'",
                            isRefreshing: true);
                      } else {
                        await _fetchInvoices(isRefreshing: true);
                      }
                    },
                    child: ListView.builder(
                      itemCount: _invoices.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _invoices.length) {
                          return _hasMore
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox.shrink();
                        }
                        final invoice = _invoices[index];
                        return Material(
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      InvoiceDetailScreen(invoice: invoice),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        text: invoice.customerName,
                                        fontSize: 16.0,
                                        // color: Colors.black,
                                        // style: const TextStyle(fontSize: 16),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color:
                                              _getStatusColor(invoice.status),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final uncollectibleTextWidth =
                                                TextPainter(
                                              text: TextSpan(
                                                text: 'uncollectible',
                                                // Longest status text
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                              textDirection: TextDirection.ltr,
                                            )..layout(
                                                    maxWidth: double.infinity);

                                            final uncollectibleWidth =
                                                uncollectibleTextWidth.width;

                                            return SizedBox(
                                              width: uncollectibleWidth,
                                              child: CustomText(
                                                    align: TextAlign.center,
                                                    text: invoice.status,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CustomText(
                                        text: '${invoice.currency.toUpperCase()} \$${invoice.amountDue.toStringAsFixed(2)}',
                                      ),
                                      CustomText(
                                        text: _formatDate(invoice.periodEnd),
                                      ),
                                    ],
                                  ),
                                  const Divider(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'open':
        return Color(0xFF29B6F6);
      case 'paid':
        return Colors.green;
      case 'uncollectible':
        return Colors.red;
      case 'void':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
