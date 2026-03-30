import 'dart:async';
import 'dart:io';

import 'package:natrix/src/core/parser.dart' show NatrixParser, NatrixParserOutput;
import 'package:natrix/src/core/command.dart' show NatrixCommand;
import 'package:natrix/src/core/flag.dart' show NatrixFlag;
import 'package:natrix/src/core/theme.dart'
    show NatrixTheme, NatrixContext, NatrixDefaultTheme;

typedef NatrixThemeCallback = NatrixTheme Function(NatrixContext);

class NatrixCallbackOptions {
  final NatrixCommand command;
  final List<String> arguments;
  final Iterable<NatrixFlag> flags;
  final NatrixTheme theme;

  const NatrixCallbackOptions({
    required this.command,
    required this.theme,
    required this.arguments,
    required this.flags,
  });

  NatrixFlag<T> getFlag<T>(String name) {
    for (final NatrixFlag f in flags) {
      if (f.id == name) {
        return f as NatrixFlag<T>;
      }
    }
    throw Exception(
      "There isn't a flag found with the name \"$name\" in the given list.",
    );
  }
}

final class NatrixPipeline {
  final List<String> _arguments;
  final Iterable<NatrixFlag> _global;
  final NatrixParser parser;
  late final NatrixThemeCallback theme;
  NatrixPipeline({
    required List<String> arguments,
    this.parser = const NatrixParser(),
    List<NatrixFlag> globalFlags = const [],
  }) : _global = globalFlags,
       _arguments = arguments,
       theme = ((context) => NatrixDefaultTheme(context));

  Future<void> run(NatrixCommand command) async {
    final List<String> args = parser.mergeArguments(_arguments);

    NatrixCommand c = command;
    final List<NatrixFlag> flags = [];

    bool found = true;
    int i = 0;
    while (found) {
      flags.addAll(c.flags);
      for (final NatrixCommand s in c.children) {
        found = s.id == args.elementAtOrNull(i);
        if (found) {
          c = s.withParent(c);
          i++;
          break;
        }
      }
      break;
    }
    final NatrixParserOutput options = parser.parse(args, flags);

    await command.callback(
      NatrixCallbackOptions(
        command: command,
        flags: options.flags,
        arguments: options.arguments,
        theme: theme(
          NatrixContext(
            command: command,
            options: options,
            globalFlags: _global,
            lineLength: stdout.hasTerminal ? stdout.terminalColumns : 512,
          ),
        ),
      ),
    );
  }
}
