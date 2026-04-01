import 'dart:io';

import 'package:natrix/core.dart';
import 'package:natrix/theme.dart';

class NatrixDefaultTheme extends NatrixTheme {
  late final int lineLength;
  final int maxCommandLength;
  final int maxFlagLength;

  NatrixDefaultTheme.of(
    super.context, {
    int lineLength = 50,
    this.maxCommandLength = 13,
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
    tooltip: NatrixText(context.command.tooltip).wrap(lineLength),
    usage: usage.text,
    description: NatrixText(context.command.description).wrap(lineLength),
  );

  @override
  NatrixLine get footer => NatrixLine(text: NatrixText.empty());

  @override
  NatrixLine get usage {
    String out = "Usage: ";
    NatrixCommand command = context.command;
    final List<String> arguments = [command.id];
    while (command.hasParent()) {
      command = command.parent!;
      arguments.add(command.id);
    }
    out += arguments.reversed.join(" ");
    if (context.command.children.isNotEmpty &&
        context.command.children.length < 4) {
      out += " <${context.command.children.map((e) => e.id).join("|")}>";
    }
    if (context.command.expectArgument) {
      out += " <${context.command.argumentName}>";
    }
    return NatrixText(out).asLineSection();
  }

  @override
  NatrixBlock get flags {
    final List<NatrixText> lines = [];
    for (final NatrixFlag f in context.command.flags) {
      String name = (f.hasAcronym ? "-${f.acronym!.c}, " : "") + "--${f.id}";
      name += " " * (maxFlagLength - name.length);
      final String tooltip = f.getTooltip(
        maxLength: lineLength - name.length - 1,
      );
      lines.add(NatrixText(name + tooltip));
    }
    ;
    return NatrixBlock(
      heading: NatrixText("Flags:", style: NatrixStyle.bold),
      content: NatrixStructure(
        spacePrefix: 1,
        sections: [NatrixColumn(lines: lines.toList())],
      ),
    );
  }

  NatrixBlock get globalFlags {
    return NatrixBlock(
      heading: NatrixText("Global flags:", style: NatrixStyle.bold),
      content: NatrixStructure(
        sections: context.globalFlags
            .map((e) => NatrixText(e.id).asLineSection())
            .toList(),
      ),
    );
  }

  @override
  NatrixBlock get commands {
    final List<NatrixText> lines = [];
    for (final NatrixCommand c in context.command.children) {
      final String name = c.id + " " * (maxCommandLength - c.id.length);
      final String tooltip = c.getTooltip(
        maxLength: lineLength - maxCommandLength - 1,
      );
      lines.add(NatrixText(name + tooltip));
    }
    return NatrixBlock(
      heading: NatrixText("Commands:", style: NatrixStyle.bold),
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
}
