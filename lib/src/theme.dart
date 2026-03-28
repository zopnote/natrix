import 'package:natrix/natrix.dart';
import 'package:natrix/src/writer.dart';

class NatrixHeader {
  final List<NatrixText> tooltip;
  final NatrixText usage;
  final List<NatrixText> description;
  final NatrixText? padding;

  const NatrixHeader({
    required this.tooltip,
    required this.usage,
    required this.description,
    this.padding,
  });
}

class NatrixSection {
  final NatrixText heading;
  final List<NatrixText> children;
  const NatrixSection({required this.heading, required this.children});
}

class NatrixThemeContext {
  final NatrixCommand cmd;
  final int terminalCharWidth;
  final Iterable<NatrixFlag> globalFlags;

  const NatrixThemeContext({
    required this.cmd,
    required this.globalFlags,
    required this.terminalCharWidth,
  });
}

abstract class NatrixTheme {
  const NatrixTheme();

  NatrixHeader header(NatrixThemeContext context);
  NatrixFooter footer(NatrixThemeContext context);
  NatrixText commandUsage(NatrixThemeContext context);
  NatrixSection flags(NatrixThemeContext context);
  NatrixSection subCommands(NatrixThemeContext context);
}

class NatrixFooter {
  final List<NatrixText> text;
  const NatrixFooter({required this.text});
}

/**
 * Renders a human-readable syntax reference for this command.
 *
 * The output begins with [description]. If [children] is non-empty an
 * "Available commands:" section follows, listing every non-[hidden] child
 * with identifiers padded to the length of the longest child [id]. When
 * [withFlags] is `true` and [flags] is non-empty a "Command avertable
 * flags:" section is appended, delegating to [NatrixFlag.syntaxString]
 * for each entry.
 *
 * [spacer] controls the column width reserved for flag identifiers and
 * is forwarded to [NatrixFlag.syntaxString]. Defaults to `13`.
 */
class NatrixDefaultTheme extends NatrixTheme {
  const NatrixDefaultTheme();
  @override
  NatrixHeader header(final NatrixThemeContext context) => NatrixHeader(
    tooltip: NatrixText(context.cmd.tooltip).wrap(context.terminalCharWidth),
    usage: commandUsage(context),
    description: NatrixText(
      context.cmd.description,
    ).wrap(context.terminalCharWidth),
    padding: const NatrixText.empty(),
  );

  @override
  NatrixFooter footer(_) => NatrixFooter(text: []);

  @override
  NatrixText commandUsage(final NatrixThemeContext c) {
    String out = "";
    NatrixCommand command = c.cmd;
    final List<String> arguments = [command.id];
    while (command.hasParent()) {
      command = command.parent!;
      arguments.add(command.id);
    }
    out += arguments.reversed.join(" ");
    if (c.cmd.children.isNotEmpty) {
      c.cmd.children.map((e) => e.id).join("|");
    }
    out += " <argument>";
    return NatrixText(out);
  }

  @override
  NatrixSection flags(NatrixThemeContext context) {
    // String output = "";
    // output += flag.acronym != null ? "-${flag.acronym}, " : " " * 4;
    // output += "--${flag.id}";
    // output += " " * (allowedUnitLength - flag.id.length - 2);
    // if (flag.tooltip.length > 50) {}
    return NatrixSection(
      heading: NatrixText("Flags:"),
      children: context.globalFlags.map((e) => NatrixText(e.id)).toList(),
    );
  }

  @override
  NatrixSection subCommands(NatrixThemeContext context) {
    return NatrixSection(
      heading: NatrixText("Commands:"),
      children: context.cmd.children.map((e) => NatrixText(e.id)).toList(),
    );
  }
}
