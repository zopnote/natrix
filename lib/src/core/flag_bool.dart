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
