// add_tax_rate_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/data.dart';

class AddTaxRateScreen extends StatefulWidget {
  const AddTaxRateScreen({Key? key}) : super(key: key);

  @override
  State<AddTaxRateScreen> createState() => _AddTaxRateScreenState();
}

class _AddTaxRateScreenState extends State<AddTaxRateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _displayName = '';
  double _percentage = 0;
  bool _inclusive = false;
  String? _selectedTaxType;
  SharedData sharedData = SharedData();

  final List<Map<String, String>> _taxTypes = [
    {'value': 'gst', 'label': 'Goods and Services Tax'},
    {'value': 'sales_tax', 'label': 'Sales Tax'},
    {'value': 'vat', 'label': 'Value-Added Tax'},
  ];

  Future<void> _addTaxRate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final response = await http.post(
        Uri.https('api.stripe.com', '/v1/tax_rates'),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: {
          'display_name': _displayName,
          'percentage': _percentage.toString(),
          'inclusive': _inclusive.toString(),
          'tax_type': _selectedTaxType,
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tax rate added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add tax rate')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Tax Rate'),
        backgroundColor: Color(0xFF29B6F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Display Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _displayName = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Percentage'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a percentage';
                  }
                  final percentage = double.tryParse(value);
                  if (percentage == null || percentage < 0) {
                    return 'Please enter a valid percentage';
                  }
                  return null;
                },
                onSaved: (value) {
                  _percentage = double.parse(value!);
                },
              ),
              SwitchListTile(
                title: Text('Inclusive'),
                value: _inclusive,
                onChanged: (value) {
                  setState(() {
                    _inclusive = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Tax Type'),
                items: _taxTypes
                    .map((taxType) => DropdownMenuItem<String>(
                  value: taxType['value'],
                  child: Text(taxType['label']!),
                ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a tax type';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _selectedTaxType = value;
                  });
                },
                onSaved: (value) {
                  _selectedTaxType = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTaxRate,
                child: Text('Add Tax Rate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
