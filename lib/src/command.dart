import 'dart:async';

import 'package:meta/meta.dart';

import 'package:natrix/natrix.dart';

extension NatrixStringCutExtension on String {
  String cut(int start, [int? end]) =>
      this.substring(start, (end ?? length).clamp(0, length));
}

/**
 * Callback signature invoked when a [NatrixCommand] is selected during
 * pipeline traversal.
 *
 * Receives the resolved [NatrixCommand] instance as [self], the positional [arguments] remaining after flag tokens have
 * been consumed, and the fully parsed [flags] collection whose values
 * can be retrieved via [NatrixIterableFlagExtension.get].
 *
 * Returns [FutureOr<void>] so that both synchronous and asynchronous
 * implementations are accepted without adaptation.
 */
typedef NatrixCommandCallback =
    FutureOr<void> Function(
      NatrixCommand self,
      List<String> arguments,
      Iterable<NatrixFlag> flags,
    );

/**
 * Immutable descriptor for a single node in a hierarchical CLI command tree.
 *
 * A [NatrixCommand] binds a unique string [id], human-readable metadata
 * ([description], [tooltip]), structural configuration ([flags], [children],
 * [inheritFlags], [hidden]), and an executable [callback] into one value
 * object.
 *
 * Commands form a tree: the root command (could be identified by an empty [id]) acts
 * as the application entry point, while each element in [children] represents
 * a sub-command that is matched against successive positional arguments at
 * runtime. [NatrixPipeline] walks this tree depth-first: it compares every
 * child's [id] to the next positional argument, descends into the first
 * match, and finally delegates execution to the deepest node reached.
 *
 *
 * ```dart
 * final clang = NatrixCommand(
 *   tooltip: "A C/C++/Objective-C compiler driver.",
 *   description: "A C language family frontend for LLVM.",
 *   flags: [
 *     NatrixBoolFlag(id: "version", acronym: NatrixChar("v"),
 *         tooltip: "Print the version string and exit."),
 *     NatrixBoolFlag(id: "help", acronym: NatrixChar("h"),
 *         tooltip: "Print this help message and exit."),
 *   ],
 *   children: [
 *     NatrixCommand(
 *       id: "compile",
 *       description: "Compile source files into object files.",
 *       inheritFlags: true,
 *       flags: [
 *         NatrixTextFlag(id: "output", acronym: NatrixChar("o"),
 *             tooltip: "Path to the output file."),
 *       ],
 *       callback: (self, arguments, flags) {
 *         final output = flags.get<String>("output").value;
 *       },
 *     ),
 *   ],
 *   callback: (self, arguments, flags) {},
 * );
 *
 * await NatrixPipeline(arguments: args).run(clang);
 * ```
 */
@immutable
class NatrixCommand {

  /**
   * The token matched against a positional argument during pipeline traversal.
   *
   * [NatrixPipeline] compares each child's [id] to the corresponding raw
   * argument to decide which branch to descend into.
   */
  final String id;

  /**
   * A concise single-line summary displayed in abbreviated help contexts.
   *
   * When omitted at construction time the factory truncates [description] to
   * its first characters.
   */
  final String tooltip;

  /**
   * A full-length explanation of the command's purpose and behaviour.
   */
  final String description;

  /**
   * Controls whether this command appears in sub-command listings.
   */
  final bool hidden;

  /**
   * Determines whether this command inherits its parent's flags.
   *
   * When `true`, [NatrixPipeline] merges the flags registered on ancestor
   * commands into this command's parsing context in addition to its own
   * [flags]. Defaults to `false`.
   */
  final bool inheritFlags;

  /**
   * The flags recognised when this command is the execution target.
   *
   * Every element must carry a unique [NatrixFlag.id] and, when set, a
   * unique [NatrixFlag.acronym] within the same list.
   */
  final List<NatrixFlag> flags;

