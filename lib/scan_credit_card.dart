// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:iz_scan/iz_scan.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_stripe/flutter_stripe.dart';
//
// class CreditCardScanScreen extends StatefulWidget {
//   late String clientSecretKey;
//
//   CreditCardScanScreen({Key? key, required this.clientSecretKey}) : super(key: key);
//
//   @override
//   _CreditCardScanScreenState createState() => _CreditCardScanScreenState();
// }
//
// class _CreditCardScanScreenState extends State<CreditCardScanScreen> {
//   String cardNumber = '';
//   String expiryMonth = '';
//   String expiryYear = '';
//   String cardHolderName = '';
//   String cvvCode = '';
//   String _amount = '';
//
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   String _email = '';
//   bool _isLoading = false;
//   String? _responseMessage;
//
//   final ValueNotifier<bool> _isScanning = ValueNotifier(true);
//   late StreamSubscription _streamSubscription;
//   CardFormEditController _cardEditController = CardFormEditController();
//
//   Key _cardFieldKey = UniqueKey(); // Add a key to force rebuild
//   late String clientSecret;
//
//   @override
//   void initState() {
//     super.initState();
//
//     clientSecret = widget.clientSecretKey;
//     print (clientSecret);
//     Stripe.publishableKey = "pk_live_51PfJoiKzGGJ2LnDpdgAgNmhbjOyBo18Nsyuw97NlADNa6Pp4jJfTiA1Vq8qkFdnUrbGZyF93xB6wvUUKwpYa5yhp00j1weFcK9";
//     Stripe.instance.initPaymentSheet(paymentSheetParameters: SetupPaymentSheetParameters(
//       // Set to true for custom flow
//       customFlow: false,
//       // Main params
//       paymentIntentClientSecret: clientSecret,
//       merchantDisplayName: 'Flutter Stripe Store Demo',
//       // Extra options
//       // applePay: const PaymentSheetApplePay(
//       //   merchantCountryCode: 'US',
//       // ),
//       // googlePay: const PaymentSheetGooglePay(
//       //   merchantCountryCode: 'US',
//       //   testEnv: true,
//       // ),
//       style: ThemeMode.dark,
//     ));
//
//      Stripe.instance.presentPaymentSheet();
//     _streamSubscription = IZScan.cardScanStream.listen(
//           (cardStreamInfo) {
//         if (cardStreamInfo != null) {
//           setState(() {
//             cardNumber = cardStreamInfo.number!;
//             expiryMonth = cardStreamInfo.expiryMonth!;
//             expiryYear = cardStreamInfo.expiryDate!;
//             cvvCode = '';
//
//             // Create a new controller with the updated details
//             _cardEditController = CardFormEditController(
//               initialDetails: CardFieldInputDetails(
//                 number: cardNumber,
//                 expiryMonth: int.parse(expiryMonth),
//                 expiryYear: int.parse(expiryYear),
//                 cvc: "",
//                 complete: false,
//               ),
//             );
//
//             // Generate a new key to force the CardField widget to rebuild
//             _cardFieldKey = UniqueKey();
//           });
//           _isScanning.value = false;
//         }
//       },
//       onError: (error) {
//         if (kDebugMode) {
//           print('Error during card scan: $error');
//         }
//       },
//     );
//   }
//
//   Future<void> _startCardScan() async {
//     await Stripe.instance.presentPaymentSheet();
//     // try {
//     //   await IZScan.startCardScan();
//     // } catch (error) {
//     //   if (kDebugMode) {
//     //     print('Error starting card scan: $error');
//     //   }
//     // }
//   }
//
//   void _createPaymentMethod() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       setState(() {
//         _isLoading = true;
//       });
//
//       _formKey.currentState?.save();
//
//       try {
//         print (PaymentMethodParams.card(
//             paymentMethodData: PaymentMethodData(
//           // billingDetails: BillingDetails(
//           //   email: _email,
//           // ),
//         )));
//
//         // Create payment method
//         final paymentMethod = await Stripe.instance.createPaymentMethod(
//           params: const PaymentMethodParams.card(
//             paymentMethodData: PaymentMethodData(
//               // billingDetails: BillingDetails(
//               //   email: _email,
//               // ),
//             ),
//           ),
//         );
//
//         print(_amount);
//         // Create a PaymentIntent directly using the Stripe API
//         final response = await http.post(
//           Uri.parse('https://api.stripe.com/v1/payment_intents'),
//           headers: {
//             'Authorization': 'Bearer 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', // Replace with your Stripe secret key
//             'Content-Type': 'application/x-www-form-urlencoded',
//           },
//           body: {
//             'amount': (int.parse(_amount)*100).toString(), // Use the amount entered by the user
//             'currency': 'usd',
//             'payment_method': paymentMethod.id,
//             'confirm': 'true',
//             'return_url': "https://google.com",
//             'automatic_payment_methods[enabled]': 'true'
//           },
//         );
//
//         final responseBody = json.decode(response.body);
//         final clientSecret = responseBody['client_secret'];
//
//         print(responseBody);
//         // Confirm the payment
//         await Stripe.instance.confirmPayment(
//           paymentIntentClientSecret: clientSecret,
//           data: PaymentMethodParams.card(
//             paymentMethodData: PaymentMethodData(
//               // billingDetails: BillingDetails(
//               //   email: _email,
//               // ),
//             ),
//           ),
//         );
//
//         setState(() {
//           _responseMessage = 'Payment successful!';
//         });
//       } catch (e) {
//         setState(() {
//           _responseMessage = 'Payment failed: $e';
//         });
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   // @override
//   // void dispose() {
//   //   _streamSubscription.cancel();
//   //   _cardEditController.dispose(); // Dispose of the controller
//   //   super.dispose();
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create Payment'),
//       ),
//       body: ValueListenableBuilder<bool>(
//         valueListenable: _isScanning,
//         builder: (context, isScanning, child) {
//           return SingleChildScrollView(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         ElevatedButton(onPressed: _startCardScan, child: Text("Scan")),
//                         TextFormField(
//                           decoration: InputDecoration(labelText: 'Amount'),
//                           keyboardType: TextInputType.number,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter an amount';
//                             }
//                             return null;
//                           },
//                           onSaved: (value) {
//                             _amount = value!;
//                           },
//                         ),
//                         SizedBox(height: 20),
//                         CardFormField(
//                           controller: _cardEditController,
//                           dangerouslyGetFullCardDetails: true,
//                           dangerouslyUpdateFullCardDetails: true,
//                           key: _cardFieldKey, // Force rebuild with a unique key
//                           onCardChanged: (card) {
//                             setState(() {
//                               // Update the state with card information
//                             });
//                           },
//                           style: CardFormStyle(
//                             borderColor: Colors.black,
//                             backgroundColor: Colors.black,
//                             textColor: Colors.black,
//                             borderRadius: 8,
//                             placeholderColor: Colors.grey[400],
//                             textErrorColor: Colors.red,
//                           ),
//                         ),
//                         SizedBox(height: 20),
//                         _isLoading
//                             ? CircularProgressIndicator()
//                             : ElevatedButton(
//                           onPressed: _createPaymentMethod,
//                           child: Text('Pay'),
//                         ),
//                         if (_responseMessage != null) ...[
//                           SizedBox(height: 20),
//                           Text(_responseMessage!),
//                         ],
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
