// add_tax_rate_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/data.dart';
import 'package:stripe_invoice/views/CustomInputDecoration.dart';
import 'package:stripe_invoice/views/CustomText.dart';

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
          SnackBar(content: CustomText(text: 'Tax rate added successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: CustomText(text: 'Failed to add tax rate ' + json.decode(response.body)['error']['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the color of the back indicator
        ),
        title: const CustomText(text: 'Add Tax Rate', color: Colors.white,),
        backgroundColor: Color(0xFF29B6F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: CustomInputDecoration.inputStyle(labelText: 'Display Name'),
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
                decoration: CustomInputDecoration.inputStyle(labelText: 'Percentage'),
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
                title: const CustomText(text: 'Inclusive'),
                activeColor:  const Color(0xFF29B6F6),
                inactiveThumbColor: Colors.grey,
                value: _inclusive,
                onChanged: (value) {
                  setState(() {
                    _inclusive = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                decoration: CustomInputDecoration.inputStyle(labelText: 'Tax Type'),
                items: _taxTypes
                    .map((taxType) => DropdownMenuItem<String>(
                  value: taxType['value'],
                  child: CustomText(text: taxType['label']!),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addTaxRate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF29B6F6),
                  // backgroundColor: Color(0xFF29B6F6),
                  // Background color of the button
                  // foregroundColor: Colors.white,
                  // Text color of the button
                  padding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(8.0), // Button border radius
                  ),
                  elevation: 3, // Elevation of the button
                ),
                child: const Text('Add Tax Rate',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Urbanist',
                    // fontSize: 16.0, // Font size of the button text
                    fontWeight:
                    FontWeight.bold, // Font weight of the button text
                  ),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
