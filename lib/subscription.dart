import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class Subscription extends StatefulWidget {
  final int selectedId;
  final int id;
  final String text1;
  final String text2;
  final String text3;
  final String text4;
  final void Function(int) onTap;

  const Subscription({Key? key, required this.id, required this.text1, required this.text2, required this.text3, required this.text4, required this.onTap, required this.selectedId}) : super(key: key);

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  Color _selected_bgColor = Colors.black;
  Color _selected_borderColor = const Color(0xFF29B6F6);
  double _selected_borderWidth = 3.0;
  Color _selected_textColor = Colors.white;

  Color _unselect_bgColor = Colors.black54;
  Color _unselect_borderColor = Colors.transparent;
  double _unselect_borderWidth = 0.0;
  Color _unselect_textColor = Colors.white54;

  @override
  Widget build(BuildContext context) {

    void _handleTap() {
      widget.onTap(widget.id);
    }

    return GestureDetector(
        onTap: _handleTap,
        child: Container(
          // color: _bgColor,
          decoration: BoxDecoration(
            color: (widget.selectedId == widget.id) ? _selected_bgColor : _unselect_bgColor,
            border: Border.all(
              color: (widget.selectedId == widget.id) ? _selected_borderColor : _unselect_borderColor, // Border color
              width: (widget.selectedId == widget.id) ? _selected_borderWidth : _unselect_borderWidth, // Border width
            ),
            borderRadius: BorderRadius.circular(10.0), // Border radius
          ),
          child:  Padding(
            padding: EdgeInsets.all(.0),
            child: Column(children: [
              Padding(padding: EdgeInsets.all(8.0)),
              Text(widget.text1, style: TextStyle(color: (widget.selectedId == widget.id) ? _selected_textColor : _unselect_textColor, fontSize: 24, fontWeight: FontWeight.w800, fontFamily: 'Urbanist',)),
              Text(widget.text2, style: TextStyle(color: (widget.selectedId == widget.id) ? _selected_textColor : _unselect_textColor, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Urbanist',)),
              Padding(padding: EdgeInsets.all(8.0)),
              Text(widget.text3, style: TextStyle(color: (widget.selectedId == widget.id) ? _selected_textColor : _unselect_textColor, fontWeight: FontWeight.w600, fontFamily: 'Urbanist',)),
              Text(widget.text4, style: TextStyle(color: (widget.selectedId == widget.id) ? _selected_textColor : _unselect_textColor, fontWeight: FontWeight.w600, fontFamily: 'Urbanist',)),
              Padding(padding: EdgeInsets.all(8.0)),
            ]),
          ),
        ));
  }
}
