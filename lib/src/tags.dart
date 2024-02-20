class Tags {
  final List<Tag> _tags = [];

  Tag addTag(Tag tag) {
    //check if the tag already exists
    if (_tags.contains(tag)) {
      return tag;
    }
    //check if the tag starts with a number
    //the tag can't start with a number because the tag is used to identify the
    //tag of type request with the tag automatically generated.
    if (tag.valor.startsWith(RegExp(r'[0-9]'))) {
      throw ArgumentError('the tag can\'t start with a number.');
    }
    _tags.add(tag);

    return tag;
  }

  get tags {
    return _tags;
  }

  Tag getTag(String tag) {
    return _tags.firstWhere((element) => element.valor == tag,
        orElse: () => Tag('', () {}));
  }

  void removeTag(Tag tag) {
    _tags.remove(tag);
  }

  Tag getNewTag(value, Function function) {
    if (value.length > 8) {
      throw ArgumentError('the string exceeds the maximum size of 8 bytes.');
    }
    final String microsecond = DateTime.now().microsecondsSinceEpoch.toString();
    //remove the last 3 characters of the microsecond
    String tag = microsecond.substring(5, microsecond.length - 3);
    //3 characters

    return addTag(Tag(value + tag, function));
  }
}

class Tag {
  final String _valor;
  final Function _function;
  List<int> _data = [];

  Tag(this._valor, this._function) {
    if (_valor.length > 16) {
      throw ArgumentError('the string exceeds the maximum size of 16 bytes.');
    }
  }

  //get
  String get valor {
    return _valor;
  }

  //get function
  Function get function {
    return _function;
  }

  //set data
  set data(List<int> data) {
    _data = data;
  }

  List<int> get data {
    return _data;
  }

  @override
  String toString() {
    return _valor;
  }
}
