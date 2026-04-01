import 'package:natrix/core.dart';
import 'package:natrix/src/core/misc.dart';

/**
 * Represents an unprocessed flag read directly from the command-line input.
 */
class NatrixParserFlag {
  const NatrixParserFlag(this.tag, this.val, this.isShort);

  /**
   * The [tag] of the flag (the flag’s identifier or acronym),
   * specified on the command line (``-t`` or ``--test``).
   */
  final String tag;

  /**
   * A [string] value to be assigned to the flag call.
   */
  final String val;

  /**
   * Whether the flag was called in short
   * form (``-e``) or in long form (``--example``);
   */
  final bool isShort;

  NatrixParserFlag set(String val) => NatrixParserFlag(tag, val, isShort);

  @override
  String toString() => tag;

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) => identical(other, this);
}

/**
 * [NatrixParserOutput] holds the output of the process within [NatrixParser].
 */
class NatrixParserOutput {
  const NatrixParserOutput([this.args = const [], this.flags = const []]);

  /**
   * An [Iterable] of all [NatrixFlag]s which will be applied to a command.
   */
  final Iterable<NatrixFlag> flags;

  /**
   * The [args], that will be finally applied to a commands callback.
   */
  final List<String> args;
}

/**
 * The [NatrixParser] processes command-line input in a standard CLI syntax.
 * This is the implementation of the user interface.
 */
class NatrixParser {
  const NatrixParser();

  /**
   * To process the arguments correctly, the system checks for quotation
   * marks in the arguments, as well as for opening and closing brackets,
   * to ensure that the [mergedArguments] contain related
   * data to actual parse it later.
   */
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

  /**
   * Reads raw [String] input and map it into the description of a flag usable for
   * further processing.
   */
  NatrixParserFlag parseRawFlag(String raw, [String? val]) {
    final List<String> parts = raw.split("=");
    final bool isShort = !raw.startsWith("--") && raw.startsWith("-");
    return NatrixParserFlag(
      parts.first.substring(isShort ? 1 : 2),
      val ?? (parts.length > 1 ? parts.last : ""),
      !raw.startsWith("--") && raw.startsWith("-"),
    );
  }

  /**
   * Using the [predefinedFlags], it is possible to determine the corresponding
   * [NatrixFlag] called from the input values ([mergedArguments]) and create
   * a copy of the instance with the new value provided.
   */
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
        if (r.isShort ? f.acronym != r.tag : f.id != r.tag) {
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

  /**
   * Reads [mergedArguments] (by default from [NatrixParser.mergeArguments()])
   * and converts them into concrete, interface-compliant value representations.
   */
  NatrixParserOutput parse(
    final List<String> mergedArguments,
    final Iterable<NatrixFlag> predefinedFlags,
  ) {
    final List<String> options = [];
    final List<String> args = mergedArguments;
    ;
    for (int i = 0; i < args.length; i++) {
      if (!args[i].startsWith("-")) {
        options.add(simpleStringReduction(args[i]));
        continue;
      }
      final NatrixParserFlag r = parseRawFlag(args[i]);
      final NatrixFlag? flag = predefinedFlags.firstWhereOrNull(
        (f) => r.isShort ? f.acronym == r.tag : f.id == r.tag,
      );
      if (flag == null) {
        throw Exception(
          "There is no flag with the identifier \"$r\" in this context.",
        );
      }
      if (r.val.isNotEmpty || i >= args.length - 1) {
        continue;
      }
      if (!args[i + 1].startsWith("-")) {
        i++;
        continue;
      }
    }
    return NatrixParserOutput(
      options,
      parseFlags(mergedArguments, predefinedFlags),
    );
  }
}
