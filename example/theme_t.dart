

import 'package:natrix/natrix.dart';
import 'clang_cli.dart';

void main(List<String> arguments) {
  NatrixDefaultTheme theme = NatrixDefaultTheme();
  NatrixThemeContext context = NatrixThemeContext(
      cmd: clang, globalFlags: [], terminalCharWidth: 60);
  print(theme.header(context));
}