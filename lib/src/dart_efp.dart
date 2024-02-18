import 'dart:io';
import 'dart:typed_data';

import 'package:dart_efp/src/tags.dart';

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

  Efp(this.conn, {this.dmtu = 15000000}) {
    if (dmtu > 15000000) {
      throw ArgumentError(
          'the DMTU exceeds the maximum size of 15,000,000 bytes.');
    }
  }

  List<Uint8List> _splitData(data) {
    final listData = <Uint8List>[];

    for (var i = 0; i < data.length; i += dmtu) {
      var end = i + dmtu;
      //check end for not exceed the length of data
      if (end > data.length) {
        end = data.length;
      }

      final chunk = data.sublist(i, end);
      listData.add(chunk);
    }

    return listData;
  }

  void send(Uint8List data, Tag tag) {
    final lengthData = data.length;

    /// 22 bytes for the header of Unit (id, tag, sizeData)
    // sizeData 3 bytes
    final bytesId = Uint8List(2);
    idChannel++;
    bytesId.buffer.asByteData().setInt16(0, idChannel, Endian.big);

    // tag 16 bytes
    final bytesTag = Uint8List(16);
    bytesTag.buffer.asUint8List().setAll(0, tag.valor.codeUnits);
    final bytesLengthData = Uint8List(4);
    bytesLengthData.buffer.asByteData().setInt32(0, lengthData, Endian.big);

    /// if is bigger
    if (lengthData > dmtu) {
      //split the data
      final listData = _splitData(data);
      bool isFirstUnit = true;
      for (Uint8List data in listData) {
        //Write data to the socket
        if (isFirstUnit) {
          var combinedData = Uint8List.fromList(
              [...bytesId, ...bytesTag, ...bytesLengthData, ...data]);

          conn.add(combinedData);
          isFirstUnit = false;
        } else {
          conn.add(data);
        }
      }

      ///if is normal
    } else {
      Uint8List combinedData = Uint8List.fromList(
          [...bytesId, ...bytesTag, ...bytesLengthData, ...data]);
      //Write data to the socket
      conn.add(combinedData);
    }
  }
}
