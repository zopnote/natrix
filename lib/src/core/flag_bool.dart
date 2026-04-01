import 'package:natrix/core.dart';

/**
 * Flag for Boolean values (bool).
 *
 * Use [NatrixBoolFlag] for simple toggles that can be enabled
 * or disabled.
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
