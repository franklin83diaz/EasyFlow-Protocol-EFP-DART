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

      final close = connsHandler.req("close", (data, tag) {
        socket.close();
      });
      connsHandler.add(close);

      final login = dart_efp.ConnHandler("login", (data, tag) {
        print("server process login");
        Map d = jsonDecode(utf8.decode(data));
        if (d["user"] == "user01" && d["password"] == "MyPassword") {
          print(" login success");
          print("originalTag: $tag");
          efp.send(utf8.encode('{"logged":true)'), tag);
        }
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

    //process data from server
    efp.receive(connsHandler);

    //  efp.receive(connsHandler);
    await Future.delayed(Duration(seconds: 1));

    //!TODO: do not work
    final reqLogin = connsHandler.req("login", (data, tag) {
      print("Client:  ${utf8.decode(data)}");
    });
    print("All Handler: ${connsHandler.getAll}");
    efp.send(utf8.encode('{"user":"user01", "password": "MyPassword"}'),
        reqLogin.tag,
        typeData: 1);

    await Future.delayed(Duration(seconds: 5));
  });

  print("end");
}
