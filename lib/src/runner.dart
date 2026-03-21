import 'dart:async';
import 'dart:io';

import 'package:natrix/natrix.dart';

typedef VoidResponseCallback = FutureOr<void> Function(Response response);


abstract class NatrixStencil {
  const NatrixStencil();

}

final class ConfigurableNatrixStencil extends NatrixStencil {
  const ConfigurableNatrixStencil();
}

class NatrixPipeline {
  final List<String> _arguments;
  final List<Flag> _globalFlags;
  final NatrixStencil stencil;
  final VoidResponseCallback? _runAtEnd;

  const NatrixPipeline({
    required List<String> arguments,
    this.stencil = const ConfigurableNatrixStencil(),
    List<Flag<dynamic>> globalFlags = const [],
    FutureOr<void> Function(Response)? runAtEnd,
  }) : _runAtEnd = runAtEnd, _globalFlags = globalFlags, _arguments = arguments;

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

  /// Parses the flags from the arguments and sets the flags of list their values.
  void _parseAndSetFlags(
      final Iterable<String> flagArgs,
      final Iterable<Flag> flags,
      ) {
    for (final String flagArg in flagArgs) {
      final List<String> parts = flagArg.split("=");
      final String flagName = parts.first;
      String flagValue = "";
      if (parts.length == 1) {
        flagValue = "true";
      } else {
        flagValue = flagArg.substring(flagArg.indexOf("=") + 1);
      }
      Flag? flag;
      for (final iteratedFlag in flags) {
        if (iteratedFlag.name == flagName) {
          flag = iteratedFlag;
        }
      }

      if (flag == null) {
        stdout.writeln("$flagName is ignored in this context.");
        continue;
      }
      flag.setParsed(flagValue);
    }
  }


  /// Executes a [Command] with the arguments of the command line.
  ///
  /// [_globalFlags] are available for every command, regardless of [inheritFlags].
  Future<Response> run(Command command) async {
    List<Flag> flags = command.flags;
    List<String> passableArguments = const [];

    final List<String> mergedArgs = _mergeArguments(_arguments);
    final List<String> plainArgs = mergedArgs.where(
          (raw) => !raw.startsWith("--"),
    ).toList(growable: false);
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

    _parseAndSetFlags(flagArgs, flags);

    Response? response;
    try {
      response = await command.run(CommandInformation(command, passableArguments, flags));
    } catch (e) {
      response = Response(e.toString(), Level.critical);
    }
    await _runAtEnd?.call(response);
    return response;
  }
}
