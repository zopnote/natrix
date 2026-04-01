import 'package:natrix/core.dart';

class NatrixContext {
  final NatrixCommand command;
  final NatrixParserOutput parserOutput;
  final Iterable<NatrixFlag> globalFlags;

  const NatrixContext({
    required this.command,
    required this.parserOutput,
    required this.globalFlags,
  });
}

class NatrixCallbackOptions {
  final NatrixCommand command;
  final List<String> arguments;
  final Iterable<NatrixFlag> flags;

  /**
   * Direct output of [NatrixParser.parse()].
   */
  final NatrixParserOutput _parserOutput;
  /**
   * Sublist of global [NatrixFlag] that are also in [flags].
   */
  final Iterable<NatrixFlag> _globalFlags;

  const NatrixCallbackOptions({
    required this.command,
    required this.arguments,
    required this.flags,
    required NatrixParserOutput parserOutput,
    required Iterable<NatrixFlag> globalFlags,
  }) : _globalFlags = globalFlags,
       _parserOutput = parserOutput;

  NatrixContext getContext() => NatrixContext(
    command: command,
    parserOutput: _parserOutput,
    globalFlags: _globalFlags,
  );

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
  final NatrixParser _parser;
  NatrixPipeline({
    required List<String> arguments,
    NatrixParser parser = const NatrixParser(),
    List<NatrixFlag> globalFlags = const [],
  }) : _parser = parser,
       _global = globalFlags,
       _arguments = arguments;

  Future<void> run(NatrixCommand command) async {
    final List<String> args = _parser.mergeArguments(_arguments);

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
    final NatrixParserOutput parserOutput = _parser.parse(args, flags);

    await command.callback(
      NatrixCallbackOptions(
        command: command,
        flags: parserOutput.flags,
        arguments: parserOutput.arguments,
        globalFlags: _global,
        parserOutput: parserOutput,
      ),
    );
  }
}
