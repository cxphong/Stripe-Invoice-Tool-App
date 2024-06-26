import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // for formatting dates
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/payment.dart';
import 'package:stripe_invoice/scan_credit_card.dart';
import 'package:stripe_invoice/data.dart';
import 'package:stripe_invoice/settings-page.dart';
import 'package:stripe_invoice/stripe.dart';

class PaymentIntent {
  final String id;
  final int amount;
  final String currency;
  final int created;
  final String status;

  PaymentIntent({
    required this.id,
    required this.amount,
    required this.currency,
    required this.created,
    required this.status,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'],
      amount: json['amount'],
      currency: json['currency'],
      created: json['created'],
      status: json['status'],
    );
  }
}

class PaymentScreen extends StatefulWidget {
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<PaymentIntent> _paymentIntents = [];
  bool _isLoading = false;
  bool _hasMore = true;
  SharedData sharedData = SharedData();

  @override
  void initState() {
    super.initState();
    _fetchPaymentIntents();
  }

  Future<void> _fetchPaymentIntents({bool refresh = false}) async {
    if (!_isLoading || refresh) {
      if (!refresh) {
        setState(() => _isLoading = true);
      }
      final int limit = 10;
      final String startingAfter = refresh
          ? ''
          : _paymentIntents.isNotEmpty
              ? _paymentIntents.last.id
              : '';
      final response = await http.get(
        Uri.https('api.stripe.com', '/v1/payment_intents', {
          'limit': '$limit',
          if (!refresh) 'starting_after': startingAfter,
        }),
        headers: {'Authorization': 'Bearer ${sharedData.stripe_access_key}'},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> paymentIntentsData = jsonData['data'];
        setState(() {
          if (refresh) {
            _paymentIntents.clear();
          }
          _paymentIntents.addAll(paymentIntentsData
              .map((data) => PaymentIntent.fromJson(data))
              .toList());
          _hasMore = jsonData['has_more'];
        });
      } else {
        print('Failed to fetch payment intents: ${response.statusCode}');
      }
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(int timestamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat.yMMMd().add_jm().format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
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
                  MaterialPageRoute(
                      builder: (context) => CreateStripePayment()));
            },
          ),
        ],
      ),
      body: _paymentIntents.isEmpty
          ? const Center(
              child: Text("No payment data"),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent &&
                    !_isLoading) {
                  _fetchPaymentIntents();
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () => _fetchPaymentIntents(refresh: true),
                child: ListView.builder(
                  itemCount: _paymentIntents.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _paymentIntents.length) {
                      final paymentIntent = _paymentIntents[index];
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              title: Text(
                                '${paymentIntent.amount / 100} ${paymentIntent.currency.toUpperCase()}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  'Created: ${_formatDate(paymentIntent.created)}\nStatus: ${paymentIntent.status}'),
                            ),
                            Divider(
                              thickness: 1,
                            )
                          ]);
                    } else if (_isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
            ),
    );
  }
}
