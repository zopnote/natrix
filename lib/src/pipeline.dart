import 'dart:async';

import 'package:natrix/natrix.dart';
import 'package:natrix/src/writer.dart';

final class NatrixPipeline {
  final List<String> _arguments;
  final Iterable<NatrixFlag> _global;
  final NatrixTheme theme;
  final NatrixParser parser;

  NatrixPipeline({
    required List<String> arguments,
    this.parser = const NatrixParser(),
    final NatrixTheme? theme,
    List<NatrixFlag<dynamic>> globalFlags = const [],
  }) : _global = globalFlags,
       this.theme = theme ?? NatrixDefaultTheme.at(NatrixStdio()),
       _arguments = arguments;

  Future<void> run(NatrixCommand command) async {
    final List<String> args = parser.mergeArguments(_arguments);

    NatrixCommand c = command;
    final List<NatrixFlag> flags = _global.toList();

    bool found = true;
    int i = 0;
    while (found) {
      flags.addAll(c.flags);
      for (final NatrixCommand s in c.children) {
        found = s.id == args.elementAtOrNull(i);
        if (found) {
          c = s;
          i++;
          break;
        }
      }
      break;
    }
    final NatrixOptions options = parser.parseOptions(args, flags);
    await command.callback(command, options.arguments, options.flags);
  }
}
