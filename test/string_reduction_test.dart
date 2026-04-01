import 'package:natrix/src/core/misc.dart';
import 'package:test/test.dart';

void main() {
  group("Test string reduction of misc.dart", () {
    test("Single quote reduction", () {
      expect(simpleStringReduction("\"Hello world\""), "Hello world");
    });
    test("Multiple backslashed quote reduction", () {
      expect(simpleStringReduction("\\\"\\\"\\\"Hello world\\\"\\\"\\\""), "\"\"\"Hello world\"\"\"");
    });
    test("Inner quote reduction", () {
      expect(simpleStringReduction("\"\\\"\\\"Hello world\\\"\\\"\""), "\"\"Hello world\"\"");
    });
  });
}