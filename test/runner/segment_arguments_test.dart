import 'package:natrix/natrix.dart';
import 'package:natrix/src/runner.dart';
import 'package:test/test.dart';

void main() {
  final NatrixParser parser = NatrixParser();
  test('First Test', () {
    expect(
      parser.segmentArguments([
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
      NatrixOptions([
        "redeem", "code", "dr3-4Sa-W7c-dF2-1AV:\"SPRING SALE AUGUST 2024\""
      ], [
        NatrixRawFlag(identifier: "newest", short: false),
        NatrixRawFlag(identifier: "account", short: false, value: "Lenny Siebert"),
        NatrixRawFlag(identifier: "password", short: false, value: "tripple 11"),
        NatrixRawFlag(identifier: "f", short: true),
        NatrixRawFlag(identifier: "m", short: true, value: "zopnote@proton.me")
      ]),
    );
  });
}
