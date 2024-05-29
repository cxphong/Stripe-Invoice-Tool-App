
import 'dart:convert';

String decodeText(String encodedText) {
  // Decode the text using UTF-8 encoding
  return utf8.decode(encodedText.runes.toList());
}