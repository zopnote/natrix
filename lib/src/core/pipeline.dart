import 'dart:async';
import 'package:natrix/core.dart';

class FlagNotFoundException implements Exception {
  const FlagNotFoundException({
    required this.identifier,
    required this.superiorCommandIdentifier,
  });
  final String identifier;
  final String superiorCommandIdentifier;

  @override
  String toString() =>
      "The flag with the name \"$identifier\" couldn't be found.";
}

/**
 * The [NatrixContext] is primarily an interface for applications
 * outside the [NatrixPipeline] implementation to track the user's
 * command input.
 */
class NatrixContext {
  const NatrixContext({
    required this.cmd,
    required this.parserOutput,
    required this.globalFlags,
  });
  /**
   * The [NatrixCommand] called by the user.
   */
  final NatrixCommand cmd;

  /**
   * The output of the parsing process of the command line input,
   * which holds information related to the execution configuration.
   */
  final NatrixParserOutput parserOutput;
  /**
   * [globalFlags] is a [Iterable] with elements
   * that may occur in [parserOutput.args].
   *
   * The usage of [globalFlags] is related to specify which flags are global
   * to provide better help/usage-documentation for the user of the cli.
   */
  final Iterable<NatrixFlag> globalFlags;
}
/**
 * Data passed to the [NatrixCommandCallback] necessary for working with the
 * libraries internal and external definitions.
 */
class NatrixCallbackOptions {
  const NatrixCallbackOptions({
    required this.cmd,
    required this.args,
    required this.flags,
    required NatrixParserOutput parserOutput,
    required Iterable<NatrixFlag> globalFlags,
  }) : _globalFlags = globalFlags,
       _parserOutput = parserOutput;
  /**
   * The [NatrixCommand] which owns this callback
   * and it's position in the cli tree after pipeline traversal.
   */
  final NatrixCommand cmd;

  /**
   * A [List] of the parsed arguments from the command line.
   *
   * Doesn't contain command identifiers or flags and their values at all.
   */
  final List<String> args;

  /**
   * The flags of the command line input parsed from the predefined
   * [NatrixFlag]s of their corresponding [NatrixCommand] which
   * got mapped in [NatrixPipeline] traversal.
   */
  final Iterable<NatrixFlag> flags;

  /**
   * Direct output of [NatrixParser.parse()].
   */
  final NatrixParserOutput _parserOutput;
  /**
   * Sublist of global [NatrixFlag] that are also in [flags].
   */
  final Iterable<NatrixFlag> _globalFlags;

  /**
   * Retrieves the [NatrixContext] of the callback-given-metadata.
   */
  NatrixContext getContext() => NatrixContext(
    cmd: cmd,
    parserOutput: _parserOutput,
    globalFlags: _globalFlags,
  );

  /**
   * Returns a [NatrixFlag] casted as the [Type]
   * if the flag is available by it's identifier.
   *
   * All [NatrixFlag]s defined in the
   * superior CLI-tree (at least all superior if [inheritFlags = true])
   * are available here at all times.
   *
   * Throw
   */
  NatrixFlag<T> getFlag<T>(String name) {
    for (final NatrixFlag f in flags) {
      if (f.id == name) {
        return f as NatrixFlag<T>;
      }
    }
    throw FlagNotFoundException(
      identifier: name,
      superiorCommandIdentifier: this.cmd.id,
    );
  }
}

/**
 * The [NatrixPipeline] is relatively simple and
 * generally combines the subordinate steps,
 * bringing together the data and the command to be executed.
 */
final class NatrixPipeline {
  final List<String> _arguments;
  final Iterable<NatrixFlag> _global;
  final NatrixParser _parser;
  const NatrixPipeline({
    required List<String> arguments,
    NatrixParser parser = const NatrixParser(),
    List<NatrixFlag> globalFlags = const [],
  }) : _parser = parser,
       _global = globalFlags,
       _arguments = arguments;

  /**
   * Determines which [NatrixCommand] of a tree will be executed by the
   * arguments and applies these in parsed state to the command's [NatrixCommandCallback].
   */
  FutureOr<void> run(NatrixCommand cmd) async {
    final List<String> args = _parser.mergeArguments(_arguments);
    final List<NatrixFlag> flags = [];
    bool found = true;
    int i = 0;
    while (found) {
      flags.addAll(cmd.flags);
      for (final NatrixCommand s in cmd.children) {
        found = s.id == args.elementAtOrNull(i);
        if (found) {
          cmd = s.withParent(cmd);
          i++;
          break;
        }
      }
      break;
    }
    final NatrixParserOutput parserOutput = _parser.parse(args, flags);
    return cmd.callback(
      NatrixCallbackOptions(
        cmd: cmd,
        flags: parserOutput.flags,
        args: parserOutput.args,
        globalFlags: _global,
        parserOutput: parserOutput,
      ),
    );
  }
}
