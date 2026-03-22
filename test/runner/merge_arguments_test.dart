import 'package:natrix/natrix.dart';
import 'package:natrix/src/runner.dart';
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
        "-m",
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
        "-m",
        "zopnote@proton.me",
        "\"dr3-4Sa-W7c-dF2-1AV:\\\"SPRING SALE AUGUST 2024\\\"\"",
      ],
    );
  });
}
