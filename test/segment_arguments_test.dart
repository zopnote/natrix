import 'package:natrix/natrix.dart' show TextFlag;
import 'package:natrix/src/flag.dart' show BoolFlag;
import 'package:natrix/src/parser.dart' show NatrixParser, NatrixOptions;
import 'package:test/test.dart';

extension SerializeNatrixOptionsExtension on NatrixOptions {
  Map<String, dynamic> toJson() => {
    "flags": flags.map(
      (flag) => {
        "name": flag.name,
        "short": flag.short,
        "description": flag.description,
        "examples": flag.examples,
        "value": flag.value,
      },
    ),
    "arguments": arguments,
  };
}

void main() {
  final NatrixParser parser = NatrixParser();
  test('First Test', () {
    expect(
      parser.parseOptions(
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
          BoolFlag(name: "newest"),
          TextFlag(name: "account"),
          TextFlag(name: "password"),
          BoolFlag(name: "force", short: "f"),
          TextFlag(name: "mail", short: "m"),
        ],
      ).toJson(),
      NatrixOptions(
        ["redeem", "code", "dr3-4Sa-W7c-dF2-1AV:\"SPRING SALE AUGUST 2024\""],
        [
          BoolFlag(name: "newest", value: true),
          TextFlag(name: "account", value: "Lenny Siebert"),
          TextFlag(name: "password", value: "tripple 11"),
          BoolFlag(name: "force", short: "f", value: true),
          TextFlag(name: "mail", short: "m", value: "zopnote@proton.me"),
        ],
      ).toJson(),
    );
  });
}
