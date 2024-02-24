import 'dart:convert';
import 'dart:io';

import 'package:dart_efp/dart_efp.dart' as dart_efp;
import 'package:test/test.dart';

void main() {
  () async {
    print("server running");
    await Future.delayed(Duration(seconds: 1));
    // create server
    var server = await ServerSocket.bind(InternetAddress.anyIPv4, 3503);

    await for (var socket in server) {
      final efp = dart_efp.Efp(socket, dmtu: 500);
      final connsHandler = dart_efp.ConnsHandler();

      await Future.delayed(Duration(seconds: 1));

      final login = dart_efp.ConnHandler("history", (connHandler, tag) async {
        bool cancel = false;
        connHandler.cancel.stream.listen((event) {
          cancel = true;
        });

        await Future.delayed(Duration(seconds: 5));

        if (cancel) {
          print("process canceled");
        } else {
          print("processed");
        }
      });
      connsHandler.add(login);

      efp.receive(connsHandler);
    }
  }();

  test('client port 3503', () async {
    print("client running");
    await Future.delayed(Duration(seconds: 1));
    final socket = await Socket.connect('127.0.0.1', 3503);

    final efp = dart_efp.Efp(socket, dmtu: 500);
    final connsHandler = dart_efp.ConnsHandler();

    //process data from server
    efp.receive(connsHandler);

    //  efp.receive(connsHandler);
    await Future.delayed(Duration(seconds: 1));

    final reqHistory = connsHandler.req("history", (connHandler, tag) {
      //data history
    });

    efp.send(utf8.encode('{"start":0, "end": 999999999}'), reqHistory.tag,
        action: 1);
    //cencel history
    await Future.delayed(Duration(seconds: 2));
    efp.send(utf8.encode('canceled'), reqHistory.tag, action: 3);

    await Future.delayed(Duration(seconds: 10));
  });

  print("end");
}
