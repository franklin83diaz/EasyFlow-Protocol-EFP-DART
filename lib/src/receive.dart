part of "dart_efp.dart";

void receiveData(Uint8List data, Tags tags, BytesBuilder buffer) {
  //print console text color blue
  print('\x1B[34m');
  print(utf8.decode(data));
  print('\x1B[0m');

  buffer.add(data);

  // header is complete 22 bytes
  while (buffer.length >= 22) {
    // Convert the buffer to a list of bytes
    var availableData = buffer.toBytes();
    // if is header print the header

    // extract the header
    final idBytes = availableData.sublist(0, 2);
    final tagBytes = availableData.sublist(2, 18);
    final lengthBytes = availableData.sublist(18, 22);
    final int idChannel = Uint8List.fromList(idBytes)
        .buffer
        .asByteData()
        .getUint16(0, Endian.big);
    final int lengthData = Uint8List.fromList(lengthBytes)
        .buffer
        .asByteData()
        .getUint32(0, Endian.big);
    final tagValue = tagBytesToString(tagBytes);

    //Print the header
    print("id Channel: $idChannel");
    print("tag: ${utf8.decode(tagBytes)}");
    print("length Data: $lengthData");

    Tag tag = tags.tags.firstWhere((element) => element.valor == tagValue,
        orElse: () => Tag('', () {}));
    if (tag.valor == '') {
      print('Tag not found: $tagValue');
      print("in List: ${tags.tags}");
    }

    //set the total length of the message
    int start = 22;
    int totalLengthData = start + lengthData;

    // check if the buffer has enough data to process
    if (availableData.length >= totalLengthData) {
      if (lengthData == 0) {
        //  print('End of Channel $idChannel');
        tag.function(tag.data);
      } else {
        tag.data.addAll(availableData.sublist(start, totalLengthData));
      }

      // remove the processed message from the buffer
      buffer.clear();
      if (availableData.length > totalLengthData) {
        buffer.add(availableData.sublist(totalLengthData));
      }
    } else {
      //need to wait for more data
      break;
    }
  }
}
