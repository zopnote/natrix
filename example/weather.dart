import 'dart:async';

import 'package:natrix/io.dart';

const List<String> spin = ["⣄", "⠇", "⠋", "⠙", "⠸", "⣠"];
final NatrixChar block = NatrixChar('▓');
final NatrixChar thin = NatrixChar('░');

final Map<String, NatrixText> languages = {
  "de": NatrixText.join([
    NatrixText(block.c, foreground: .grayDark),
    NatrixText(block.c, foreground: .red),
    NatrixText(block.c, foreground: .yellowAccent),
  ]),

  "en": NatrixText.join([
    NatrixText(block.c, foreground: .blue),
    NatrixText(block.c, foreground: .gray),
    NatrixText(block.c, foreground: .redAccent),
  ]),

  "fr": NatrixText.join([
    NatrixText(block.c, foreground: .blue),
    NatrixText(block.c, foreground: .gray),
    NatrixText(block.c, foreground: .red),
  ]),

  "es": NatrixText.join([
    NatrixText(block.c, foreground: .red),
    NatrixText(block.c, foreground: .yellowAccent),
    NatrixText(block.c, foreground: .red),
  ]),

  "it": NatrixText.join([
    NatrixText(block.c, foreground: .green),
    NatrixText(block.c, foreground: .gray),
    NatrixText(block.c, foreground: .red),
  ]),
};

Future<void> main(List<String> args) async {
  final NatrixStdio io = NatrixStdio();
  final (String input, NatrixMount inputMount) = io.requestInput(
    inputForegroundColor: .grayAccent,
    prefix: NatrixText("Select a region: ", style: .bold),
  );

  if (!languages.keys.contains(input)) {
    io.setLine(
      mount: inputMount,
      text: NatrixText("The specified region \"$input\" isn't available."),
    );
    return;
  }
  if (input.isNotEmpty) {
    io.setLine(
      mount: inputMount,
      text: NatrixText.join([
        NatrixText("Your selected region is "),
        NatrixText(input, foreground: .grayAccent),
        NatrixText(".  "),
        languages[input]!,
      ]),
    );
  }
  final NatrixMount bar = io.newLine();
  io.setLine(mount: bar, text: NatrixText(thin.c * 20));
  final NatrixMount spinner = io.newLine();
  int n = 0;
  io.setLine(mount: spinner, text: NatrixText("Retrieves weather ${spin[n]}"));
  for (int i = 0; i < 80; i++) {
    await Future.delayed(Duration(milliseconds: 75));
    io.setLine(
      mount: bar,
      text: NatrixText(
        block.c * (i / 4).round() + thin.c * (20 - (i / 4).round()),
      ),
    );
    io.setLine(
      mount: spinner,
      text: NatrixText("Retrieves weather ${spin[n++ >= 5 ? n = 0 : n]}"),
    );
  }
  io.setLine(mount: bar, text: NatrixText.empty());
  io.setLine(
    mount: spinner,
    text: NatrixText.join([
      NatrixText("Weather is "),
      NatrixText("sunny ☀️", foreground: .yellow),
    ]),
  );
}
