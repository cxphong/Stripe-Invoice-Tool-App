import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_invoice/data.dart';

class CreateStripePayment extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<CreateStripePayment> {
  final TextEditingController _amountController = TextEditingController();
  double amount = 0;
  final ValueNotifier<double> _amountNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<Currency> _currencyNotifier = ValueNotifier<Currency>(Currency(
    code: 'USD',
    name: 'United States Dollar',
    symbol: '\$',
    flag: '🇺🇸',
    number: 840,
    decimalDigits: 2,
    namePlural: 'US dollars',
    symbolOnLeft: true,
    decimalSeparator: '.',
    thousandsSeparator: ',',
    spaceBetweenAmountAndSymbol: false,
  ));
  SharedData sharedData = SharedData();

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey =
    "pk_test_51O5xFBIhRsa9dgl32CyqFayAJFdJcBEGR9pc7Q7lMWjw5IQFwayjgQBD1IEAqTJVzMXdANRjaR0OEJuQJTfZsxoF00HLUXe94w";
    _currencyNotifier.addListener(_updateFormattedAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _currencyNotifier.dispose();
    super.dispose();
  }

  void _updateFormattedAmount() {
    final String value = _amountController.text;
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) {
      cleaned = '000';
    }
    double amountValue = double.parse(cleaned) / 100.0;
    final formatter = NumberFormat.currency(
        locale: 'en_US', symbol: '${_currencyNotifier.value.code}\$');
    String newText = formatter.format(amountValue);

    _amountController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  _onAmountChanged(String value) {
    String cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) {
      cleaned = '000';
    }
    double amountValue = double.parse(cleaned) / 100.0;
    _amountNotifier.value = amountValue;
    setState(() {
      amount = amountValue;
    });
  }

  makeStripePayment(String clientSecret) {
    Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          customFlow: false,
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Flutter Stripe Store Demo',
          style: ThemeMode.dark,
        ));

    Stripe.instance.presentPaymentSheet();
  }

  Future<void> createPaymentIntent() async {
    const String apiUrl = "https://api.stripe.com/v1/payment_intents";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${sharedData.stripe_access_key}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(),
          'currency': _currencyNotifier.value.code,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonMap = jsonDecode(response.body);
        String clientSecret = jsonMap['client_secret'];

        makeStripePayment(clientSecret);
      } else {
        print('Failed to create Payment Intent: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while creating Payment Intent: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payment'),
        backgroundColor: Color(0xFF5469d4),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            const Text(
              'Enter an amount',
              style: TextStyle(fontSize: 18),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: ValueListenableBuilder<Currency>(
                      valueListenable: _currencyNotifier,
                      builder: (context, selectedCurrency, child) {
                        return TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            AmountInputFormatter(selectedCurrency),
                            MaxValueInputFormatter(999999.99)
                          ],
                          onChanged: _onAmountChanged,
                          style: const TextStyle(fontSize: 24.0),
                          decoration: const InputDecoration(
                            hintText: 'US\$0.00',
                            border: InputBorder.none,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Theme.of(context).brightness == Brightness.light
                        ? Border.all(
                        color: Colors.grey.shade300) // Light theme border
                        : Border.all(), // Dark theme border
                  ),
                  child: TextButton.icon(
                    onPressed: () {
                      showCurrencyPicker(
                        context: context,
                        showFlag: true,
                        showSearchField: true,
                        showCurrencyName: true,
                        showCurrencyCode: true,
                        onSelect: (Currency currency) {
                          print(currency);
                          _currencyNotifier.value = currency;
                        },
                      );
                    },
                    icon: Icon(Icons.arrow_drop_down),
                    label: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      // Aligns the icon and text to the left
                      children: [
                        Text(_currencyNotifier.value.code),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ValueListenableBuilder<double>(
              valueListenable: _amountNotifier,
              builder: (context, amount, child) {
                return ElevatedButton(
                  onPressed: amount > 0 ? createPaymentIntent : null,
                  child: Text('Pay'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MaxValueInputFormatter extends TextInputFormatter {
  final double maxValue;

  MaxValueInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final double newValueDouble =
        double.tryParse(newValue.text.replaceAll(RegExp(r'[^\d.]'), '')) ??
            maxValue + 1;
    if (newValueDouble <= maxValue) {
      return newValue;
    }
    return oldValue;
  }
}

class AmountInputFormatter extends TextInputFormatter {
  late Currency selectedCurrency;

  AmountInputFormatter(this.selectedCurrency);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String cleaned = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.isEmpty) {
      cleaned = '000';
    }
    double value = double.parse(cleaned) / 100.0;
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '${selectedCurrency.code}\$');
    String newText = formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
