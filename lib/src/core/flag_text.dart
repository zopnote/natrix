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

