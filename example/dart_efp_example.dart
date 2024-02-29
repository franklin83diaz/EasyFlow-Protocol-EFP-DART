import 'dart:convert';
import 'dart:io';

import 'package:dart_efp/dart_efp.dart';

void main() async {
  server();
  await Future.delayed(Duration(seconds: 1));
  client();
}

//server
void server() async {
  print("Running server");
  await Future.delayed(Duration(seconds: 1));
  // create server
  var server = await ServerSocket.bind(InternetAddress.anyIPv4, 3000);

  await for (var socket in server) {
    //Create the Efp
    final efp = Efp(socket);

    // The ConnsHandler is where all the ConnHandlers will be.
    // and the ConnsHandler use for create the ConnHandlers or request.
    final connsHandler = ConnsHandler();

    //initialize the efp receive for process the data from the client
    efp.receive(connsHandler);

    //handle login process tag login from client in this case
    // validate user and password.
    final login = ConnHandler('login', (connHandler, tag, id) {
      final data = json.decode(utf8.decode(connHandler.data[id]!));
      //remove the data from the connHandler
      connHandler.data.remove(id);

      if (data["user"] == "pepe" && data["password"] == "123") {
        efp.send(utf8.encode('{"logged": true}'), tag);
      }
    });

    //add login to connsHandler for process the login tag
    connsHandler.add(login);

    //handle history process tag history from client in this case
    // process the history request.
    final history = ConnHandler('history', (connHandler, tag, id) async {
      final data = json.decode(utf8.decode(connHandler.data[id]!));
      //remove the data from the connHandler
      connHandler.data.remove(id);
      final start = data["start"];
      final end = data["end"];
      bool isCancel = false;
      connHandler.cancel.stream.listen((tagCanceled) {
        print("tagCanceled: $tagCanceled");
        if (tagCanceled == tag.substring(1)) {
          isCancel = true;
        }
      });
      int max = 0;
      for (var i = start; i <= end; i++) {
        await Future.delayed(Duration(milliseconds: 1000));
        stdout.write("$i,");
        max = i;
        if (isCancel) {
          print("process canceled in $i of $end");
          return;
        }
      }
      print("");
      efp.send(utf8.encode('{"data": $max}'), tag);
    });

    connsHandler.add(history);
  }
}

//client
void client() async {
  print("Running client");
  final socket = await Socket.connect('127.0.0.1', 3000);
  final efp = Efp(socket);
  final connsHandler = ConnsHandler();

  //initialize the efp receive for process the data from the server
  efp.receive(connsHandler);

  //login
  final login = connsHandler.req("login", (connHandler, tag, id) {
    Map data = json.decode(utf8.decode(connHandler.data[id]!));
    if (data["logged"]) {
      print("You are logged");
    }
  });

  //request login
  final credential = utf8.encode('{"user": "pepe", "password": "123"}');
  efp.send(credential, login.tag, action: 1);

  //History
  var history = connsHandler.req("history", (connHandler, tag, id) async {
    Map data = json.decode(utf8.decode(connHandler.data[id]!));
    print("Client Data: ${data["data"]}");
  });

  //request history
  efp.send(utf8.encode('{"start": 1, "end":99}'), history.tag, action: 1);
  await Future.delayed(Duration(seconds: 5));
  //cancel history
  // efp.send(utf8.encode(''), "test1121545", action: 3);

  //TODO: change send to cancel efp.camcel(tag)
  efp.send(utf8.encode(''), "arrozconmango", action: 3);
  //TODO: problem with the cancel  continuous send
  //await Future.delayed(Duration(seconds: 1));
  efp.send(utf8.encode(''), history.tag, action: 3);
  // efp.send(utf8.encode(''), history.tag, action: 3);
  // efp.send(utf8.encode(''), history.tag, action: 3);

  //request history less data
  await Future.delayed(Duration(seconds: 1));
  history = connsHandler.req("history", (connHandler, tag, id) async {
    Map data = json.decode(utf8.decode(connHandler.data[id]!));
    print("Client Data: ${data["data"]}");
  });
  efp.send(utf8.encode('{"start": 10, "end":15}'), history.tag, action: 1);
  efp.send(utf8.encode('{"start": 10, "end":15}'), history.tag, action: 1);
}
