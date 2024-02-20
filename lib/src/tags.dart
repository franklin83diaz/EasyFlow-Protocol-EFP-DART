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
    return _connsHandler.firstWhere((element) => element.tag == tag,
        orElse: () => ConnHandler('', () {}));
  }

  void remove(ConnHandler connHandler) {
    _connsHandler.remove(connHandler);
  }

  ConnHandler req(String tag, Function function) {
    if (tag.length > 8) {
      throw ArgumentError('the string exceeds the maximum size of 8 bytes.');
    }
    final String microsecond = DateTime.now().microsecondsSinceEpoch.toString();
    //remove the 8 characters of the microsecond !note: or convert base256
    String subTag = microsecond.substring(5, microsecond.length - 3);

    return _addReq(ConnHandler(subTag + tag, function));
  }
}

class ConnHandler {
  final String _tag;
  final Function _function;
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
