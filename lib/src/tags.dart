import 'dart:math';

class Tags {
  final List<Tag> _tags = [];

  bool addTag(Tag tag) {
    //check if the tag already exists
    if (_tags.contains(tag)) {
      return false;
    }
    //check if the tag starts with a number
    //the tag can't start with a number because the tag is used to identify the
    //tag of type request with the tag automatically generated.
    if (tag.valor.startsWith(RegExp(r'[0-9]'))) {
      return false;
    }
    _tags.add(tag);

    return true;
  }

  void removeTag(Tag tag) {
    _tags.remove(tag);
  }

  getNewTag() {
    //rand characters
    List chars = 'abcdefghijklmnopqrstuvwxyz'.split('');
    var random = Random();
    String tag = '';

    final String microsecond = DateTime.now().microsecondsSinceEpoch.toString();
    //remove the last 3 characters of the microsecond
    tag += microsecond.substring(0, microsecond.length - 3);
    //3 characters
    for (var i = 0; i < 3; i++) {
      tag += chars[random.nextInt(chars.length)];
    }
    return Tag(tag.toString());
  }
}

class Tag {
  final String _valor;

  Tag(this._valor) {
    if (_valor.length > 16) {
      throw ArgumentError('the string exceeds the maximum size of 16 bytes.');
    }
  }

  //set
  set valor(String valor) {
    if (valor.length > 16) {
      throw ArgumentError('the string exceeds the maximum size of 16 bytes.');
    }
  }

  //get
  String get valor {
    return _valor;
  }

  @override
  String toString() {
    return _valor;
  }
}
