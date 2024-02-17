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
  });
}
