import 'package:flutter/material.dart';

class NumberKeyboard extends StatelessWidget {
  final Function(String) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  NumberKeyboard({
    required this.onKeyTap,
    required this.onBackspace,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF424242),
      // padding: EdgeInsets.all(10),
      child: Column(
        children: [
          buildNumberRow(['1', '2', '3']),
          buildNumberRow(['4', '5', '6']),
          buildNumberRow(['7', '8', '9']),
          buildNumberRow(['x', '0', '<']),
        ],
      ),
    );
  }

  Widget buildNumberRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: values.map((value) {
        return Expanded(
            child: ElevatedButton(
          onPressed: () {
            if (value == 'x') {
              onClear();
            } else if (value == '<') {
              onBackspace();
            } else {
              onKeyTap(value);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0, // Flat style with no elevation
            padding: EdgeInsets.all(25), // No padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // No rounded corners
            ),
          ),
          child: Text(
            value,
            style: (value == 'x' || value == '<' ) ? TextStyle(fontSize: 24, color: Colors.blueGrey) : TextStyle(fontSize: 24, color: const Color(0xFF29B6F6)),
          ),
        ));
        // Padding(
        // padding: const EdgeInsets.all(8.0),

        // );
      }).toList(),
    );
  }
}
