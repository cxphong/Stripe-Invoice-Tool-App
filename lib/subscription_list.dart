import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'subscription.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class SubscriptionList extends StatefulWidget {
  int selectedId;
  final void Function(int) onTap;
  final List<ProductDetails> productDetails;

  SubscriptionList({
    Key? key,
    required this.selectedId,
    required this.onTap,
    required this.productDetails,
  }) : super(key: key);

  @override
  State<SubscriptionList> createState() => _SubscriptionListState();
}

class _SubscriptionListState extends State<SubscriptionList> {

  @override
  Widget build(BuildContext context) {
    print('product length =  ${widget.productDetails.length}');

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 150.0, // Set a fixed height for the Subscription widgets
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: widget.productDetails.map((productDetail) {
                  int index = widget.productDetails.indexOf(productDetail);
                  return Container(
                    width: 125.0, // Fixed width for each Subscription widget
                    margin: EdgeInsets.only(right: 8.0), // Space between items
                    child: Subscription(
                      id: index,
                      text1: _getText1(productDetail),
                      text2: _getText2(productDetail),
                      text3: productDetail.price,
                      text4: _getText4(productDetail),
                      onTap: widget.onTap,
                      selectedId: widget.selectedId,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  _getPlanDescription(widget.selectedId),
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getText1(ProductDetails productDetail) {
    // Custom logic to extract text1 from productDetail
    return productDetail.title.split(" ")[0]; // Example
  }

  String _getText2(ProductDetails productDetail) {
    // Custom logic to extract text2 from productDetail
    return productDetail.title; // Example
  }

  String _getText4(ProductDetails productDetail) {
    // Custom logic to extract text4 (description) from productDetail
    return "Best deal"; // Example, you can customize based on productDetail
  }

  String _getPlanDescription(int id) {
    // Custom logic to generate plan description
    switch (id) {
      case 0:
        return 'Monthly renewal with the flexibility to cancel anytime.';
      case 1:
        return "6-month renewal with the option to cancel anytime.";
      case 2:
        return 'Yearly renewal with the flexibility to cancel anytime.';
      case 3:
        return 'One-time payment with no recurring charges.';
      default:
        return "";
    }
  }
}
