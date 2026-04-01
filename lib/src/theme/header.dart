import 'package:natrix/core.dart';
import 'package:natrix/theme.dart';

/**
 * Definiert den Textabschnitt, der vorwiegend bei der Anfrage eines
 * Anwendungshinweises eines [NatrixCommand] zurückgegeben wird.
 */
class NatrixHeader implements NatrixSection {
  /**
   * Eine kurze Beschreibung des [NatrixCommand].
   */
  final List<NatrixText> tooltip;

  /**
   * Eine formatierte und kurze Darstellung der möglichen und richtigen Anwendung
   * des [NatrixCommand].
   */
  final NatrixText usage;

  /**
   * Eine ausführliche Beschreibung des [NatrixCommand] um Nutzern
   * über sein jeweiliges Verhalten aufzuklären.
   */
  final List<NatrixText> description;

  const NatrixHeader({
    required this.tooltip,
    required this.usage,
    required this.description,
  });

  List<NatrixText> format() => isEmpty
      ? NatrixBlock.empty().format()
      : NatrixStructure(
    sections: [
      NatrixColumn(lines: tooltip.toList()),
      usage.asLineSection(),
      NatrixColumn(lines: description.toList()),
    ],
  ).format();

  @override
  bool get isEmpty => tooltip.isEmpty && usage.isEmpty && description.isEmpty;
}

