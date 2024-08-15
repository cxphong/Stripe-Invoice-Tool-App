import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:stripe_invoice/apps.dart';
import 'package:stripe_invoice/data.dart';
import 'package:stripe_invoice/subscription.dart';
import 'package:stripe_invoice/subscription_list.dart';
import 'package:http/http.dart' as http;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> productDetails = [];
  late int selectedId;
  static const List<String> _kIds = ['sub_1_month', 'sub_12_months', 'unlimited'];
  SharedData data = SharedData();

  @override
  void initState() {
    // TODO: implement initState
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    });
    selectedId = 1;
    loadInappPurchase();
    super.initState();
  }

  void onTap(int id) {
    setState(() {
      selectedId = id;
    });
  }

  Future<void> updateOriginalTransactionId({
    required String appleId,
    required String originalTransactionId,
  }) async {
    // Replace with your API Gateway URL or Lambda URL
    final String apiUrl = 'https://8n5whw25p0.execute-api.us-east-1.amazonaws.com/default/stripe-admin-apple-users';

    final Map<String, dynamic> requestBody = {
      'apple_id': "001818.21b0770e1602420788aa4ce5a89bccee.0848", //appleId,
      'original_transaction_id': originalTransactionId,
    };

    try {
      final http.Response response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        // The response body is a JSON string, so we need to decode it
        final responseBody = jsonDecode(response.body);

        // Access the "message" and "originalTransactionId" fields
        // final String message = responseBody['message'];
        // final String updatedTransactionId = responseBody['updatedAttributes']['originalTransactionId'];

        print('Update successful: $responseBody');
        // print('Updated originalTransactionId: $updatedTransactionId');
      } else {
        print('Failed to update. Status code: ${response.statusCode}');
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }


  void loadInappPurchase() async {
    final ProductDetailsResponse response =
    await _inAppPurchase.queryProductDetails(_kIds.toSet());

    print (response.productDetails);
    // if (response.notFoundIDs.isNotEmpty) {
    //   // Handle the error.
    //   print("not found");
    // }

    setState(() {
      // print (response.notFoundIDs);
      productDetails = response.productDetails;
      for (var value in response.productDetails) {
        print(value.description);
        print(value.price);
        print(value.title);
        print(value.currencyCode);
        print(value.currencySymbol);
        print(value.id);
        print(value.rawPrice);
      }
    });

  }

  ProductDetails? retrieveSelectedProduct() {
    for (var value in productDetails) {
      if (_kIds[selectedId] == value.id) {
        return value;
      }
    }

    return null;
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      // print(purchaseDetails.status);
      // print(purchaseDetails.pendingCompletePurchase);
      // print(purchaseDetails.productID);
      // print(purchaseDetails.purchaseID);
      // print(purchaseDetails.transactionDate);
      // print(purchaseDetails.verificationData.serverVerificationData);

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await postPurchaseVerification(purchaseDetails);
          if (valid) {
            // _deliverProduct(purchaseDetails);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
          } else {
            // _handleInvalidPurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance
              .completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<bool> postPurchaseVerification(PurchaseDetails purchaseDetails) async {
    final url = Uri.parse('https://gkfk5rl009.execute-api.us-east-1.amazonaws.com/default/apple-store-verify-purchase');

    // Body content
    final body = jsonEncode({
      "receipt": purchaseDetails.verificationData.serverVerificationData
    });

    // POST request
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // Check the response
    if (response.statusCode == 200) {
      // Request was successful
      print('Response data: ${response.body}');
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Replace 'fieldName' with the actual field name you want to retrieve
      final String? originalTransactionId = responseBody['originalTransactionId'];
      if (originalTransactionId != null) {
        await updateOriginalTransactionId(appleId:  data.apple_user_identifier, originalTransactionId: originalTransactionId);
      }

      return true;
    } else {
      // Handle error
      print('Failed to post data. Status code: ${response.statusCode}');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            // Ensures the container takes up the full width
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Text("Length = ${selectedId}"),
                Text(
                  'Your free 7 days trial has ended',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 24,
                    color: const Color(0xFF29B6F6),
                  ),
                ),
                Padding(padding: EdgeInsets.all(24.0)),
                SubscriptionList(selectedId: selectedId, onTap: onTap),
                Padding(padding: EdgeInsets.all(24.0)),
                FractionallySizedBox(
                  widthFactor: 0.65, // 65% of the width
                  child: ElevatedButton(
                    onPressed: () {
                      ProductDetails? product = retrieveSelectedProduct();

                      if (product != null) {
                        final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
                        _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
                      }

                      // loadInappPurchase();
                    },
                    child: Text(
                      'SUBSCRIBE',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Urbanist',),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29B6F6)
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Positioned(
          //   top: 50.0,
          //   left: 20.0,
          //   child: GestureDetector(
          //     onTap: () {
          //       Navigator.of(context).pop(); // Close the screen
          //     },
          //     child: Container(
          //       decoration: const BoxDecoration(
          //         shape: BoxShape.circle,
          //         color: Colors.black26, // Circle color
          //       ),
          //       child: const Padding(
          //         padding: EdgeInsets.all(8.0),
          //         child: Icon(
          //           Icons.close,
          //           color: Colors.white, // X icon color
          //           size: 24.0,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
