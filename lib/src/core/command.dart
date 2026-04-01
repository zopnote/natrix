import 'dart:async' show FutureOr;

import 'package:meta/meta.dart' show immutable;

import 'package:natrix/core.dart';

/**
 * Callback signature invoked when a [NatrixCommand] is selected during
 * pipeline traversal.
 */
typedef NatrixCommandCallback =
    FutureOr<void> Function(NatrixCallbackOptions options);

/**
 * Immutable descriptor for a single node in a hierarchical CLI command tree.
 *
 * [NatrixPipeline] walks this tree depth-first. It compares every
 * child's [id] to the next positional argument, descends into the first
 * match, and finally delegates execution to the deepest node reached.
 */
@immutable
class NatrixCommand {
  const NatrixCommand._internal({
    String? tooltip,
    this.parent,
    required this.id,
    required this.description,
    required this.hidden,
    required this.inheritFlags,
    required this.flags,
    required this.children,
    required this.callback,
    required this.argumentTip,
  }) : _tooltip = tooltip;

  factory NatrixCommand.new({
    required final String id,
    String? tooltip,
    required final String description,
    required final NatrixCommandCallback callback,
    final String argumentTip = "",
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

    return NatrixCommand._internal(
      id: id,
      tooltip: tooltip,
      description: description,
      hidden: hidden,
      argumentTip: argumentTip,
      inheritFlags: inheritFlags,
      flags: flags,
      children: children,
      callback: callback,
    );
  }
  /**
   * During processing within [NatrixPipeline], [NatrixCommand] will be
   * added as a parent to a new instance, corresponding to its parent
   * [NatrixCommand] in the CLI tree.
   */
  final NatrixCommand? parent;

  /**
   * The identifier matched against a positional argument during pipeline traversal.
   */
  final String id;

  /**
   * The [argumentTip] is a word that describes the argument in help requests
   * and briefly explains to the user what they should enter.
   */
  final String argumentTip;

  /**
   * A concise single-line summary displayed in abbreviated help contexts.
   */
  String get tooltip => _tooltip ?? description;
  final String? _tooltip;

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
   * [flags].
   */
  final bool inheritFlags;

  /**
   * The flags recognised when this command is the execution target.
   */
  final List<NatrixFlag> flags;

  /**
   * The sub-commands nested directly beneath this command inside pipeline traversal.
   */
  final Iterable<NatrixCommand> children;

  /**
   * The function executed when this command is selected as the final
   * target of pipeline resolution.
   */
  final NatrixCommandCallback callback;

  bool hasParent() => parent != null;
  bool hasChildren() => children.isNotEmpty;

  /**
   * Returns a copy of this command with the provided [parent] assigned.
   */
  NatrixCommand withParent([final NatrixCommand? parent]) =>
      NatrixCommand._internal(
        parent: parent,
        id: id,
        tooltip: _tooltip,
        argumentTip: argumentTip,
        description: description,
        hidden: hidden,
        inheritFlags: inheritFlags,
        flags: flags,
        children: children,
        callback: callback,
      );
}
