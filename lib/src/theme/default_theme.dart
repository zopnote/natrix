import 'dart:io';

import 'package:natrix/core.dart';
import 'package:natrix/theme.dart';

class NatrixDefaultTheme extends NatrixTheme {
  late final int lineLength;
  final int maxCmdLength;
  final int maxFlagLength;

  NatrixDefaultTheme.of(
    super.context, {
    int lineLength = 65,
    this.maxCmdLength = 13,
    this.maxFlagLength = 18,
  }) : super.of() {
    try {
      this.lineLength = stdout.terminalColumns;
    } on StdoutException {
      this.lineLength = lineLength;
    }
  }

  @override
  NatrixHeader get header => NatrixHeader(
    tooltip: NatrixColumn(
      lines: NatrixText(context.cmd.tooltip).wrap(lineLength),
    ),
    usage: usage.text,
    description: context.cmd.hasTooltip()
        ? NatrixColumn(
            lines: NatrixText(context.cmd.description).wrap(lineLength),
          )
        : NatrixBlock.empty(),
  );

  @override
  NatrixSection get footer => NatrixLine(text: NatrixText.empty());

  @override
  NatrixLine get usage {
    NatrixText usage = NatrixText("Usage: ", style: .bold);
    NatrixCommand command = context.cmd;
    final List<String> cmds = [command.id];
    while (command.hasParent()) {
      command = command.parent!;
      cmds.add(command.id);
    }
    String out = "";
    out += cmds.reversed.join(" ");
    if (context.cmd.children.isNotEmpty && context.cmd.children.length < 4) {
      out += " <${context.cmd.children.map((e) => e.id).join("|")}>";
    }
    if (context.cmd.argumentTip.isNotEmpty) {
      out += " <${context.cmd.argumentTip}>";
    }
    return NatrixText.join([usage, NatrixText(out)]).asLineSection();
  }

  @override
  NatrixBlock get flags {
    final List<NatrixFlag> flags = context.parserOutput.flags
        .where((e) => !context.globalFlags.map((g) => g.id).contains(e.id))
        .toList();
    if (flags.isEmpty) {
      return NatrixBlock.empty();
    }
    final List<NatrixText> lines = [];
    _add(Iterable<NatrixFlag> flags) => flags.forEach((flag) {
      String name = "";
      if (flag.hasAcronym) {
        name += "-${flag.acronym!.c}, ";
      } else {
        name += " " * 4;
      }
      name += "--${flag.id}";
      name += " " * (maxFlagLength - name.length);
      final List<NatrixText> tooltip = NatrixText(
        flag.tooltip,
      ).wrap(lineLength - name.length - 1);

      bool first = true;
      tooltip.forEach((tip) {
        if (first) {
          lines.add(NatrixText(name + tip.text));
          first = !first;
          return;
        }
        lines.add(NatrixText(NatrixChar(' ') * (name.length) + tip.text));
      });
    });
    _add(flags.where((e) => e.hasAcronym));
    _add(flags.where((e) => !e.hasAcronym));
    return NatrixBlock(
      heading: NatrixText("Flags:", style: NatrixStyle.bold),
      content: NatrixStructure(
        spacePrefix: 1,
        sections: [NatrixColumn(lines: lines.toList())],
      ),
    );
  }

  @override
  NatrixBlock get commands {
    if (!context.cmd.hasChildren()) {
      return NatrixBlock.empty();
    }

    final List<NatrixText> lines = [];
    context.cmd.children.forEach((cmd) {
      final String name = cmd.id + " " * (maxCmdLength - cmd.id.length);
      final List<NatrixText> tooltip = NatrixText(
        cmd.tooltip,
      ).wrap(lineLength - name.length - 1);

      bool first = true;
      tooltip.forEach((tip) {
        if (first) {
          lines.add(NatrixText(name + tip.text));
          first = false;
          return;
        }
        lines.add(NatrixText(NatrixChar(' ') * (name.length) + tip.text));
      });
    });
    return NatrixBlock(
      heading: NatrixText("Commands:", style: NatrixStyle.bold),
      content: NatrixStructure(
        spacePrefix: 1,
        sections: [NatrixColumn(lines: lines.toList())],
      ),
    );
  }

  NatrixBlock get globalFlags {
    final List<NatrixText> lines = [];
    if (context.globalFlags.isEmpty) {
      return NatrixBlock.empty();
    }
    _add(Iterable<NatrixFlag> flags) => flags.forEach((flag) {
      String name = "";
      if (flag.hasAcronym) {
        name += "-${flag.acronym!.c}, ";
      } else {
        name += " " * 4;
      }
      name += "--${flag.id}";
      name += " " * (maxFlagLength - name.length);
      final List<NatrixText> tooltip = NatrixText(
        flag.tooltip,
      ).wrap(lineLength - name.length - 1);

      bool first = true;
      tooltip.forEach((tip) {
        if (first) {
          lines.add(NatrixText(name + tip.text));
          first = !first;
          return;
        }
        lines.add(NatrixText(NatrixChar(' ') * (name.length) + tip.text));
      });
    });
    _add(context.globalFlags.where((e) => e.hasAcronym));
    _add(context.globalFlags.where((e) => !e.hasAcronym));
    return NatrixBlock(
      heading: NatrixText("Global Flags:", style: NatrixStyle.bold),
      content: NatrixStructure(
        spacePrefix: 1,
        sections: [NatrixColumn(lines: lines.toList())],
      ),
    );
  }

  @override
  NatrixDocument get root {
    return NatrixDocument(
      header: header,
      content: NatrixStructure(
        padding: 1,
        sections: [globalFlags, flags, commands],
      ),
      footer: footer,
    );
  }

  @override
  NatrixSection get syntax => throw UnimplementedError();
}
