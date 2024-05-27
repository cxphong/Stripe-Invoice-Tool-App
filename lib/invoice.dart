// invoice_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/add_invoice.dart';
import 'package:stripe_invoice/invoice_detail.dart';
import 'package:stripe_invoice/constant.dart';

class LineItem {
  final String description;
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

  Invoice({
    required this.id,
    required this.customerName,
    required this.periodEnd,
    required this.status,
    required this.amountDue,
    required this.currency,
    required this.hostedInvoiceUrl,
    required this.lineItems,
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

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  Future<void> _fetchInvoices() async {
    if (!_isLoading && _hasMore) {
      setState(() => _isLoading = true);
      final response = await http.get(
        Uri.https('api.stripe.com', '/v1/invoices', {
          'limit': '10',
          'starting_after': _invoices.isNotEmpty ? _invoices.last.id : ''
        }),
        headers: {'Authorization': 'Bearer ${stripe_secret_key}'},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> invoicesData = jsonData['data'];
        setState(() {
          _invoices.addAll(
              invoicesData.map((data) => Invoice.fromJson(data)).toList());
          _hasMore = jsonData['has_more'];
          _currentPage++;
        });
      } else {
        print('Failed to fetch invoices: ${response.statusCode}');
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        backgroundColor: Colors.blue[400],
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
        child: CircularProgressIndicator(),
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
              color: Colors.transparent,
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
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            invoice.customerName,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(invoice.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              invoice.status == 'void' ? 'canceled' : invoice.status,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        color: Colors.black12,
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
    return '${date.day}/${date.month}/${date.year}';
  }
}
