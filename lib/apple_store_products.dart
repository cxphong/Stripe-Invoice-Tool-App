import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:stripe_invoice/data.dart';
import 'package:stripe_invoice/renewal_transaction.dart';
import 'package:stripe_invoice/transaction.dart';

class AppleStoreProductManager {
  SharedData data = SharedData();
  RenewalTransaction? renewalTransaction;
  LastTransaction? lastTransaction;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> productDetails = [];
  static const List<String> _kIds = [
    'sub_1_month',
    'sub_12_months',
    'unlimited_subscription',
    'sub_6_months'
  ];

  static final AppleStoreProductManager _singleton =
      AppleStoreProductManager._internal();

  factory AppleStoreProductManager() {
    return _singleton;
  }

  AppleStoreProductManager._internal();

  Future<void> loadInappPurchase() async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_kIds.toSet());

    // Parse the productDetails and sort them by price
    List<ProductDetails> sortedProductDetails = response.productDetails;

    // Sort by price
    sortedProductDetails.sort((a, b) {
      final double priceA = _parsePrice(a.price);
      final double priceB = _parsePrice(b.price);
      return priceA.compareTo(priceB);
    });

    productDetails = sortedProductDetails;

    for (var value in productDetails) {
      print(value.description);
      print(value.price);
      print(value.title);
      print(value.currencyCode);
      print(value.currencySymbol);
      print(value.id);
      print(value.rawPrice);
    }
  }

  double _parsePrice(String price) {
    // Remove any non-numeric characters (like currency symbols) and parse the value as a double
    final sanitizedPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(sanitizedPrice) ?? 0.0;
  }

  Future<void> loadSubscriptionStatus() async {
    if (data.apple_user_identifier == null) return;

    // Replace with your API Gateway URL or Lambda URL
    final String apiUrl =
        'https://gkfk5rl009.execute-api.us-east-1.amazonaws.com/default/apple-store-verify-purchase';

    // Adding query parameters to the URL
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: {
      'apple_id': data.apple_user_identifier,
    });

    try {
      final http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print ('body = ${response.body}');
        // The response body is a JSON string, so we need to decode it
        final responseBody = jsonDecode(response.body);
        // print (responseBody);

        if (responseBody is List && responseBody.isNotEmpty) {
          print('Update successful: ${responseBody[0]}');
          print('Update successful: ${responseBody[1]}');

          renewalTransaction = RenewalTransaction.fromJson(responseBody[0]);

          print(renewalTransaction);
          // Parse the second object to Transaction
          lastTransaction = LastTransaction.fromJson(responseBody[1]);

          print(renewalTransaction?.originalTransactionId);
          print(lastTransaction?.originalTransactionId);
        } else {
          lastTransaction = LastTransaction.fromJson(responseBody);
        }
      } else {
        print('Failed to update. Status code: ${response.statusCode}');
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception caught: $e');
    }
  }
}
