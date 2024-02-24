import 'dart:async';

class ConnsHandler {
  final List<ConnHandler> _connsHandler = [];

  ConnHandler add(ConnHandler connHandler) {
    //check if the tag already exists
    if (_connsHandler.contains(connHandler)) {
      return connHandler;
    }
    //check if the tag starts with a number
    //the tag can't start with a number because the tag is used to identify the
    //tag of type request with the tag automatically generated.
    if (connHandler.tag.startsWith(RegExp(r'[0-9]'))) {
      throw ArgumentError('the tag can\'t start with a number.');
    }
    _connsHandler.add(connHandler);

    return connHandler;
  }

  ConnHandler _addReq(ConnHandler connHandler) {
    //check if the tag already exists
    if (_connsHandler.contains(connHandler)) {
      throw ArgumentError('the tag already exists');
    }
    _connsHandler.add(connHandler);

    return connHandler;
  }

  get getAll {
    return _connsHandler;
  }

  ConnHandler get(String tag) {
    return _connsHandler.firstWhere(
      (element) => element.tag == tag,
      orElse: () => ConnHandler('', (f, t) {}),
    );
  }

  void remove(ConnHandler connHandler) {
    _connsHandler.remove(connHandler);
  }

  ConnHandler req(String tag, ActionFunc function) {
    if (tag.length > 8) {
      throw ArgumentError('the string exceeds the maximum size of 8 bytes.');
    }
    final String microsecond = DateTime.now().microsecondsSinceEpoch.toString();
    //!OLD remove the 8 characters of the microsecond !note: or convert base256
    ///remove the 5 characters of the microsecond convert base32
    String subTag = microsecond.substring(2, microsecond.length - 3);
    //subTag to base32
    subTag = int.parse(subTag).toRadixString(32);

    return _addReq(ConnHandler("$subTag$tag", function));
  }
}

typedef ActionFunc = void Function(ConnHandler, String);

class ConnHandler {
  final String _tag;
  final ActionFunc _function;
  final StreamController<String> cancel = StreamController.broadcast();

  List<int> data = [];

  ConnHandler(this._tag, this._function) {
    if (_tag.length > 16) {
      throw ArgumentError('the string exceeds the maximum size of 16 bytes.');
    }
  }

  //get
  String get tag {
    return _tag;
  }

  //get function
  Function get function {
    return _function;
  }

  @override
  String toString() {
    return _tag;
  }
}
