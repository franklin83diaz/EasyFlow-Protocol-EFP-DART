import 'dart:convert';
import 'dart:io';

import 'package:dart_efp/dart_efp.dart' as dart_efp;
import 'package:test/test.dart';

void main() {
  () async {
    print("server running");
    await Future.delayed(Duration(seconds: 1));
    // create server
    var server = await ServerSocket.bind(InternetAddress.anyIPv4, 3502);

    await for (var socket in server) {
      final efp = dart_efp.Efp(socket, dmtu: 500);
      final connsHandler = dart_efp.ConnsHandler();

      await Future.delayed(Duration(seconds: 1));

      final close = connsHandler.req("close", (data) {
        socket.close();
      });
      connsHandler.add(close);

      final login = dart_efp.ConnHandler("login", (data) {
        print("server process login");
        //Map data = jsonDecode(utf8.decode(data));
        if (data["user"] == "user01" && data["password"] == "MyPassword") {
          print(" login success");
        }
        //!TODO: send response with same tag
        // efp.send(utf8.encode('{"logged":true)'));
      });
      connsHandler.add(login);

      efp.receive(connsHandler);

      // final reqLogin = connsHandler.req("login", (data) {
      //   print(utf8.decode(data));
      // });
      // efp.send(
      //     utf8.encode('{"logged":true), reqLogin);
    }
  }();

  test('client port 3502', () async {
    print("client running");
    await Future.delayed(Duration(seconds: 1));
    final socket = await Socket.connect('127.0.0.1', 3502);

    final efp = dart_efp.Efp(socket, dmtu: 500);
    final connsHandler = dart_efp.ConnsHandler();

    //  efp.receive(connsHandler);
    await Future.delayed(Duration(seconds: 1));

    final reqLogin = connsHandler.req("login", (data) {
      print(utf8.decode(data));
    });
    efp.send(
        utf8.encode('{"user":"user01", "password": "MyPassword"}'), reqLogin);

    await Future.delayed(Duration(seconds: 5));
  });

  print("end");
}