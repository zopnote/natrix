
/**
 * A flag is the base representation of a property given at the command line.
 *
 * It is intended to be extended for every special use case to deliver formatting
 * and parsing.
 */
abstract class Flag<T> {
  const Flag({
    required this.name,
    this.short,
    required this.value,
    this.examples = const [],
    this.description = "",
  });

  /**
   * The name of the flag, that have to be referenced
   * when typing in the command line.
   */
  final String name;

  /**
   * A shortage of the flags name, that have to be referenced
   * when typing in the command line.
   */
  final String? short;

  /**
   * Description of the flag, explaining the purpose of the property.
   *
   * It will be displayed as part of the help/syntax message.
   */
  final String description;

  /**
   * The mutable reference to the flags value.
   */
  final T value;

  /**
   * The flags example values done for guiding.
   */
  final List<T> examples;

  /**
   * Returns the flags value as a formatted string.
   */
  String getFormatted() => format(value);

  /**
   * Returns the flag example values as formatted strings.
   * If the examples are empty an empty list is returned.
   */
  List<String> getExamplesFormatted() =>
      examples.map<String>((example) => format(example)).toList();

  /**
   * Parses a string into the flags value type.
   * Returns the parsed value.
   */
  T parse(String raw);

  /**
   * Formats the flags value into a string,
   * that can be parsed by the Flag's [parse] function.
   */
  String format(T value);

  Flag<T> set(T value);

  @override
  int get hashCode => Object.hash(name, description, examples, parse, format);

  @override
  bool operator ==(Object other) {
    return identical(this, other);
  }

  @override
  String toString() => format(value);

  /**
   * Syntax message part describing the flag.
   *
   * Used as part of [Command.syntaxMessage()].
   */
  String syntaxString({final int spacer = 13}) {
    String syntax = "--${name}";
    final int space = spacer - name.length;
    if (description.isNotEmpty) {
      syntax = syntax + (" " * space) + "${description}";
    }
    if (examples.isNotEmpty) {
      syntax = syntax + " (examples: ${getExamplesFormatted().join(", ")})";
    }
    return syntax;
  }
}

/**
 * A flag that contains a [String] as it's value.
 */
final class TextFlag extends Flag<String> {
  const TextFlag({required super.name, super.short, super.description, super.value = ""});

  String format(String value) => value;

  String parse(String raw) {
    String o = "";
    int n = 0;
    for (int i = 0; i < raw.length; i++) {
      if (raw[i] != "\"") {
        o += raw[i];
        n++;
        continue;
      }
      if (i < 1) {
        continue;
      }
      if (raw[i - 1] != "\\") {
        continue;
      }
      o = o.substring(0, n - 1);
      o += raw[i];
    }
    return o;
  }

  @override
  Flag<String> set(String value) =>
      TextFlag(name: name, short: short, description: description, value: value);
}

/**
 * A flag representing a boolean value.
 *
 * Whenever the flag is provided in command line,
 * it is interpreted as true, even without specifying it directly.
 */
final class BoolFlag extends Flag<bool> {
  const BoolFlag({
    super.short,
    required super.name,
    super.value = false,
    super.description,
  });
  String format(bool value) => value.toString();
  bool parse(String raw) => raw != "false" || raw.isEmpty;

  @override
  Flag<bool> set(bool value) => BoolFlag(
    name: name,
    short: short,
    description: description,
    value: value,
  );
}
