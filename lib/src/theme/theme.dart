import 'package:natrix/core.dart';

abstract class NatrixTheme {
  final NatrixContext context;
  const NatrixTheme.of(this.context);
  NatrixSection get root;
  NatrixSection get header;
  NatrixSection get footer;
  NatrixSection get usage;
  NatrixSection get flags;
  NatrixSection get commands;
}

/**
 * Eine [NatrixSection] dient als Schnittstellendefinition für Objekte, die einen
 * Textabschnitt beschreiben.
 */
abstract interface class NatrixSection {
  const NatrixSection();
  bool get isEmpty;
  /**
   * Gibt eine Ausgabebereite [List] an formatierten [NatrixText] zurück.
   */
  List<NatrixText> format();
}

class NatrixStructure implements NatrixSection {
  final List<NatrixSection> sections;
  final int padding;
  final int spacePrefix;
  const NatrixStructure({
    required this.sections,
    this.padding = 1,
    this.spacePrefix = 0,
  });

  const NatrixStructure.empty()
    : sections = const [],
      padding = 0,
      spacePrefix = 0;

  bool get isEmpty => sections.isEmpty;

  @override
  List<NatrixText> format() {
    if (sections.isEmpty) {
      return const [];
    }

    final List<NatrixText> o = [];
    final NatrixText p = NatrixText(' ') * spacePrefix;
    int i = 0;
    void _addPadding() {
      int n = 0;
      for (;;) {
        if (n >= padding) {
          break;
        }
        o.add(NatrixText.empty());
        n++;
      }
    }

    final List<NatrixSection> notEmptySections = [];
    sections.forEach((e) => !e.isEmpty ? notEmptySections.add(e) : null);
    for (final NatrixSection s in notEmptySections) {
      final List<NatrixText> sectionItems = s.format();
      sectionItems.forEach((t) => o.add(p + t));
      if (i < notEmptySections.length - 1) {
        _addPadding();
      }
      i++;
    }
    return o;
  }
}

class NatrixLine extends NatrixSection {
  final NatrixText text;

  const NatrixLine({required this.text});
  const NatrixLine.empty() : text = const NatrixText.empty();
  @override
  List<NatrixText> format() => isEmpty ? [] : [text];

  @override
  bool get isEmpty => text.isEmpty;
}

extension NatrixTextFormatExtension on NatrixText {
  List<NatrixText> format() => isEmpty ? const [] : [this];
  NatrixLine asLineSection() => NatrixLine(text: this);
}

class NatrixColumn implements NatrixSection {
  final List<NatrixText> lines;
  const NatrixColumn({required this.lines});
  @override
  List<NatrixText> format() {
    if (isEmpty) {
      return const [];
    }
    final List<NatrixText> o = [];
    lines.forEach((l) => o.addAll(l.format()));
    return o;
  }

  @override
  bool get isEmpty => lines.isEmpty;
}

class NatrixDocument implements NatrixSection {
  final NatrixSection header;
  final NatrixStructure content;
  final NatrixSection footer;

  const NatrixDocument({
    required this.header,
    required this.content,
    required this.footer,
  });
  @override
  List<NatrixText> format() =>
      NatrixStructure(padding: 1, sections: [header, content, footer]).format();

  @override
  bool get isEmpty => header.isEmpty && content.isEmpty && footer.isEmpty;
}

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

/**
 * Ein Textabschnitt, der einer Überschrift bedarf und mehrere Zeilen
 * umfasst.
 *
 * Beispielsweise dient [NatrixBlock] dem Textabschnitt der möglichen
 * Unterbefehle oder Anwendbaren [NatrixFlag]s.
 */
class NatrixBlock implements NatrixSection {
  /**
   * Die Überschrift des Textabschnitts.
   */
  final NatrixText heading;

  /**
   * Die Zeilen unterhalb der Überschrift, die dem Textabschnitt zuzuordnen sind.
   */
  final NatrixStructure content;
  const NatrixBlock({required this.heading, required this.content});
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
