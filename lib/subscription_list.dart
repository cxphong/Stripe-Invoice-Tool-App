import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'subscription.dart';

class SubscriptionList extends StatefulWidget {
  int selectedId;
  final void Function(int) onTap;

  SubscriptionList({Key? key, required this.selectedId, required this.onTap}) : super(key: key);

  @override
  State<SubscriptionList> createState() => _SubscriptionListState();
}

class _SubscriptionListState extends State<SubscriptionList> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  String getPlanDescription(int id) {
    switch (id) {
      case 0:
        return 'Monthly renewal with the flexibility to cancel anytime.';
      case 1:
        return 'Yearly renewal with the flexibility to cancel anytime.';
      case 2:
        return 'One-time payment with no recurring charges.';
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    String planDescription = getPlanDescription(widget.selectedId);

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 150.0, // Set a fixed height for the Subscription widgets
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: double.infinity, // Ensure full height
                    child: Subscription(
                      id: 0,
                      text1: "1",
                      text2: "MONTH",
                      text3: "\$19.99",
                      text4: "\$4.6 per week",
                      onTap: widget.onTap,
                      selectedId: widget.selectedId,
                    ),
                  ),
                ),
                SizedBox(width: 4.0),
                Expanded(
                  child: Container(
                    height: double.infinity, // Ensure full height
                    child: Subscription(
                      id: 1,
                      text1: "12",
                      text2: "MONTHS",
                      text3: "\$199",
                      text4: "\$3.8 per week",
                      onTap: widget.onTap,
                      selectedId: widget.selectedId,
                    ),
                  ),
                ),
                SizedBox(width: 4.0),
                Expanded(
                  child: Container(
                    height: double.infinity, // Ensure full height
                    child: Subscription(
                      id: 2,
                      text1: "∞",
                      text2: "UNLIMITED",
                      text3: "\$499",
                      text4: "Best saving",
                      onTap: widget.onTap,
                      selectedId: widget.selectedId,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              color: Colors.black,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  planDescription,
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
}
