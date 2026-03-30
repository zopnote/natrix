import 'dart:io';

import 'package:natrix/core.dart';
import 'package:natrix/io.dart';
import 'clang_cli.dart';

void main(List<String> arguments) {
  final NatrixDefaultTheme theme = NatrixDefaultTheme(
    NatrixContext(
      command: clang,
      globalFlags: [],
      lineLength: stdout.terminalColumns,
      options: NatrixParserOutput(),
    ),
  );
  final NatrixStdio io = NatrixStdio();
  io.writeLines(lines: theme.header.format());
}
