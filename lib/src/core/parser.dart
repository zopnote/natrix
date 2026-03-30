
import 'package:natrix/src/core/flag.dart' show NatrixFlag, NatrixBoolFlag;
import 'package:natrix/src/core/misc.dart' show IterableFirstWhereOrNullExtension, simpleStringReduction;



class NatrixParserFlag {
  final String id;
  final String val;
  final bool isShort;

  const NatrixParserFlag(this.id, this.val, this.isShort);

  NatrixParserFlag set(String val) => NatrixParserFlag(id, val, isShort);

  @override
  String toString() => id;

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) => identical(other, this);
}

class NatrixParserOutput {
  final Iterable<NatrixFlag> flags;
  final List<String> arguments;
  const NatrixParserOutput([this.arguments = const [], this.flags = const []]);
}

class NatrixParser {
  const NatrixParser();

  List<String> mergeArguments(List<String> rawArguments) {
    final List<String> args = [];
    String arg = "";
    bool openQuotes = false;
    for (final String raw in rawArguments) {
      arg += arg.isEmpty ? raw : " $raw";
      for (int i = 0; i < raw.length; i++) {
        if (i > 0 && raw[i - 1] == "\\") {
          continue;
        }
        if (raw[i] == "\"") {
          openQuotes = !openQuotes;
        }
      }
      if (!openQuotes) {
        args.add(arg);
        arg = "";
      }
    }
    return args;
  }

  NatrixParserFlag parseRawFlag(String raw, [String? val]) {
    final List<String> parts = raw.split("=");
    final bool isShort = !raw.startsWith("--") && raw.startsWith("-");
    return NatrixParserFlag(
      parts.first.substring(isShort ? 1 : 2),
      val ?? (parts.length > 1 ? parts.last : ""),
      !raw.startsWith("--") && raw.startsWith("-"),
    );
  }

  Iterable<NatrixFlag> parseFlags(
    final List<String> mergedArguments,
    final Iterable<NatrixFlag> predefinedFlags,
  ) {
    final List<String> args = mergedArguments;
    final List<NatrixFlag> flags = [];

    for (NatrixFlag f in predefinedFlags) {
      NatrixParserFlag? raw;

      for (int i = 0; i < args.length; i++) {
        if (!args[i].startsWith("-")) {
          continue;
        }
        final NatrixParserFlag r = parseRawFlag(args[i]);
        if (r.isShort ? f.acronym != r.id : f.id != r.id) {
          continue;
        }
        if (f is NatrixBoolFlag || r.val.isNotEmpty) {
          raw = r;
          break;
        }
        final String e =
            "The flag with the identifier \"$r\" requires a value.";
        if (i >= args.length - 1) {
          throw Exception(e);
        }
        final String val = args[i + 1];
        if (val.startsWith("-")) {
          throw Exception(e);
        }
        raw = r.set(val);
        break;
      }
      if (raw == null) {
        flags.add(f);
        continue;
      }
      flags.add(f.set(f.parse(raw.val)));
    }
    return flags;
  }

  NatrixParserOutput parse(
    final List<String> mergedArguments,
    final Iterable<NatrixFlag> predefinedFlags,
  ) {
    final List<String> options = [];
    final List<String> args = mergedArguments;
    int i = 0;
    for (;;) {
      if (i >= args.length) {
        break;
      }
      if (!args[i].startsWith("-")) {
        options.add(simpleStringReduction(args[i]));
        i++;
        continue;
      }
      final NatrixParserFlag r = parseRawFlag(args[i]);
      final NatrixFlag? flag = predefinedFlags.firstWhereOrNull(
        (f) => r.isShort ? f.acronym == r.id : f.id == r.id,
      );
      if (flag == null) {
        throw Exception(
          "There is no flag with the identifier \"$r\" in this context.",
        );
      }
      if (r.val.isNotEmpty || i >= args.length - 1) {
        i++;
        continue;
      }
      if (!args[i + 1].startsWith("-")) {
        i += 2;
        continue;
      }
      i++;
    }
    return NatrixParserOutput(
      options,
      parseFlags(mergedArguments, predefinedFlags),
    );
  }
}
