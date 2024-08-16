import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/add_tax_rate.dart';
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/data.dart';

class TaxRate {
  final String id;
  final String displayName;
  final bool inclusive;
  final String taxType;
  final double percentage;
  final bool active;

  TaxRate({
    required this.id,
    required this.displayName,
    required this.inclusive,
    required this.taxType,
    required this.percentage,
    required this.active,
  });

  factory TaxRate.fromJson(Map<String, dynamic> json) {
    return TaxRate(
      id: json['id'],
      displayName: json['display_name'],
      inclusive: json['inclusive'],
      taxType: json['tax_type'] ?? 'Unknown',
      percentage: json['percentage'].toDouble(),
      active: json['active'],
    );
  }
}

class TaxRateScreen extends StatefulWidget {
  final bool selectMode;

  TaxRateScreen({Key? key, this.selectMode = false}) : super(key: key);

  @override
  State<TaxRateScreen> createState() => _TaxRateScreenState();
}

class _TaxRateScreenState extends State<TaxRateScreen> {
  List<TaxRate> _taxRates = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  SharedData sharedData = SharedData();

  @override
  void initState() {
    super.initState();
    _fetchTaxRates();
  }

  Future<void> _fetchTaxRates({bool isRefreshing = false}) async {
    if (!_isLoading) {
      setState(() => _isLoading = true);

      final response = await http.get(
        Uri.https('api.stripe.com', '/v1/tax_rates', {
          'limit': '10',
          'starting_after': isRefreshing
              ? ''
              : (_taxRates.isNotEmpty ? _taxRates.last.id : '')
        }),
        headers: {'Authorization': 'Bearer ${sharedData.stripe_access_key}'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> taxRatesData = jsonData['data'];
        setState(() {
          if (isRefreshing) {
            _taxRates.clear();
          }
          _taxRates.addAll(taxRatesData
              .map((data) => TaxRate.fromJson(data))
              .where((taxRate) => taxRate.active)
              .toList());
          _hasMore = jsonData['has_more'];
          _currentPage++;
        });
      } else {
        print('Failed to fetch tax rates: ${response.statusCode}');
      }

      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchTaxRates(isRefreshing: true);
  }

  Future<void> _archiveTaxRate(String id) async {
    final response = await http.post(
      Uri.https('api.stripe.com', '/v1/tax_rates/$id'),
      headers: {
        'Authorization': 'Bearer ${sharedData.stripe_access_key}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: {'active': 'false'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _taxRates.removeWhere((taxRate) => taxRate.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tax rate archived')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to archive tax rate')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back indicator
        ),
        title: Text('Tax Rates', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist')),
        backgroundColor: Color(0xFF29B6F6),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTaxRateScreen()),
              ).then((value) {
                _handleRefresh(); // Refresh the list after adding a new tax rate
              });
            },
          ),
        ],
      ),
      body: _taxRates.isEmpty
          ? Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Text('No active tax rates available', style: TextStyle(fontFamily: 'Urbanist'),),
      )
          : NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels ==
              scrollInfo.metrics.maxScrollExtent &&
              _hasMore &&
              !_isLoading) {
            _fetchTaxRates();
          }
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: ListView.builder(
            itemCount: _taxRates.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _taxRates.length) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              final taxRate = _taxRates[index];
              return Dismissible(
                key: Key(taxRate.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Icon(
                    Icons.archive,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  _archiveTaxRate(taxRate.id);
                },
                child: ListTile(
                  title: Text(taxRate.displayName),
                  subtitle: Text('${taxRate.taxType} - ${taxRate.percentage}%', style: TextStyle(fontFamily: 'Urbanist'),),
                  trailing: Text(taxRate.inclusive ? "Inclusive" : "Exclusive", style: TextStyle(fontFamily: 'Urbanist'),),
                  onTap: widget.selectMode
                      ? () {
                    Navigator.pop(context, taxRate);
                  }
                      : null,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
