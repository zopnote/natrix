import 'package:meta/meta.dart' show immutable;
import 'package:natrix/src/core/misc.dart' show NatrixStringCutExtension;
@immutable
class NatrixChar {
  final String c;
  NatrixChar(this.c) {
    if (c.length > 1) {
      throw Exception("A character cannot be longer than 1 unit.");
    }
  }

  @override
  bool operator ==(Object other) => c == other;

  String operator *(int times) => c * times;

  String operator +(String other) => c + other;

  @override
  String toString() => c;
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
    if (ansi.length < maxLength) {
      return [this];
    }
    final List<NatrixText> texts = [];

    String buffer = ansi;
    int breakpoint = 0;
    int count = 0;
    while (count < buffer.length) {
      breakpoint = buffer[count] == " " ? count + 1 : breakpoint;
      if (count < maxLength) {
        count++;
        continue;
      }
      texts.add(NatrixText(buffer.cut(0, breakpoint)));
      buffer = buffer.cut(breakpoint);
      count = 0;
    }
    if (buffer.isNotEmpty) {
      texts.add(NatrixText(buffer));
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