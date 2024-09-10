// detail_customer_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:country_list_picker/country_list_picker.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/customer.dart';
import 'package:stripe_invoice/data.dart';
import 'package:stripe_invoice/views/CustomInputDecoration.dart';

class DetailCustomerScreen extends StatefulWidget {
  final Customer customer;

  const DetailCustomerScreen({Key? key, required this.customer})
      : super(key: key);

  @override
  _DetailCustomerScreenState createState() => _DetailCustomerScreenState();
}

class _DetailCustomerScreenState extends State<DetailCustomerScreen> {
  late Countries selectedCountryCode;
  String? phoneNumber;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController descriptionController;
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController cityController;
  late TextEditingController provinceController;
  late TextEditingController postalCodeController;
  late TextEditingController phoneNumberController;
  final List<Countries> _countries = Countries.values.toList();
  late List<Countries> sortedCountries;
  final _formKey = GlobalKey<FormState>();
  SharedData sharedData = SharedData();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.customer.name);
    emailController = TextEditingController(text: widget.customer.email);
    descriptionController =
        TextEditingController(text: widget.customer.description);
    addressLine1Controller =
        TextEditingController(text: widget.customer.addressLine1);
    addressLine2Controller =
        TextEditingController(text: widget.customer.addressLine2);
    cityController = TextEditingController(text: widget.customer.city);
    provinceController = TextEditingController(text: widget.customer.state);
    postalCodeController =
        TextEditingController(text: widget.customer.postalCode);
    phoneNumberController = TextEditingController(text: widget.customer.phone);
    selectedCountryCode = Countries.values.firstWhere(
        (country) => country.iso_3166_1_alpha2 == widget.customer.country);

    sortedCountries = _countries.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> updateStripeCustomer({
    required String customerId,
    required String name,
    required String description,
    required String email,
    required String city,
    required String country,
    required String addressLine1,
    String? addressLine2,
    required String postalCode,
    required String state,
    required String phone,
  }) async {
    // Construct the request body
    Map<String, dynamic> requestBody = {
      'name': name,
      'email': email,
      'description': description,
      'address[city]': city,
      'address[country]': country,
      'address[line1]': addressLine1,
      'address[postal_code]': postalCode,
      'address[state]': state,
      'phone': phone
    };

    if (addressLine2 != null) {
      requestBody['address[line2]'] = addressLine2;
    }

    // Make the API request
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers/$customerId'),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Customer updated successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer updated successfully.')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        // print('Failed to update customer: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(jsonDecode(response.body)['error']['message'])),
        );
      }
    } catch (e) {
      print('Error updating customer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back indicator
        ),
        title: const Text(
          'Customer Details',
          style: TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
        ),
        backgroundColor: Color(0xFF29B6F6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(fontFamily: 'Urbanist'),
                  decoration: CustomInputDecoration.inputStyle(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: CustomInputDecoration.inputStyle(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextField(
                  controller: descriptionController,
                  style: TextStyle(fontFamily: 'Urbanist'),
                  decoration: CustomInputDecoration.inputStyle(
                    labelText: 'Description',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Billing Address',
                  style: TextStyle(fontFamily: 'Urbanist'),
                  // style: Theme.of(context).textTheme.headline6,
                ),
                const SizedBox(height: 8.0),
                DropdownButton<Countries>(
                  isExpanded: true,
                  value: selectedCountryCode,
                  items: sortedCountries.map((country) {
                    return DropdownMenuItem(
                      value: country,
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          country.name,
                          // style: TextStyle(fontSize: 18),
                          style: TextStyle(fontFamily: 'Urbanist'),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCountryCode = value!;
                    });
                  },
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: addressLine1Controller,
                  decoration: CustomInputDecoration.inputStyle(
                    labelText: 'Address Line 1',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: addressLine2Controller,
                  decoration: CustomInputDecoration.inputStyle(
                    labelText: 'Address Line 2',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: cityController,
                  decoration: CustomInputDecoration.inputStyle(
                    labelText: 'City',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: provinceController,
                  decoration: CustomInputDecoration.inputStyle(
                    labelText: 'Province/State',
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: postalCodeController,
                  decoration: CustomInputDecoration.inputStyle(
                    labelText: 'Postal Code',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: phoneNumberController,
                  decoration: CustomInputDecoration.inputStyle(
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Handle form submission
                    String name = nameController.text;
                    String email = emailController.text;
                    String description = descriptionController.text;
                    String addressLine1 = addressLine1Controller.text;
                    String addressLine2 = addressLine2Controller.text;
                    String city = cityController.text;
                    String province = provinceController.text;
                    String postalCode = postalCodeController.text;
                    String phone = phoneNumberController.text;

                    if (name.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please complete all required fields.')),
                      );
                      return;
                    }

                    updateStripeCustomer(
                      customerId: widget.customer.id,
                      name: name,
                      email: email,
                      description: description,
                      city: city,
                      country: selectedCountryCode.iso_3166_1_alpha2,
                      addressLine1: addressLine1,
                      addressLine2: addressLine2,
                      postalCode: postalCode,
                      state: province,
                      phone: phone,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 3,
                    backgroundColor: const Color(0xFF29B6F6),
                  ),
                  child: Text(
                    'Update Customer',
                    style: TextStyle(
                      color: Colors.white,
                      // fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
