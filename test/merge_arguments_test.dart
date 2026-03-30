import 'package:natrix/src/core/parser.dart' show NatrixParser;
import 'package:test/test.dart';

void main() {
  final NatrixParser parser = NatrixParser();
  test('First Test', () {
    expect(
      parser.mergeArguments([
        "redeem",
        "code",
        "--newest",
        "--account=\"Lenny",
        "Siebert\"",
        "--password=\"tripple",
        "11\"",
        "-f",
        "--mail",
        "zopnote@proton.me",
        "\"dr3-4Sa-W7c-dF2-1AV:\\\"SPRING",
        "SALE",
        "AUGUST",
        "2024\\\"\"",
      ]),
      [
        "redeem",
        "code",
        "--newest",
        "--account=\"Lenny Siebert\"",
        "--password=\"tripple 11\"",
        "-f",
        "--mail",
        "zopnote@proton.me",
        "\"dr3-4Sa-W7c-dF2-1AV:\\\"SPRING SALE AUGUST 2024\\\"\"",
      ],
    );
  });
}
