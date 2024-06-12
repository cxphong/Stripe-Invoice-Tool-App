// invoice_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/add_invoice.dart';
import 'package:stripe_invoice/invoice_detail.dart';
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/custom_appbar.dart';
import 'package:stripe_invoice/settings-page.dart';
import 'package:stripe_invoice/settings.dart';
import 'package:stripe_invoice/data.dart';

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
    required this.number
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
      number: json['number']
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
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  SharedData sharedData = SharedData();

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
          'starting_after':isRefreshing ? '' : (_invoices.isNotEmpty ? _invoices.last.id : '')
        }),
        headers: {'Authorization': 'Bearer ${sharedData.stripe_access_key}'},
      );

      if (response.statusCode == 200) {
        print (response.body);
        final jsonData = jsonDecode(response.body);
        final List<dynamic> invoicesData = jsonData['data'];
        setState(() {
          if (isRefreshing) {
            _invoices.clear(); // Clear existing invoices if refreshing
          }
          _invoices.addAll(
              invoicesData.map((data) => Invoice.fromJson(data)).toList());
          _hasMore = jsonData['has_more'];
          _currentPage++;
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

  Future<void> _handleRefresh() async {
    print("handle refresh");
    await _fetchInvoices(isRefreshing: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoices'),
        // foregroundColor: Colors.white,
        backgroundColor: Color(0xFF5469d4),
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            // Handle settings button press
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddInvoiceScreen()),
              );
            },
          ),
        ],
      ),
      body: _invoices.isEmpty
          ? const Center(
              child: Text("No invoice data"),
            )
          : NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      !_isLoading) {
                    _fetchInvoices();
                  }
                  return true;
                },
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
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
                      // color: Colors.transparent,
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
                                  Text(
                                    invoice.customerName,
                                    style: const TextStyle(
                                        fontSize: 16
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(invoice.status),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final uncollectibleTextWidth = TextPainter(
                                          text: TextSpan(
                                            text: 'uncollectible', // Longest status text
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          textDirection: TextDirection.ltr,
                                        )..layout(maxWidth: double.infinity);

                                        final uncollectibleWidth = uncollectibleTextWidth.width;

                                        return SizedBox(
                                          width: uncollectibleWidth,
                                          child: Text(
                                            invoice.status == 'void' ? 'canceled' : invoice.status,
                                            style: const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      },
                                    )

                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${invoice.currency.toUpperCase()} \$${invoice.amountDue.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    _formatDate(invoice.periodEnd),
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const Divider(
                                // color: Colors.black12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey;
      case 'open':
        return Colors.blueAccent;
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
