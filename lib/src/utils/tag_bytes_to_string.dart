import 'dart:convert';
import 'dart:typed_data';

/// Convert tag bytes to string
/// remove all null bytes (0)
///
/// Example:
/// ```dart
/// final tag = tagBytesToString(Uint8List.fromList([116, 101, 115, 116, 0, 0, 0, 0]));
/// print(tag); // test
/// ```
///
tagBytesToString(Uint8List tagBytes) {
  //remove null bytes
  return utf8.decode(tagBytes).replaceAll(RegExp(r'\x00'), '');
}

/// Remove null bytes from string
/// remove all null bytes (0)
///
/// Example:
/// ```dart
/// final tag = removeNull('test\x00\x00\x00\x00');
/// print(tag); // test
/// ```
///
removeNull(String s) {
  //remove null bytes
  return s.replaceAll(RegExp(r'\x00'), '');
}
