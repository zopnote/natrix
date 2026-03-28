import 'dart:io' as io show stdout, stderr, stdin;

import 'package:natrix/natrix.dart';

class NatrixMount {
  final int position;
  final NatrixOutput output;
  const NatrixMount({required this.position, required this.output});
  @override
  int get hashCode => Object.hash(position, output);
  @override
  bool operator ==(Object other) {
    if (other is! NatrixMount) {
      return false;
    }
    return this.position == other.position && this.output == other.output;
  }
}

class NatrixOutput {
  static final NatrixOutput stderr = NatrixOutput(io.stderr);
  static final NatrixOutput stdout = NatrixOutput(io.stdout);

  const NatrixOutput(this.stream);
  final StringSink stream;

  @override
  int get hashCode => stream.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! NatrixOutput) {
      return false;
    }
    return this.stream == other.stream;
  }
}

class NatrixStdio {
  int totalLinesWritten = 0;

  (String, NatrixMount) requestInput({
    final NatrixText prefix = const NatrixText.empty(),
    NatrixColor inputForegroundColor = .none,
    NatrixColor inputBackgroundColor = .none,
    NatrixStyle inputStyle = .none,
    final bool hideInput = false,
  }) {
    if (!prefix.valid()) {
      throw Exception(_invalidMessage(prefix));
    }
    final bool initEcho = io.stdin.echoMode;
    final bool initLine = io.stdin.lineMode;
    if (hideInput) {
      io.stdin.echoMode = false;
      io.stdin.lineMode = true;
    }
    final NatrixMount mount = NatrixMount(
      position: totalLinesWritten++,
      output: NatrixOutput.stdout,
    );
    mount.output.stream.write(
      "${prefix.ansi}"
      "${inputForegroundColor.ansiForegroundSequence}"
      "${inputBackgroundColor.ansiBackgroundSequence}"
      "${inputStyle.ansiStartSequence}",
    );
    final String input = io.stdin.readLineSync() ?? "";
    mount.output.stream.write(
      "${inputStyle.ansiResetSequence}"
      "${inputBackgroundColor.ansiResetBackgroundSequence}"
      "${inputForegroundColor.ansiResetForegroundSequence}",
    );

    if (hideInput) {
      io.stdin.echoMode = initEcho;
      io.stdin.lineMode = initLine;
    }
    return (input, mount);
  }

  NatrixMount newLine({
    final NatrixText text = const NatrixText.empty(),
    final NatrixOutput? output,
  }) {
    if (!text.valid()) {
      throw Exception(_invalidMessage(text));
    }
    final NatrixMount mount = NatrixMount(
      position: totalLinesWritten++,
      output: output ?? NatrixOutput.stdout,
    );
    mount.output.stream.write("${text.ansi}\n");
    return mount;
  }

  void setLine({
    required final NatrixMount mount,
    final NatrixText text = const NatrixText.empty(),
  }) {
    if (!text.valid()) {
      throw Exception(_invalidMessage(text));
    }
    final int d = totalLinesWritten - mount.position;
    mount.output.stream.write("\x1B[${d}F\x1B[2K${text}\x1B[${d}E");
  }

  static String _invalidMessage(Object content) =>
      "Unallowed character inside \"$content\". "
      "There can't be terminal codes that manipulate the "
      "output other than color codes. "
      "Remove ANSI sequences, unix operations and line breaks.";
  @override
  bool operator ==(Object other) {
    throw Exception(
      "It makes no sense to check whether two NatrixWriters are equal.",
    );
  }

  @override
  int get hashCode => totalLinesWritten.hashCode;
}

class NatrixText {
  final NatrixColor background;
  final NatrixColor foreground;
  final NatrixStyle style;
  final String text;

  String get ansi =>
      style.apply(background.colorize(foreground.colorize(text)));

  const NatrixText(
    this.text, {
    this.foreground = .none,
    this.background = .none,
    this.style = .none,
  });
  const NatrixText.empty()
    : text = "",
      foreground = .none,
      background = .none,
      style = .none;
  factory NatrixText.join(List<NatrixText> components) {
    String s = "";
    components.forEach((c) => s += c.ansi);
    return NatrixText(s);
  }

  bool valid() =>
      !RegExp(r'\x1B$$[0-9;]*[^m]').hasMatch(text) &&
      !text.contains("\n") &&
      !text.contains("\r");

  List<NatrixText> wrap(final int maxLength) {
    final double a = ansi.length / maxLength;
    if (a.round() < 1.0) {
      return [this];
    }
    final List<NatrixText> texts = [];
    String b = ansi;
    for (int i = 0; i < a.round(); i++) {
      final String c = b.cut(0, maxLength);
      texts.add(NatrixText(c));
      b = b.cut(maxLength);
    }
    return texts;
  }

  @override
  String toString() => ansi;

  @override
  bool operator ==(Object other) {
    if (other is String) {
      return ansi == other;
    }
    if (other is! NatrixText) {
      return false;
    }
    return ansi == other.ansi;
  }

  @override
  int get hashCode => ansi.hashCode;
}

enum NatrixStyle {
  none(-1, -1),
  bold(1, 22),
  italic(3, 23),
  underline(4, 24),
  blink(5, 25),
  reverse(7, 27),
  hidden(8, 28),
  strikethrough(9, 29);

  final int startCode;
  final int resetCode;
  String get ansiStartSequence => startCode == -1 ? "" : "\x1B[${startCode}m";
  String get ansiResetSequence => resetCode == -1 ? "" : "\x1B[${resetCode}m";
  const NatrixStyle(this.startCode, this.resetCode);
  String apply(String text) => "$ansiStartSequence$text$ansiResetSequence";
}

enum NatrixColor {
  none(-1),
  grayDark(236),
  gray(250),
  grayAccent(244),
  redDark(88),
  red(210),
  redAccent(196),
  orangeDark(130),
  orange(216),
  orangeAccent(208),
  yellowDark(136),
  yellow(229),
  yellowAccent(226),
  greenDark(22),
  green(120),
  greenAccent(46),
  cyanDark(30),
  cyan(159),
  cyanAccent(51),
  blueDark(18),
  blue(153),
  blueAccent(21),
  purpleDark(54),
  purple(183),
  purpleAccent(93),
  pinkDark(125),
  pink(218),
  pinkAccent(201);

  String get ansiResetForegroundSequence => value == -1 ? "" : "\x1B[39m";
  String get ansiResetBackgroundSequence => value == -1 ? "" : "\x1B[49m";
  final int value;
  String get ansiForegroundSequence => value == -1 ? "" : "\x1B[38;5;${value}m";
  String get ansiBackgroundSequence => value == -1 ? "" : "\x1B[48;5;${value}m";
  const NatrixColor(this.value);
  String colorize(String text) =>
      "$ansiForegroundSequence$text$ansiResetForegroundSequence";
}
