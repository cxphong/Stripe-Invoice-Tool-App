import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:stripe_invoice/apple_store_products.dart';
import 'package:stripe_invoice/apps.dart';
import 'package:stripe_invoice/data.dart';
import 'package:stripe_invoice/demo_manager.dart';
import 'package:stripe_invoice/progress_dialog.dart';
import 'package:stripe_invoice/stripe_connect_page.dart';
import 'package:stripe_invoice/subscription.dart';
import 'package:stripe_invoice/subscription_list.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late int selectedId;
  SharedData data = SharedData();
  bool processingPurchase = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      if (processingPurchase) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }
    });
    selectedId = 1;
    // loadInappPurchase();
    _completePendingTransactions();
  }

  Future<void> _completePendingTransactions() async {
    final Stream<List<PurchaseDetails>> purchaseStream =
        _inAppPurchase.purchaseStream;
    final List<PurchaseDetails> pendingPurchases = await purchaseStream.first;

    for (PurchaseDetails purchase in pendingPurchases) {
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
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
    final String apiUrl =
        'https://8n5whw25p0.execute-api.us-east-1.amazonaws.com/default/stripe-admin-apple-users';

    final Map<String, dynamic> requestBody = {
      'apple_id': SharedData().apple_user_identifier, //appleId,
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

  ProductDetails? retrieveSelectedProduct() {
    return AppleStoreProductManager().productDetails[selectedId];
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (var i = 0; i < purchaseDetailsList.length; i++) {
      PurchaseDetails purchaseDetails = purchaseDetailsList[i];

      print(purchaseDetails.status);

      // Mark the purchase as pending and add it to the processed set
      if (purchaseDetails.status == PurchaseStatus.pending) {
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          setState(() {
            processingPurchase = false;
          });
          // Handle the error if necessary
          // _handleError(purchaseDetails.error!);
          // hideProgress(context);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await postPurchaseVerification(purchaseDetails);

          if (valid) {
            await AppleStoreProductManager().loadSubscriptionStatus();

            if (DemoManager().demo) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const StripeConnectPage()),
              );
            } else {
              if (SharedData().stripe_access_key.isEmpty) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const StripeConnectPage()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyHomePage()),
                );
              }
            }
          } else {
            // Handle invalid purchase
            // _handleInvalidPurchase(purchaseDetails);
          }

          // hideProgress(context);
          setState(() {
            processingPurchase = false;
          });
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          setState(() {
            processingPurchase = false;
          });
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void showProgress(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const ProgressDialog(message: "Processing ...");
      },
    );
  }

  void hideProgress(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<bool> postPurchaseVerification(PurchaseDetails purchaseDetails) async {
    final url = Uri.parse(
        'https://gkfk5rl009.execute-api.us-east-1.amazonaws.com/default/apple-store-verify-purchase');

    // Body content
    final body = jsonEncode(
        {"receipt": purchaseDetails.verificationData.serverVerificationData});

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
      final String? originalTransactionId =
          responseBody['originalTransactionId'];
      if (originalTransactionId != null) {
        await updateOriginalTransactionId(
            appleId: data.apple_user_identifier,
            originalTransactionId: originalTransactionId);
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
            color: Colors.white,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.2), // Add some top padding if needed
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "A subscription is needed to use this app—no free version is offered. Start with a 7-day trial, cancel anytime.",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 18,
                        color: const Color(0xFF29B6F6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  RichText(
                    text: TextSpan(
                      text: 'Term of use',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          const url =
                              "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/";
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8.0)),
                  RichText(
                    text: TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          const url =
                              "https://stripeinvoice-app-public.s3.amazonaws.com/stripeinvoice-privacy-policy.html";
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            throw 'Could not launch $url';
                          }
                        },
                    ),
                  ),

                  Padding(padding: EdgeInsets.all(24.0)),
                  SubscriptionList(
                    selectedId: selectedId,
                    onTap: onTap,
                    productDetails: AppleStoreProductManager().productDetails,
                  ),
                  Padding(padding: EdgeInsets.all(24.0)),
                  FractionallySizedBox(
                    widthFactor: 0.65, // 65% of the width
                    child: ElevatedButton(
                      onPressed: () {
                        ProductDetails? product = retrieveSelectedProduct();

                        if (product != null) {
                          setState(() {
                            processingPurchase = true;
                          });

                          final PurchaseParam purchaseParam =
                              PurchaseParam(productDetails: product);
                          _inAppPurchase.buyConsumable(
                              purchaseParam: purchaseParam);
                        }
                      },
                      child: Text(
                        'SUBSCRIBE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF29B6F6)),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height *
                          0.2), // Add some bottom padding if needed
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
