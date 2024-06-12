import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _email = '';
  bool _isLoading = false;
  String? _responseMessage;

  CardFieldInputDetails? _cardFieldInputDetails;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Stripe.publishableKey = "pk_test_51O5xFBIhRsa9dgl32CyqFayAJFdJcBEGR9pc7Q7lMWjw5IQFwayjgQBD1IEAqTJVzMXdANRjaR0OEJuQJTfZsxoF00HLUXe94w";
  }
  void _createPaymentMethod() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      _formKey.currentState?.save();

      try {
        // Create payment method
        final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(
                email: _email,
              ),
            ),
          ),
        );

        // Create a PaymentIntent directly using the Stripe API
        final response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          headers: {
            'Authorization': 'Bearer sk_test_51O5xFBIhRsa9dgl3u1xnl2lV2mh5L30UFrisv1PNEuGCusEolpPja0YMtmtrASfztwYTj8cM52tFmBbfI2BWoB9g00pHiff5vY', // Replace with your Stripe secret key
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {
            'amount': '1000', // Example amount in cents
            'currency': 'usd',
            'payment_method': paymentMethod.id,
            // 'confirmation_method': 'auto',
            'confirm': 'true',
            'receipt_email': _email,
            'return_url': "https://google.com",
            'automatic_payment_methods[enabled]': 'true'
          },
        );

        print (response.body);
        final responseBody = json.decode(response.body);
        final clientSecret = responseBody['client_secret'];

        // Confirm the payment
        await Stripe.instance.confirmPayment(
          paymentIntentClientSecret: clientSecret,
          data: PaymentMethodParams.card(
            paymentMethodData: PaymentMethodData(
              billingDetails: BillingDetails(
                email: _email,
              ),
            ),
          ),
        );

        setState(() {
          _responseMessage = 'Payment successful!';
        });
      } catch (e) {
        setState(() {
          _responseMessage = 'Payment failed: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CardField(
                onCardChanged: (card) {
                  setState(() {
                    _cardFieldInputDetails = card;
                  });
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _createPaymentMethod,
                child: Text('Pay'),
              ),
              if (_responseMessage != null) ...[
                SizedBox(height: 20),
                Text(_responseMessage!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
