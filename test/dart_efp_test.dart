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

      dart_efp.Efp efp = dart_efp.Efp(socket);
      efp.send(utf8.encode('{"status":"ok"}'), dart_efp.Tag('tag01'));
      await Future.delayed(Duration(seconds: 5));
    });
  });
}

Future<void> serverTest() async {
  // Create a server socket that listens on a specified IP address and port.
  var server = await ServerSocket.bind(InternetAddress.anyIPv4, 3500);
  print('Server Running on Port: ${server.port}...');

  await for (var socket in server) {
    print('Client connected: ${socket.remoteAddress}:${socket.remotePort}');
    // listen for incoming connections
    socket.listen((data) {
      final idBytes = data.sublist(0, 2);
      final lengthBytes = data.sublist(18, 22);

      final int recoveredIdChannel =
          idBytes.buffer.asByteData().getUint16(0, Endian.big);
      print("id Channel: $recoveredIdChannel");

      final int recoveredLengthData =
          lengthBytes.buffer.asByteData().getUint32(0, Endian.big);
      print("length Data: $recoveredLengthData");

      // decode the incoming data
      var message = utf8.decode(data);
      print('Data Received: $message');
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
