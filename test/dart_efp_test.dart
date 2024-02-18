import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_efp/dart_efp.dart' as dart_efp;
import 'package:test/test.dart';

void main() {
  group('Tags', () {
    test('addTag', () {
      final tags = dart_efp.Tags();
      final tag = dart_efp.Tag('tag01');
      expect(tags.addTag(tag), isTrue);
      expect(tags.addTag(tag), isFalse);
    });

    test('Get new Tag', () {
      final tags = dart_efp.Tags();
      final tag = tags.getNewTag();
      expect(tags.addTag(tag), isFalse);
      print(tag);
    });

    test('send Data', () async {
      serverTest();
      await Future.delayed(Duration(seconds: 1));
      final socket = await Socket.connect('127.0.0.1', 3500);

      dart_efp.Efp efp = dart_efp.Efp(socket, dmtu: 5000);
      efp.send(utf8.encode('{"status":"ok"}'), dart_efp.Tag('tag01'));
      efp.send(utf8.encode('{"status":"ok2"}'), dart_efp.Tag('tag002'));
      await Future.delayed(Duration(seconds: 1));
      efp.send(utf8.encode('{"status":"ok3"}'), dart_efp.Tag('tag003'));
      await Future.delayed(Duration(seconds: 5));
    });
  });
}

Future<void> serverTest() async {
  // Create a server socket that listens on a specified IP address and port.
  var server = await ServerSocket.bind(InternetAddress.anyIPv4, 3500);
  print('Server Running on Port: ${server.port}...');
  // Create a BytesBuilder and add the incoming data to it
  final buffer = BytesBuilder();
  await for (var socket in server) {
    print('Client connected: ${socket.remoteAddress}:${socket.remotePort}');
    // listen for incoming connections
    //create buffer for the data

    socket.listen((data) {
      //print console text color green
      print('\x1B[32m');
      print(utf8.decode(data));
      print('\x1B[0m');
      // Add the incoming data to the buffer

      buffer.add(data);

      // header is complete 22 bytes
      while (buffer.length > 22) {
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

        //Print the header
        print("id Channel: $idChannel");
        print("tag: ${utf8.decode(tagBytes)}");
        print("length Data: $lengthData");

        //set the total length of the message
        int start = 22;
        int totalLengthData = start + lengthData;

        // check if the buffer has enough data to process
        if (availableData.length >= totalLengthData) {
          // decode the message
          var message =
              utf8.decode(availableData.sublist(start, totalLengthData));

          if (lengthData == 0 && message.isEmpty) {
            print('End of Channel $idChannel');
          } else {
            print('Data Received: $message');
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
    },
        // handle errors
        onError: (error) {
      print('Error: $error');
    },
        // close the socket when the connection is done
        onDone: () {
      print('Client disconnected');
      socket.close();
    });
  }
}
