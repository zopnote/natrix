import 'package:natrix/src/core/text.dart' show NatrixChar;

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
  int get hashCode => Object.hash(id, tooltip, examples, parse, format);

  @override
  bool operator ==(Object other) {
    return identical(this, other);
  }

  @override
  String toString() => format(value);
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
  NatrixFlag<String> set(String value) =>
      NatrixTextFlag(id: id, acronym: acronym, tooltip: tooltip, value: value);
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
  NatrixFlag<bool> set(bool value) =>
      NatrixBoolFlag(id: id, acronym: acronym, tooltip: tooltip, value: value);
}