  /**
   * The sub-commands nested directly beneath this command.
   *
   * [NatrixPipeline] iterates [children] to locate the first entry whose
   * [id] matches the next positional argument, then descends into that
   * child. Unreachable commands (not listed here) cannot be triggered
   * through standard pipeline execution.
   */
  final List<NatrixCommand> children;

  /**
   * The function executed when this command is selected as the final
   * target of pipeline resolution.
   *
   * See [NatrixCommandCallback] for the full signature contract.
   */
  final NatrixCommandCallback callback;

  const NatrixCommand._internal({
    required this.id,
    required this.tooltip,
    required this.description,
    required this.hidden,
    required this.inheritFlags,
    required this.flags,
    required this.children,
    required this.callback,
  });

  /**
   * Creates a validated [NatrixCommand].
   *
   * Parameter defaults and derivation rules:
   *
   * - [id] defaults to `""`, designating a root command.
   * - [tooltip] defaults to the first 37 characters of [description]
   *   followed by `"..."`.
   * - [hidden] is forced to `true` when [id] is empty; otherwise
   *   defaults to `false`.
   * - [inheritFlags] defaults to `false`.
   * - [flags] and [children] default to empty immutable lists.
   *
   * Throws an [Exception] if any two entries in [flags] share the same
   * [NatrixFlag.id] or [NatrixFlag.acronym].
   */
  factory NatrixCommand.new({
    final String id = "",
    String? tooltip,
    required final String description,
    required final NatrixCommandCallback callback,
    final bool inheritFlags = false,
    bool hidden = false,
    final List<NatrixFlag> flags = const [],
    final List<NatrixCommand> children = const [],
  }) {
    void same(final NatrixFlag a, final NatrixFlag b) {
      bool twin = a.id == b.id;
      twin = twin || a.acronym == b.acronym;
      if (twin) {
        throw Exception(
          "A conflict with the flag ${a.id} has been detected. "
          "Please change the relevant acronym or identifier.",
        );
      }
    }

    flags.forEach((f) => flags.where((o) => o != f).forEach((o) => same(f, o)));
    hidden = id.isEmpty || hidden;
    tooltip ??= description.cut(0, 37) + "...";

    return NatrixCommand._internal(
      id: id,
      tooltip: tooltip,
      description: description,
      hidden: hidden,
      inheritFlags: inheritFlags,
      flags: flags,
      children: children,
      callback: callback,
    );
  }

  /**
   * Renders a human-readable syntax reference for this command.
   *
   * The output begins with [description]. If [children] is non-empty an
   * "Available commands:" section follows, listing every non-[hidden] child
   * with identifiers padded to the length of the longest child [id]. When
   * [withFlags] is `true` and [flags] is non-empty a "Command avertable
   * flags:" section is appended, delegating to [NatrixFlag.syntaxString]
   * for each entry.
   *
   * [spacer] controls the column width reserved for flag identifiers and
   * is forwarded to [NatrixFlag.syntaxString]. Defaults to `13`.
   */
  String formatSyntax({final bool withFlags = true, final int spacer = 13}) {
    String syntax = "$description\n";
    if (children.isNotEmpty) {
      syntax = "$syntax\nAvailable commands:\n";
      int useLongest = 0;
      for (final NatrixCommand cmd in children) {
        if (cmd.id.length > useLongest) {
          useLongest = cmd.id.length;
        }
      }

      for (final NatrixCommand subCommand in children) {
        if (subCommand.hidden) continue;
        final int space = useLongest + 3 - subCommand.id.length;
        syntax =
            "$syntax${subCommand.id}${" " * space}${subCommand.description}\n";
      }
    }
    if (flags.isNotEmpty && withFlags) {
      syntax += "\nCommand avertable flags:\n";
      for (final NatrixFlag flag in flags) {
        syntax += "${flag.syntaxString(spacer: spacer)}\n";
      }
    }
    if (flags.isEmpty && children.isEmpty && !withFlags) {
      syntax += "\n";
    }
    return syntax;
  }
}
