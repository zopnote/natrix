import 'package:meta/meta.dart';

import 'package:natrix/core.dart';

/**
 * Typed command-line flag.
 *
 * Concrete implementations are used to define flags for [NatrixCommand] definitions.
 * Flags are matched during pipeline traversal via their [id] (long form: `--id`)
 * or their [acronym] (short form: `-a`).
 */
@immutable
abstract class NatrixFlag<T> {
  const NatrixFlag({
    required this.id,
    this.acronym,
    required this.value,
    this.examples = const [],
    this.tooltip = "",
  });

  /**
   * Unique identifier for the flag, used as long-form syntax in command-line
   * arguments (`--id`).
   */
  final String id;

  /**
   * Optional single-character shorthand for the flag, used as short-form
   * syntax in command-line arguments (`-a` where `a` is the [acronym] character).
   * Must be unique within a command's flag set.
   */
  final NatrixChar? acronym;

  /**
   * Brief description displayed in help output.
   */
  final String tooltip;

  /**
   * Current and/or initial value of the flag.
   */
  final T value;

  /**
   * Optional list of example values for help output generation.
   */
  final List<T> examples;

  /**
   * Returns the formatted string representation of the current [value].
   */
  String getFormatted() => format(value);

  /**
   * Returns formatted string representations of all [examples].
   */
  List<String> getExamplesFormatted() =>
      examples.map<String>((example) => format(example)).toList();

  /**
   * Parses a raw string from command-line arguments into type [T].
   *
   * Invoked internally by [NatrixPipeline] during argument processing.
   */
  T parse(String raw);

  /**
   * Formats a value of type [T] as a string for output or serialization.
   */
  String format(T value);

  /**
   * Returns a new instance of this flag with the specified [value].
   *
   * Invoked internally to produce updated flag instances after parsing.
   */
  NatrixFlag<T> set(T value);

  @override
  int get hashCode => Object.hash(id, tooltip, examples, parse, format);

  bool get hasAcronym => acronym != null;

  @override
  bool operator ==(Object other) {
    return identical(this, other);
  }

  @override
  String toString() => format(value);
}

