import 'package:flutter/material.dart';
import 'package:country_list_picker/country_list_picker.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_invoice/constant.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({Key? key}) : super(key: key);

  @override
  _AddCustomerScreenState createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<CustomerDetailScreen> {
  Countries selectedCountryCode = Countries.United_States;
  String? phoneNumber;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
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
          'Authorization': 'Bearer ${stripe_secret_key}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Customer created successfully.');
      } else {
        print('Failed to create customer. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error creating customer: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Customer'),
        backgroundColor: Color(0xFF5469d4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                  TextField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
              const SizedBox(height: 16.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              Text(
                'Billing Address',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8.0),
              DropdownButton<Countries>(
                isExpanded: true,
                value: selectedCountryCode,
                items:
                sortedCountries.map((country) {
                  return DropdownMenuItem(
                    value: country,
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        country.name,
                        style: TextStyle(fontSize: 18),
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
              CountryListPicker(
                initialCountry: selectedCountryCode,
                isShowCountryName: true,
                onChanged: (value) {
                  phoneNumber = value;
                },
                onTap: () {},
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: addressLine1Controller,
                decoration: InputDecoration(
                  labelText: 'Address Line 1',
                  filled: true,
                  fillColor:  Colors.grey[100],
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: addressLine2Controller,
                decoration: InputDecoration(
                  labelText: 'Address Line 2',
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  labelText: 'City',
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: provinceController,
                decoration: InputDecoration(
                  labelText: 'Province',
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: postalCodeController,
                decoration: InputDecoration(
                  labelText: 'Postal Code',
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  // Handle form submission
                  String firstName = firstNameController.text;
                  String lastName = lastNameController.text;
                  String email = emailController.text;
                  String description = descriptionController.text;
                  String addressLine1 = addressLine1Controller.text;
                  String addressLine2 = addressLine2Controller.text;
                  String city = cityController.text;
                  String province = provinceController.text;
                  String postalCode = postalCodeController.text;

                  // Handle form submission
                  print('First Name: $firstName');
                  print('Last Name: $lastName');
                  print('Email: $email');
                  print('Description: $description');
                  print('Address Line 1: $addressLine1');
                  print('Address Line 2: $addressLine2');
                  print('City: $city');
                  print('Province: $province');
                  print('Postal Code: $postalCode');
                  print('country = ' + selectedCountryCode.iso_3166_1_alpha2);
                  print('phone = ' + phoneNumber!);

                  createStripeCustomer(
                    name: '$firstName $lastName',
                    email: email,
                    city: city,
                    country: selectedCountryCode.iso_3166_1_alpha2, // Assuming the country is the United States, you can change it as needed
                    addressLine1: addressLine1,
                    addressLine2: addressLine2,
                    postalCode: postalCode,
                    state: province,
                    phone: phoneNumber!
                  );
                },
                child: const Text('Add Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
