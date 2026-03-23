import 'package:natrix/natrix.dart';

String _simpleStringReduction(String raw) {
  String o = "";
  int n = 0;
  for (int i = 0; i < raw.length; i++) {
    if (raw[i] != "\"") {
      o += raw[i];
      n++;
      continue;
    }
    if (i < 1) {
      continue;
    }
    if (raw[i - 1] != "\\") {
      continue;
    }
    o = o.substring(0, n - 1);
    o += raw[i];
  }
  return o;
}


class NatrixParser {
  const NatrixParser();

  /// Merges raw arguments into a list of arguments, based if the raw arguments
  /// were enclosed by quotes.
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

  NatrixParserRawFlag createRawFlag(String raw, [String? val]) {
    final List<String> parts = raw.split("=");
    final bool isShort = !raw.startsWith("--") && raw.startsWith("-");
    return NatrixParserRawFlag(
      parts.first.substring(isShort ? 1 : 2),
      val ?? (parts.length > 1 ? parts.last : ""),
      !raw.startsWith("--") && raw.startsWith("-"),
    );
  }

  Iterable<Flag> parseFlags(
      final List<String> mergedArguments,
      final Iterable<Flag> predefinedFlags,
      ) {
    final List<String> args = mergedArguments;
    final List<Flag> flags = [];

    for (Flag f in predefinedFlags) {
      NatrixParserRawFlag? raw;

      for (int i = 0; i < args.length; i++) {
        if (!args[i].startsWith("-")) {
          continue;
        }
        final NatrixParserRawFlag r = createRawFlag(args[i]);
        if (r.isShort ? f.short != r.id : f.name != r.id) {
          continue;
        }
        if (f is BoolFlag || r.val.isNotEmpty) {
          raw = r;
          break;
        }
        final String e = "The flag with the identifier \"$r\" requires a value.";
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

  /// Breaks down the raw command line arguments into arguments and flags.
  NatrixOptions parseOptions(
      final List<String> mergedArguments,
      final Iterable<Flag> predefinedFlags,
      ) {
    final List<String> options = [];
    final List<String> args = mergedArguments;
    int i = 0;
    for (;;) {
      if (i >= args.length) {
        break;
      }
      if (!args[i].startsWith("-")) {
        options.add(_simpleStringReduction(args[i]));
        i++;
        continue;
      }
      final NatrixParserRawFlag r = createRawFlag(args[i]);
      final Flag? flag = predefinedFlags.firstWhereOrNull(
            (f) => r.isShort ? f.short == r.id : f.name == r.id,
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
    return NatrixOptions(options, parseFlags(mergedArguments, predefinedFlags));
  }
}

class NatrixOptions {
  final Iterable<Flag> flags;
  final List<String> arguments;
  const NatrixOptions([this.arguments = const [], this.flags = const []]);
}

class NatrixParserRawFlag {
  final String id;
  final String val;
  final bool isShort;
  const NatrixParserRawFlag(this.id, this.val, this.isShort);
  NatrixParserRawFlag set(String val) => NatrixParserRawFlag(id, val, isShort);
  @override
  String toString() => id;
}


extension IterableFirstWhereOrNullExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}