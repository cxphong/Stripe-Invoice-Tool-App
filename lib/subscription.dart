import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Subscription extends StatefulWidget {
  final int selectedId;
  final int id;
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final void Function(int) onTap;

  const Subscription({
    Key? key,
    required this.id,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.text4,
    required this.onTap,
    required this.selectedId,
  }) : super(key: key);

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  Color _selectedBgColor = Colors.black;
  Color _selectedBorderColor = const Color(0xFF29B6F6);
  double _selectedBorderWidth = 3.0;
  Color _selectedTextColor = Colors.white;

  Color _unselectBgColor = Colors.black54;
  Color _unselectBorderColor = Colors.transparent;
  double _unselectBorderWidth = 0.0;
  Color _unselectTextColor = Colors.white54;

  @override
  Widget build(BuildContext context) {

    void _handleTap() {
      widget.onTap(widget.id);
    }

    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        // width: 400,  // Set the width to 150
        child: Container(
          decoration: BoxDecoration(
            color: (widget.selectedId == widget.id) ? _selectedBgColor : _unselectBgColor,
            border: Border.all(
              color: (widget.selectedId == widget.id) ? _selectedBorderColor : _unselectBorderColor, // Border color
              width: (widget.selectedId == widget.id) ? _selectedBorderWidth : _unselectBorderWidth, // Border width
            ),
            borderRadius: BorderRadius.circular(10.0), // Border radius
          ),
          child: Padding(
            padding: EdgeInsets.all(0.0),
            child: Column(
              children: [
                Padding(padding: EdgeInsets.all(8.0)),
                Text(
                  widget.text1,
                  style: TextStyle(
                    color: (widget.selectedId == widget.id) ? _selectedTextColor : _unselectTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Urbanist',
                  ),
                ),
                Text(
                  widget.text2,
                  style: TextStyle(
                    color: (widget.selectedId == widget.id) ? _selectedTextColor : _unselectTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                Text(
                  widget.text3,
                  style: TextStyle(
                    color: (widget.selectedId == widget.id) ? _selectedTextColor : _unselectTextColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                ),
                Text(
                  widget.text4,
                  style: TextStyle(
                    color: (widget.selectedId == widget.id) ? _selectedTextColor : _unselectTextColor,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Urbanist',
                  ),
                ),
                Padding(padding: EdgeInsets.all(8.0)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
