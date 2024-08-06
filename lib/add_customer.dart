import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:country_list_picker/country_list_picker.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/constant.dart';
import 'package:stripe_invoice/data.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({Key? key}) : super(key: key);

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  Countries selectedCountryCode = Countries.United_States;
  String? phoneNumber;
  final TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController addressLine1Controller = TextEditingController();
  TextEditingController addressLine2Controller = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController provinceController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  final List<Countries> _countries = Countries.values.toList();
  late List<Countries> sortedCountries;
  final _formKey = GlobalKey<FormState>();
  SharedData sharedData = SharedData();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sortedCountries = _countries.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<void> createStripeCustomer({
    required String name,
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
        Uri.parse('https://api.stripe.com/v1/customers'),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Customer created successfully.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Customer created successfully.')),
        );
      } else {
        print('Failed to create customer. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
              content: Text(jsonDecode(response.body)['error']['message'])),
        );
      }
    } catch (e) {
      print('Error creating customer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Set the color of the back indicator
        ),
        title: const Text('Add Customer', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist')),
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
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    // filled: true,
                    // border: OutlineInputBorder(),
                    // fillColor: Colors.grey[100],
                  ),
                ),
                SizedBox(height: 16),
                const SizedBox(height: 16.0),
                TextFormField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    // filled: true,
                    // border: OutlineInputBorder(),
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
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    // filled: true,
                    // border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 48.0),
                Text(
                  'Billing Address',
                  style: TextStyle(fontFamily: 'Urbanist'),
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
                CountryListPicker(
                  initialCountry: selectedCountryCode,
                  isShowCountryName: false,
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                  // onTap: () {},
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: addressLine1Controller,
                  decoration: InputDecoration(
                    labelText: 'Address Line 1',
                    // filled: true,
                    // border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: addressLine2Controller,
                  decoration: InputDecoration(
                    labelText: 'Address Line 2',
                    // filled: true,
                    // border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: cityController,
                  decoration: InputDecoration(
                    labelText: 'City',
                    // filled: true,
                    // border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: provinceController,
                  decoration: InputDecoration(
                    labelText: 'Province/State',
                    // filled: true,
                    // border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  style: TextStyle(fontFamily: 'Urbanist'),
                  controller: postalCodeController,
                  decoration: InputDecoration(
                    labelText: 'Postal Code',
                    // filled: true,
                    // border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 8.0),
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

                    if (name.isEmpty || email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please complete all required fields.')),
                      );
                      return;
                    }

                    // if (_formKey.currentState!.validate()) {
                      // Handle form submission
                      print('name: $name');
                      print('Email: $email');
                      print('Description: $description');
                      print('Address Line 1: $addressLine1');
                      print('Address Line 2: $addressLine2');
                      print('City: $city');
                      print('Province: $province');
                      print('Postal Code: $postalCode');
                      print(
                          'country = ' + selectedCountryCode.iso_3166_1_alpha2);
                      // print('phone = ' + phoneNumber);

                      createStripeCustomer(
                          name: '$name',
                          email: email,
                          city: city,
                          country: selectedCountryCode.iso_3166_1_alpha2,
                          // Assuming the country is the United States, you can change it as needed
                          addressLine1: addressLine1,
                          addressLine2: addressLine2,
                          postalCode: postalCode,
                          state: province,
                          phone: phoneNumber != null ? phoneNumber! : "");
                  },
                  style: ElevatedButton.styleFrom(
                    // backgroundColor: Color(0xFF29B6F6),
                    // Background color of the button
                    // foregroundColor: Colors.white,
                    // Text color of the button
                    backgroundColor: const Color(0xFF29B6F6),
                    padding:
                        EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    // Button padding
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(8.0), // Button border radius
                    ),
                    elevation: 3, // Elevation of the button
                  ),
                  child: Text(
                    'Add Customer',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Urbanist',
                      // fontSize: 16.0, // Font size of the button text
                      fontWeight:
                          FontWeight.bold, // Font weight of the button text
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
