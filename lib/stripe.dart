import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_invoice/data.dart';
import 'package:stripe_invoice/number_keyboard.dart';

class CreateStripePayment extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<CreateStripePayment> {
  final TextEditingController _amountController = TextEditingController();
  double amount = 0;
  final ValueNotifier<double> _amountNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<Currency> _currencyNotifier =
      ValueNotifier<Currency>(Currency(
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
    Stripe.publishableKey = sharedData.stripe_publishable_key;
    _currencyNotifier.addListener(_updateFormattedAmount);
    print(Stripe.publishableKey);
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
    print(amount);

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

        print("secret = " + clientSecret);
        makeStripePayment(clientSecret);
      } else {
        print('Failed to create Payment Intent: ${response.body}');
      }
    } catch (e) {
      print('Error occurred while creating Payment Intent: $e');
    }
  }

  void _onKeyTap(String value) {
    final text = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    final newText = text + value;
    final formattedText = _formatCurrency(newText);
    _amountController.text = formattedText;
    _amountController.selection =
        TextSelection.fromPosition(TextPosition(offset: formattedText.length));
    double amountValue = double.parse(newText) / 100.0;
    setState(() {
      amount = amountValue;
    });
  }

  void _onBackspace() {
    final text = _amountController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.isNotEmpty) {
      final newText = text.substring(0, text.length - 1);
      final formattedText = _formatCurrency(newText);
      _amountController.text = formattedText;
      _amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: formattedText.length));
      double amountValue = double.parse(newText) / 100.0;
      setState(() {
        amount = amountValue;
      });
    }
  }

  void _onClear() {
    _amountController.clear();
    setState(() {
      amount = 0;
    });
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) {
      return 'US\$0.00';
    }
    final number = int.parse(value);
    final formattedNumber = (number / 100).toStringAsFixed(2);
    return 'US\$' +
        formattedNumber.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(0.0),
      child: Stack(
        children: [
          // Top section with currency input
          FractionallySizedBox(
            heightFactor: 0.3, // 30% of the height
            widthFactor: 1.0,
            child: Container(
              color: const Color(0xFF29B6F6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: ValueListenableBuilder<Currency>(
                        valueListenable: _currencyNotifier,
                        builder: (context, selectedCurrency, child) {
                          return TextField(
                            enabled: false,
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              AmountInputFormatter(selectedCurrency),
                              MaxValueInputFormatter(999999.99)
                            ],
                            onChanged: _onAmountChanged,
                            style: const TextStyle(
                                fontSize: 36.0, color: Colors.white, fontFamily: 'Urbanist'),
                            decoration: const InputDecoration(
                              hintText: 'US\$0.00',
                              hintStyle: TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
                              border: InputBorder.none,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
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
                            setState(() {
                              _currencyNotifier.value = currency;
                            });
                          },
                        );
                      },
                      icon: Icon(Icons.arrow_drop_down),
                      label: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            _currencyNotifier.value.code,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom section with number keyboard and button
          Align(
            alignment: Alignment.bottomCenter,
            child: Stack(
              children: [
                FractionallySizedBox(
                  heightFactor: 0.7, // 70% of the height
                  widthFactor: 1.0, // Full width
                  child: NumberKeyboard(
                    onKeyTap: _onKeyTap,
                    onBackspace: _onBackspace,
                    onClear: _onClear,
                  ),
                ),
                Positioned(
                  bottom: 50, // 50 pixels from the bottom
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: 0.65, // 65% of the width
                      child: ElevatedButton(
                        onPressed: () {
                          createPaymentIntent();
                          // Add your charge action here
                        },
                        child: Text('Charge',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Urbanist'), ),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF29B6F6)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Close button at the top left
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close the screen
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26, // Circle color
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.close,
                    color: Colors.white, // X icon color
                    size: 24.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
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
    final formatter = NumberFormat.currency(
        locale: 'en_US', symbol: '${selectedCurrency.code}\$');
    String newText = formatter.format(value);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
