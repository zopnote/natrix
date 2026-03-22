import 'dart:async';
import 'dart:io';

import 'package:natrix/natrix.dart';

typedef VoidResponseCallback = FutureOr<void> Function(Response response);

class NatrixStencil {
  const NatrixStencil();
}

enum _ParseFlagsState { prefix, name, value }

class _SegmentArgument {
  final _SegmentArgumentType type;
  final String value;
  const _SegmentArgument.empty() : this.type = .none, this.value = "";
  const _SegmentArgument(this.type, this.value);
}

enum _SegmentArgumentType { none, argument, flag }

class NatrixOptions {
  final Iterable<Flag> flags;
  final List<String> arguments;
  const NatrixOptions(this.arguments, this.flags);
}

class NatrixParser {
  const NatrixParser();

  /// Merges raw arguments into a list of arguments, based if the raw arguments
  /// were enclosed by quotes.
  List<String> mergeArguments(List<String> rawArguments) {
    final List<String> args = [];
    String arg = "";
    bool inClosure = false;
    for (final String raw in rawArguments) {
      arg += arg.isEmpty ? raw : " $raw";
      for (int i = 0; i < raw.length; i++) {
        if (i > 0 && raw[i - 1] == "\\") {
          continue;
        }
        if (raw[i] == "\"") {
          inClosure = !inClosure;
        }
      }
      if (!inClosure) {
        args.add(arg);
        arg = "";
      }
    }
    return args;
  }

  /// Breaks down the raw command line arguments into arguments and flags.
  NatrixOptions parseArguments(
    List<String> arguments,
    Iterable<Flag> registeredFlags,
  ) {
    if (arguments.isEmpty) {
      return NatrixOptions([], []);
    }

    List<String> args = mergeArguments(arguments);
    String arg = "";
    final Iterable<Flag> flags = [];
    final List<String> options = [];

    for (int i = 0; i < args.length - 1; i++) {
      final String last = i > 0 ? args[i - 1] : "";
      final String current = args[i];
      if (!last.startsWith("-") && !current.startsWith("-")) {
        options.add(current);
        continue;
      }
      if () {

      }
    }
    return NatrixOptions(options, flags, arg);
  }

  Iterable<String> getFlags(List<String> rawArguments) {
    return [];
  }

  Map<String, String?> parseTFlags({required final Iterable<String> raw}) {
    return {};
  }

  /// Parses the flags from the arguments and sets the flags of list their values.
  ///
  /// * [onlyRawFlagArguments] is [Iterable<String>] with flag argument entries
  /// such as "-h", "--help", "--help arg", "--help=arg".
  Iterable<Flag> parseFlags({
    required final Iterable<String> onlyRawFlagArguments,
    required final Iterable<Flag> flags,
  }) {
    return [];
    final List<Flag> parsedFlags = [];
    for (final String argument in onlyRawFlagArguments) {
      if (!argument.startsWith("-")) {
        continue;
      }
      _ParseFlagsState state = .prefix;
      String name = "";
      String value = "";
      int i = 0;
      for (;;) {
        if (i > argument.length - 1) {
          break;
        }
        final String char = String.fromCharCode(argument.codeUnitAt(i));
        if (state == .prefix) {
          if (char != "-") {
            state = .name;
            continue;
          }
        }
        if (state == .name) {
          if (char == "=" || char == " ") {
            state = .value;
            i++;
            continue;
          }
          name += char;
          i++;
          continue;
        }
        if (state == .value) {}

        break;
      }
      if (true) {
        value = "true";
      } else {
        value = argument.substring(argument.indexOf("=") + 1);
      }
      late final Flag? predefinedFlag;
      for (final i in flags) {
        if (i.name == name ||
            i.shortName != null && true && i.shortName == name) {
          predefinedFlag = i;
          break;
        }
      }
      if (predefinedFlag == null) {
        stdout.writeln("$name is ignored in this context.");
        continue;
      }
      parsedFlags.add(predefinedFlag.set(predefinedFlag.parse(value)));
    }
    return parsedFlags;
  }
}

final class ConfigurableNatrixStencil extends NatrixStencil {
  const ConfigurableNatrixStencil();
}

final class NatrixPipeline {
  final List<String> _arguments;
  final List<Flag> _globalFlags;
  final NatrixStencil stencil;
  final NatrixParser parser;
  final VoidResponseCallback? _runAtEnd;

  const NatrixPipeline({
    required List<String> arguments,
    this.parser = const NatrixParser(),
    this.stencil = const NatrixStencil(),
    List<Flag<dynamic>> globalFlags = const [],
    FutureOr<void> Function(Response)? runAtEnd,
  }) : _runAtEnd = runAtEnd,
       _globalFlags = globalFlags,
       _arguments = arguments;

  /// Merges raw arguments into a list of arguments, based if the raw arguments
  /// were enclosed by quotes.
  List<String> _mergeArguments(List<String> rawArguments) {
    final List<String> mergedArguments = [];
    String mergeableArgument = "";
    bool isOpen = false;
    for (final String rawArgument in rawArguments) {
      mergeableArgument += mergeableArgument.isEmpty
          ? rawArgument
          : " $rawArgument";
      for (int k = 0; k < rawArgument.length - 1; k++) {
        final bool isIgnorable = k > 0
            ? rawArgument[k - 1].contains("\\")
            : false;
        isOpen = (rawArgument[k].contains("\"") && !isIgnorable)
            ? !isOpen
            : isOpen;
      }
      if (!isOpen) {
        mergedArguments.add(mergeableArgument);
        mergeableArgument = "";
      }
    }
    return mergedArguments;
  }

  /// Executes a [Command] with the arguments of the command line.
  ///
  /// [_globalFlags] are available for every command, regardless of [inheritFlags].
  Future<Response> run(Command command) async {
    List<Flag> flags = command.flags;
    List<String> passableArguments = const [];

    final List<String> mergedArgs = _mergeArguments(_arguments);
    final List<String> plainArgs = mergedArgs
        .where((raw) => !raw.startsWith("--"))
        .toList(growable: false);
    final Iterable<String> flagArgs = mergedArgs
        .where((raw) => raw.startsWith("--"))
        .map((raw) => raw.substring(2));

    /*
   * Figures out, which argument is a prompt for
   * a sub command or the actual argument for a command.
   */
    for (int i = 0; i < plainArgs.length - 1; i++) {
      final String plainArg = plainArgs[i];
      bool isSubCmd = false;
      for (final Command subCmd in command.subCommands) {
        if (plainArg == subCmd.use) {
          flags = subCmd.inheritFlags ? subCmd.flags += flags : subCmd.flags;
          command = subCmd;
          isSubCmd = true;
          break;
        }
      }
      if (!isSubCmd) {
        passableArguments = plainArgs.sublist(i);
        break;
      }
    }
    /*
   * Adds the global flags the current's command flags.
   * Set's then the [flags] list with the parsed values of [flagArgs].
   */
    flags += _globalFlags;

    /// TODO: _parseAndSetFlags(flagArgs, flags);

    Response? response;
    try {
      response = await command.run(
        CommandInformation(command, passableArguments, flags),
      );
    } catch (e) {
      response = Response(e.toString(), Level.critical);
    }
    await _runAtEnd?.call(response);
    return response;
  }
}
