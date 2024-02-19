import 'dart:convert';
import 'dart:typed_data';

tagBytesToString(Uint8List tagBytes) {
  return utf8.decode(tagBytes).replaceAll(RegExp(r'\x00'), '');
}
