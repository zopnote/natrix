import 'package:natrix/src/core/flag.dart' show NatrixFlag;
import 'package:natrix/src/core/parser.dart' show NatrixParserOutput;
import 'package:natrix/src/core/command.dart' show NatrixCommand;
import 'package:natrix/src/core/text.dart' show NatrixText;

abstract class NatrixTheme {
  const NatrixTheme();

  NatrixSection get header;
  NatrixSection get footer;
  NatrixSection get commandUsage;
  NatrixSection get flags;
  NatrixSection get subCommands;
}

class NatrixContext {
  final NatrixCommand command;
  final NatrixParserOutput options;
  final int lineLength;
  final Iterable<NatrixFlag> globalFlags;

  const NatrixContext({
    required this.command,
    required this.options,
    required this.globalFlags,
    required this.lineLength,
  });
}
/**
 * Eine [NatrixSection] dient als Schnittstellendefinition für Objekte, die einen
 * Textabschnitt beschreiben.
 */
abstract interface class NatrixSection {
  const NatrixSection();
  /**
   * Gibt eine Ausgabebereite [List] an formatierten [NatrixText] zurück.
   */
  List<NatrixText> format();
}
