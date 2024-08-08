import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:stripe_invoice/subscription.dart';
import 'package:stripe_invoice/subscription_list.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late List<ProductDetails> productDetails;

  @override
  void initState() {
    // TODO: implement initState
    _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    });

    loadInappPurchase();
    super.initState();
  }

  void loadInappPurchase() async {
    print(await _inAppPurchase.isAvailable());
    const Set<String> _kIds = <String>{'one_time', '1_month_subscription'};
    final ProductDetailsResponse response =
    await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      // Handle the error.
      print("not found");
    }

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
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      print(purchaseDetails.status);
      print(purchaseDetails.pendingCompletePurchase);
      print(purchaseDetails.productID);
      print(purchaseDetails.purchaseID);
      print(purchaseDetails.transactionDate);
      print(purchaseDetails.verificationData.serverVerificationData);

      if (purchaseDetails.status == PurchaseStatus.pending) {
        // _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            // _deliverProduct(purchaseDetails);
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

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
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
                Text(
                  'Start your free 7 days trial',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 24,
                    color: const Color(0xFF29B6F6),
                  ),
                ),
                Padding(padding: EdgeInsets.all(24.0)),
                SubscriptionList(),
                Padding(padding: EdgeInsets.all(24.0)),
                FractionallySizedBox(
                  widthFactor: 0.65, // 65% of the width
                  child: ElevatedButton(
                    onPressed: () {
                      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails[1]);
                      _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
                    },
                    child: Text(
                      'SUBSCRIBE',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Urbanist',),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF29B6F6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50.0,
            left: 20.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop(); // Close the screen
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26, // Circle color
                ),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
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
    );
  }
}
