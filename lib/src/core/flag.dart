import 'package:meta/meta.dart';

import 'package:natrix/core.dart';
import 'package:natrix/src/core/misc.dart';

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

  String getTooltip({int maxLength = 37}) {
    if (tooltip.length < maxLength) {
      return tooltip;
    }
    int breakpoint = maxLength;
    int i = 0;
    while (true) {
      if (tooltip[i] == " ") {
        breakpoint = i;
      }
      if (i < maxLength - 1) {
        i++;
        continue;
      }
      return tooltip.cut(0, breakpoint) + "...";
    }
  }

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

/**
 * Flag implementation for string values.
 *
 * Accepts arbitrary text parameters such as file paths, names, or text literals.
 * The [parse] method handles escaped double quotes (`\"`), removing the escape
 * character while preserving the quote in the resulting value.
 */
final class NatrixTextFlag extends NatrixFlag<String> {
  const NatrixTextFlag({
    required super.id,
    super.acronym,
    super.tooltip,
    super.value = "",
  });

  String format(String value) => value;

  String parse(String raw) => simpleStringReduction(raw);

  @override
  NatrixFlag<String> set(String value) =>
      NatrixTextFlag(id: id, acronym: acronym, tooltip: tooltip, value: value);
}

/**
 * Flag für boolesche Werte (bool).
 *
 * ## Anwendung
 *
 * Verwenden Sie [NatrixBoolFlag] für einfache Schalter, die aktiviert
 * oder deaktiviert werden können.
 *
 * ## Beispiel
 *
 * ```dart
 * NatrixBoolFlag(
 *   id: "verbose",
 *   acronym: NatrixChar("v"),
 *   tooltip: "Ausführliche Ausgabe aktivieren",
 *   value: false,  // Standardwert (optional)
 * )
 * ```
 *
 * Aufruf: `programm --verbose` oder `programm -v` setzt das Flag auf `true`.
 *
 * ## Verhalten
 *
 * - Ohne Wert oder mit jedem Wert außer "false": Flag ist `true`
 * - Mit Wert "false": Flag ist `false`
 * - Beispiel: `--verbose false` ergibt `false`
 */
final class NatrixBoolFlag extends NatrixFlag<bool> {
  const NatrixBoolFlag({
    super.acronym,
    required super.id,
    super.value = false,
    super.tooltip,
  });
  String format(bool value) => value.toString();
  bool parse(String raw) => raw != "false" || raw.isEmpty;

  @override
  NatrixFlag<bool> set(bool value) =>
      NatrixBoolFlag(id: id, acronym: acronym, tooltip: tooltip, value: value);
}
