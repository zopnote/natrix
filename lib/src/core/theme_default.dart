import 'package:natrix/src/core/text.dart' show NatrixText;

class NatrixDefaultTheme implements NatrixTheme {
  final NatrixContext context;
  const NatrixDefaultTheme(this.context);

  @override
  NatrixDefaultHeader get header => NatrixDefaultHeader(
    tooltip: NatrixText(context.command.tooltip).wrap(context.lineLength),
    usage: commandUsage.text,
    description: NatrixText(
      context.command.description,
    ).wrap(context.lineLength),
  );

  @override
  NatrixDefaultFooter get footer => NatrixDefaultFooter(text: []);

  @override
  NatrixDefaultLine get commandUsage {
    String out = "Usage: ";
    NatrixCommand command = context.command;
    final List<String> arguments = [command.id];
    while (command.hasParent()) {
      command = command.parent!;
      arguments.add(command.id);
    }
    out += arguments.reversed.join(" ");
    if (context.command.children.isNotEmpty) {
      out += " <${context.command.children.map((e) => e.id).join("|")}>";
    }
    out += " <argument>";
    return NatrixDefaultLine(NatrixText(out));
  }

  @override
  NatrixDefaultBlock get flags {
    // String output = "";
    // output += flag.acronym != null ? "-${flag.acronym}, " : " " * 4;
    // output += "--${flag.id}";
    // output += " " * (allowedUnitLength - flag.id.length - 2);
    // if (flag.tooltip.length > 50) {}
    return NatrixDefaultBlock(
      heading: NatrixText("Flags:"),
      lines: context.globalFlags.map((e) => NatrixText(e.id)).toList(),
    );
  }

  @override
  NatrixDefaultBlock get subCommands {
    return NatrixDefaultBlock(
      heading: NatrixText("Commands:"),
      lines: context.command.children.map((e) => NatrixText(e.id)).toList(),
    );
  }
}
/**
 * Beschreibt einen Textabschnitt, der nur eine Zeile beträgt.
 */
class NatrixDefaultLine implements NatrixSection {
  final NatrixText text;
  const NatrixDefaultLine(this.text);
  @override
  List<NatrixText> format() => [text];
}

/**
 * Definiert den Textabschnitt, der vorwiegend bei der Anfrage eines
 * Anwendungshinweises eines [NatrixCommand] zurückgegeben wird.
 */
class NatrixDefaultHeader implements NatrixSection {
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

  const NatrixDefaultHeader({
    required this.tooltip,
    required this.usage,
    required this.description,
  });

  List<NatrixText> format() => [
    ...tooltip,
    NatrixText.empty(),
    usage,
    NatrixText.empty(),
    ...description,
  ];
}

/**
 * Ein Textabschnitt, der einer Überschrift bedarf und mehrere Zeilen
 * umfasst.
 *
 * Beispielsweise dient [NatrixDefaultBlock] dem Textabschnitt der möglichen
 * Unterbefehle oder Anwendbaren [NatrixFlag]s.
 */
class NatrixDefaultBlock implements NatrixSection {
  /**
   * Die Überschrift des Textabschnitts.
   */
  final NatrixText heading;

  /**
   * Die Zeilen unterhalb der Überschrift, die dem Textabschnitt zuzuordnen sind.
   */
  final List<NatrixText> lines;
  const NatrixDefaultBlock({required this.heading, required this.lines});

  List<NatrixText> format() => [heading, ...lines];
}

/**
 *
 */
class NatrixDefaultFooter implements NatrixSection {
  final List<NatrixText> text;
  const NatrixDefaultFooter({required this.text});
  @override
  List<NatrixText> format() => text;
}
