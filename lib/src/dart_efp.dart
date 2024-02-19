import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_efp/src/tags.dart';
import 'package:dart_efp/src/utils/tag_bytes_to_string.dart';

part 'receive.dart';
part 'send.dart';

/// This class is the main class of the library, it is responsible for managing
/// the connection channel and the tags.
/// The tags are used to identify the data that is being sent or received.
/// The maximum size of the tags is 16 bytes..
/// Data Maximum Transmission Unit (DMTU) is the maximum size of the data that
/// can be sent in. Always lee than 16,777,215.
/// The DMTU is defined by the user when creating the Efp object.
///
/// the communications use 2 bytes for the channel id, 16 bytes for the tag and
/// 3 bytes (16,777,215) for the data size.
///
///  id,    TAG                    ,  SIZE , DATA
/// _ _, _ _ _ _ _ _ _ _ _ _ _ _ _ , _ _ _ , AF02E...
///
/// Efp use 22 bytes for the header of Unit (id, tag, sizeData)
/// Split the data in parts of DMTU bytes and send it.this is for can send more
/// of data in the same time. using channels each channel can send a data with a
/// DMTU each time.
///
/// Example:
class Efp {
  final int dmtu;
  final Socket conn;
  //this number use 2 bytes max 65535
  int idChannel = 0;
  final buffer = BytesBuilder();

  Efp(this.conn, {this.dmtu = 15000000}) {
    if (dmtu > 15000000) {
      throw ArgumentError(
          'the DMTU exceeds the maximum size of 15,000,000 bytes.');
    }
  }

  /// Send data
  void send(Uint8List data, Tag tag) {
    idChannel++;
    if (idChannel > 65535) {
      idChannel = 1;
    }
    sendData(data, tag, idChannel, conn, dmtu);
  }

  //receive data
  void receive(Tags tags) {
    conn.listen((data) {
      receiveData(data, tags, buffer);
    }, onDone: () {
      print('Connection closed');
      conn.close();
    }, onError: (error) {
      print('Error: $error');
      conn.close();
    });
  }

  /// Close the connection
  void close() {
    conn.close();
  }
}
