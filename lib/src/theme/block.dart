import 'package:natrix/core.dart';
import 'package:natrix/theme.dart';

/**
 * A section of text that requires a heading and spans multiple lines.
 *
 * For example, [NatrixBlock] is used for the section of text listing possible
 * subcommands or applicable [NatrixFlag]s.
 */
class NatrixBlock implements NatrixSection {
  /**
   * The heading of the text section.
   */
  final NatrixText heading;

  /**
   * The lines below the heading that belong to this section of text.
   */
  final NatrixStructure content;

  const NatrixBlock({required this.heading, required this.content});

  /**
   * An empty [NatrixBlock] with no [content] and no [heading].
   */
  factory NatrixBlock.empty() {
    return NatrixBlock(
      heading: NatrixText.empty(),
      content: NatrixStructure.empty(),
    );
  }

  List<NatrixText> format() {
    if (isEmpty) {
      return const [];
    }
    if (heading.isEmpty) {
      return content.format();
    }
    return [heading, ...content.format()];
  }

  @override
  bool get isEmpty => content.isEmpty;
}
