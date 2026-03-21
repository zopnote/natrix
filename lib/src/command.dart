import 'dart:async';

import '../natrix.dart';


/// An action, callable by a user of the command line environment.
///
/// Whenever building a cli application, you need an entry point for
/// the functionality your app provides. To make an app more complex and
/// flexible you can nest commands into superordinary ones.
/// Therefore you command tree is the interface for the user of your
/// application to prompt it's features.
///
/// Stepflow provides you this structure by it's [Command].
class Command {
  /// Instantiates a command with the given values.
  /// A command is an action, callable inside the cli.
  Command({
    this.use = "",
    required this.short,
    required this.description,
    required this.run,
    this.inheritFlags = false,
    this.hidden = false,
    this.flags = const [],
    this.subCommands = const [],
  }) {
    if (use.length > 15) {
      throw Exception(
        "The usage of a command shouldn't be longer than 15 characters.",
      );
    }
  }

  /// The name of this command.
  /// Will be the usage in command line
  /// and get's parsed of the arguments.
  /// Maximal length of 15 characters.
  final String use;

  /// A short description of the command and
  /// it's functionality for guidance and documentation.
  final String short;

  /// A long description of the command and
  /// it's functionality for guidance and documentation.
  final String description;

  /// Whether the command is hidden from help listings.
  final bool hidden;

  /// Flags available to the command.
  List<Flag> flags;

  /// Whether this command inherits flags from a parent.
  final bool inheritFlags;

  /// Subcommands under this command.
  final List<Command> subCommands;

  /// Execution function invoked with the parsed context.
  final FutureOr<Response> Function(CommandInformation context) run;

  /// Returns a help message describing the
  /// usage of the command and it's available flags.
  ///
  /// [withFlags] will decide if the flags should
  /// also be printed into the syntax.
  String formatSyntax({final bool withFlags = true, final int spacer = 13}) {
    String syntax = "$description\n";
    if (subCommands.isNotEmpty) {
      syntax = "$syntax\nAvailable commands:\n";
      int useLongest = 0;
      for (final Command cmd in subCommands) {
        if (cmd.use.length > useLongest) {
          useLongest = cmd.use.length;
        }
      }
      for (final Command subCommand in subCommands) {
        if (subCommand.hidden) continue;
        final int space = useLongest + 3 - subCommand.use.length;
        syntax =
            "$syntax${subCommand.use}${" " * space}${subCommand.description}\n";
      }
    }
    if (flags.isNotEmpty && withFlags) {
      syntax += "\nCommand avertable flags:\n";
      for (final Flag flag in flags) {
        syntax += "${flag.syntaxString(spacer: spacer)}\n";
      }
    }
    if (flags.isEmpty && subCommands.isEmpty && !withFlags) {
      syntax += "\n";
    }
    return syntax;
  }
}

/// Information about the context of execution of a command line prompt.
final class CommandInformation {
  final Command command;
  final List<String> arguments;
  final List<Flag> flags;

  CommandInformation(this.command, this.arguments, this.flags);

  /// Returns a help message describing usage and available flags.
  String formatSyntax() {
    String syntax = "";
    syntax += command.formatSyntax(withFlags: false);
    if (flags.isNotEmpty) {
      syntax += "Flags:\n";
      for (final Flag flag in flags) {
        syntax += "${flag.syntaxString()}\n";
      }
    }
    return syntax;
  }

  /// Retrieves a flag by name and casts it to type T.
  ///
  /// Throws [Exception] if flag is not found.
  Flag<T> getFlag<T>(String name) => _getFlagOfList<T>(flags, name);

  /// Retrieves a flag by name and casts it to type T.
  ///
  /// Throws [Exception] if flag is not found.
  static Flag<T> _getFlagOfList<T>(final List<Flag> flags, final String name) {
    for (final Flag flag in flags) {
      if (flag.name == name) {
        return flag as Flag<T>;
      }
    }
    throw Exception(
      "There isn't a flag found with the name \"$name\" in the given list.",
    );
  }
}
