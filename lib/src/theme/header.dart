import 'package:natrix/core.dart';
import 'package:natrix/theme.dart';

/**
 * Defines the text section that is typically returned when requesting an application note for a [NatrixCommand].
 */
class NatrixHeader implements NatrixSection {
  /**
   * A brief description of the [NatrixCommand].
   */
  final List<NatrixText> tooltip;

  /**
   * A brief, structured overview of the possible and correct uses of the [NatrixCommand].
   */
  final NatrixText usage;

  /**
   * A detailed description of the [NatrixCommand] to inform users
   * about how it works.
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

