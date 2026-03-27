import 'package:meta/meta.dart';

extension NatrixIterableFlagExtension on Iterable<NatrixFlag> {
  NatrixFlag<T> get<T>(String name) {
    for (final f in this) {
      if (f.id == name) {
        return f as NatrixFlag<T>;
      }
    }
    throw Exception(
      "There isn't a flag found with the name \"$name\" in the given list.",
    );
  }
}

@immutable
class NatrixChar {
  final String c;
  NatrixChar(this.c) {
    if (c.length > 1) {
      throw Exception("A character cannot be longer than 1 unit.");
    }
  }

  @override
  bool operator ==(Object other) => c == other;

  String operator *(int times) => c * times;

  String operator +(String other) => c + other;

  @override
  String toString() => c;
}

abstract class NatrixFlag<T> {
  const NatrixFlag({
    required this.id,
    this.acronym,
    required this.value,
    this.examples = const [],
    this.tooltip = "",
  });

  final String id;

  final NatrixChar? acronym;

  final String tooltip;

  final T value;

  final List<T> examples;

  String getFormatted() => format(value);

  List<String> getExamplesFormatted() =>
      examples.map<String>((example) => format(example)).toList();

  T parse(String raw);

  String format(T value);

  NatrixFlag<T> set(T value);

  @override
  int get hashCode =>
      Object.hash(id, tooltip, examples, parse, format);

  @override
  bool operator ==(Object other) {
    return identical(this, other);
  }

  @override
  String toString() => format(value);

  String syntaxString({final int spacer = 13}) {
    String syntax = "--${id}";
    final int space = spacer - id.length;
    if (tooltip.isNotEmpty) {
      syntax = syntax + (" " * space) + "${tooltip}";
    }
    if (examples.isNotEmpty) {
      syntax = syntax + " (examples: ${getExamplesFormatted().join(", ")})";
    }
    return syntax;
  }
}

final class NatrixTextFlag extends NatrixFlag<String> {
  const NatrixTextFlag({
    required super.id,
    super.acronym,
    super.tooltip,
    super.value = "",
  });

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
  NatrixFlag<String> set(String value) => NatrixTextFlag(
    id: id,
    acronym: acronym,
    tooltip: tooltip,
    value: value,
  );
}

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
  NatrixFlag<bool> set(bool value) => NatrixBoolFlag(
    id: id,
    acronym: acronym,
    tooltip: tooltip,
    value: value,
  );
}
