import 'dart:async';

import 'package:natrix/natrix.dart';

final class NatrixPipeline {
  final List<String> _arguments;
  final List<Flag> _globalFlags;
  final NatrixTheme stencil;
  final NatrixParser parser;

  const NatrixPipeline({
    required List<String> arguments,
    this.parser = const NatrixParser(),
    this.stencil = const NatrixTheme(),
    List<Flag<dynamic>> globalFlags = const [],
  }) : _globalFlags = globalFlags,
       _arguments = arguments;

  /// Executes a [Command] with the arguments of the command line.
  ///
  /// [_globalFlags] are available for every command, regardless of [inheritFlags].
  Future<Response> run(Command command) async {
    final List<String> args = parser.mergeArguments(_arguments);

    Command cmd = command;
    final List<Flag> flags = _globalFlags.toList();

    bool found = true;
    int i = 0;
    while (found) {
      flags.addAll(cmd.flags);
      for (final Command s in cmd.subCommands) {
        found = s.use == args.elementAtOrNull(i);
        if (found) {
          cmd = s;
          i++;
          break;
        }
      }
      break;
    }
    Response? response;
    try {
      final NatrixOptions options = parser.parseOptions(args, flags);
      response = await command.run(
        NatrixInformation(command, options.arguments, options.flags),
      );
    } catch (e) {
      response = Response(e.toString(), Level.critical);
    }
    print(response.message);
    return response;
  }
}
