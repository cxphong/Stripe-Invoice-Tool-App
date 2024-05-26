import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/add_invoice.dart';
import 'package:stripe_invoice/constant.dart';

class Invoice {
  final String id;
  final String customerName;
  final DateTime periodEnd;
  final String status;
  final double amountDue;
  final String currency;

  Invoice({
    required this.id,
    required this.customerName,
    required this.periodEnd,
    required this.status,
    required this.amountDue,
    required this.currency,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      customerName: json['customer_name'],
      periodEnd: DateTime.fromMillisecondsSinceEpoch(json['period_end'] * 1000),
      status: json['status'],
      amountDue: (json['amount_due'] / 100.0),
      currency: json['currency'],
    );
  }
}

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List<Invoice> _invoices = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _invoices = [];
    _fetchInvoices();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    if (!_isLoading && _hasMore) {
      setState(() => _isLoading = true);
      final response = await http.get(
        Uri.https('api.stripe.com', '/v1/invoices', {'limit': '10', 'starting_after': _invoices.isNotEmpty ? _invoices.last.id : null}),
        headers: {
          'Authorization': 'Bearer ${stripe_secret_key}'
        },
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> invoicesData = jsonData['data'];
        setState(() {
          _invoices.addAll(invoicesData.map((data) => Invoice.fromJson(data)).toList());
          _hasMore = jsonData['has_more'];
          _currentPage++;
        });
      } else {
        print('Failed to fetch invoices: ${response.statusCode}');
      }
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 500 && !_isLoading && _hasMore) {
      _fetchInvoices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
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
          : ListView.builder(
        controller: _scrollController,
        itemCount: _invoices.length,
        itemBuilder: (context, index) {
          final invoice = _invoices[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
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
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(invoice.status),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        invoice.status,
                        style: const TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${invoice.currency.toUpperCase()} \$${invoice.amountDue}',
                      style: const TextStyle(fontSize
                          : 14),
                    ),
                    Text(
                      '${_formatDate(invoice.periodEnd)}',
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
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.grey; // Adjust color as needed
      case 'open':
        return Colors.blueAccent; // Adjust color as needed
      case 'paid':
        return Colors.green; // Adjust color as needed
      case 'uncollectible':
        return Colors.red; // Adjust color as needed
      case 'void':
        return Colors.grey; // Adjust color as needed
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}
