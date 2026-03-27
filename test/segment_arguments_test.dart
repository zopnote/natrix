import 'package:natrix/natrix.dart' show NatrixTextFlag, NatrixChar;
import 'package:natrix/src/flag.dart' show NatrixBoolFlag;
import 'package:natrix/src/parser.dart' show NatrixParser, NatrixOptions;
import 'package:test/test.dart';

extension SerializeNatrixOptionsExtension on NatrixOptions {
  Map<String, dynamic> toJson() => {
    "flags": flags.map(
      (flag) => {
        "name": flag.id,
        "acronym": flag.acronym,
        "description": flag.tooltip,
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
          NatrixBoolFlag(id: "newest"),
          NatrixTextFlag(id: "account"),
          NatrixTextFlag(id: "password"),
          NatrixBoolFlag(id: "force", acronym: NatrixChar("f")),
          NatrixTextFlag(id: "mail", acronym: NatrixChar("m")),
        ],
      ).toJson(),
      NatrixOptions(
        ["redeem", "code", "dr3-4Sa-W7c-dF2-1AV:\"SPRING SALE AUGUST 2024\""],
        [
          NatrixBoolFlag(id: "newest", value: true),
          NatrixTextFlag(id: "account", value: "Lenny Siebert"),
          NatrixTextFlag(id: "password", value: "tripple 11"),
          NatrixBoolFlag(id: "force", acronym: NatrixChar("f"), value: true),
          NatrixTextFlag(
            id: "mail",
            acronym: NatrixChar("m"),
            value: "zopnote@proton.me",
          ),
        ],
      ).toJson(),
    );
  });
}
