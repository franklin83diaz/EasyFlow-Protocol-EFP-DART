part of "dart_efp.dart";

void sendData(Uint8List data, Tag tag, int idChannel, Socket conn, int dmtu) {
  final lengthData = data.length;

  /// 22 bytes for the header of Unit (id, tag, sizeData)
  // sizeData 3 bytes
  final bytesId = Uint8List(2);

  bytesId.buffer.asByteData().setInt16(0, idChannel, Endian.big);

  // tag 16 bytes
  final bytesTag = Uint8List(16);
  bytesTag.buffer.asUint8List().setAll(0, tag.valor.codeUnits);
  final bytesLengthData = Uint8List(4);
  bytesLengthData.buffer.asByteData().setInt32(0, lengthData, Endian.big);

  /// if is bigger
  if (lengthData > dmtu) {
    //split the data
    final listData = _splitData(data, dmtu);

    for (Uint8List data in listData) {
      bytesLengthData.buffer.asByteData().setInt32(0, data.length, Endian.big);
      //Write data to the socket
      var combinedData = Uint8List.fromList(
          [...bytesId, ...bytesTag, ...bytesLengthData, ...data]);

      conn.add(combinedData);
    }

    //send end channel
    var combinedData =
        Uint8List.fromList([...bytesId, ...bytesTag, ...Uint8List(4)]);
    conn.add(combinedData);

    ///if is normal
  } else {
    Uint8List combinedData = Uint8List.fromList(
        [...bytesId, ...bytesTag, ...bytesLengthData, ...data]);
    //Write data to the socket
    conn.add(combinedData);
    //send end channel
    final end = Uint8List.fromList([...bytesId, ...bytesTag, ...Uint8List(4)]);
    conn.add(end);
  }
}

List<Uint8List> _splitData(Uint8List data, int dmtu) {
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
