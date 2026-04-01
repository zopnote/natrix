import 'package:natrix/core.dart';
import 'package:test/test.dart';

void main() {
  group('NatrixTextFlag', () {
    test('parses plain text without quotes', () {
      const flag = NatrixTextFlag(id: "test");
      final result = flag.parse("hello world");

      expect(result, "hello world");
    });

    test('parses text with escaped quotes', () {
      const flag = NatrixTextFlag(id: "test");
      final result = flag.parse('text with \\"escaped\\" quotes');

      expect(result, 'text with "escaped" quotes');
    });

    test('removes unescaped quotes', () {
      const flag = NatrixTextFlag(id: "test");
      final result = flag.parse('"quoted text"');

      expect(result, 'quoted text');
    });

    test('handles multiple escaped quotes', () {
      const flag = NatrixTextFlag(id: "test");
      final result = flag.parse('first \\"quote\\" and second \\"quote\\"');

      expect(result, 'first "quote" and second "quote"');
    });

    test('formats value as-is', () {
      const flag = NatrixTextFlag(id: "test", value: "some value");

      expect(flag.format("test"), "test");
      expect(flag.getFormatted(), "some value");
    });

    test('creates new instance with set()', () {
      const flag = NatrixTextFlag(id: "test", value: "old");
      final updated = flag.set("new");

      expect(flag.value, "old");
      expect(updated.value, "new");
      expect(updated.id, "test");
    });
  });

  group('NatrixBoolFlag', () {
    test('parses empty string as false', () {
      const flag = NatrixBoolFlag(id: "test");
      final result = flag.parse("");

      expect(result, true);
    });

    test('parses "false" string as false', () {
      const flag = NatrixBoolFlag(id: "test");
      final result = flag.parse("false");

      expect(result, false);
    });

    test('parses any other string as true', () {
      const flag = NatrixBoolFlag(id: "test");

      expect(flag.parse("true"), true);
      expect(flag.parse("1"), true);
      expect(flag.parse("yes"), true);
      expect(flag.parse("anything"), true);
    });

    test('formats value as string', () {
      const flag = NatrixBoolFlag(id: "test", value: true);

      expect(flag.format(true), "true");
      expect(flag.format(false), "false");
      expect(flag.getFormatted(), "true");
    });

    test('creates new instance with set()', () {
      const flag = NatrixBoolFlag(id: "test", value: false);
      final updated = flag.set(true);

      expect(flag.value, false);
      expect(updated.value, true);
      expect(updated.id, "test");
    });

    test('toString returns formatted value', () {
      const flag = NatrixBoolFlag(id: "test", value: true);

      expect(flag.toString(), "true");
    });
  });

  group('NatrixFlag equality and hashing', () {
    test('identical flags are equal', () {
      const flag = NatrixTextFlag(id: "test");

      expect(flag == flag, true);
    });

    test('hashCode is consistent', () {
      const flag = NatrixTextFlag(id: "test", tooltip: "tooltip");
      final hash1 = flag.hashCode;
      final hash2 = flag.hashCode;

      expect(hash1, hash2);
    });
  });
}
