import 'package:meta/meta.dart';

import 'package:natrix/src/core/misc.dart';

/**
 * Represents a single character string.
 */
@immutable
class NatrixChar {
  NatrixChar(this.c) {
    if (c.length > 1) {
      throw Exception("A character cannot be longer than 1 unit.");
    }
  }
  final String c;

  @override
  bool operator ==(Object other) => other is NatrixChar
      ? c == other.c
      : other is String
      ? c == other
      : false;

  String operator *(int times) => c * times;

  String operator +(String other) => c + other;

  @override
  String toString() => c;
}

/**
 * Represents a multicharacter string with
 * ansi escape sequence and filestream formatting.
 */
class NatrixText {
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

  factory NatrixText.join(List<NatrixText> parts) {
    String s = "";
    parts.forEach((c) => s += c.ansi);
    return NatrixText(s);
  }
  /**
   * The ansi escape sequence color of the background.
   */
  final NatrixColor background;
  /**
   * The ansi escape sequence color of foreground.
   */
  final NatrixColor foreground;
  /**
   * The ansi escape sequence style of the text.
   */
  final NatrixStyle style;

  /**
   * The raw string which won't get manipulated later on.
   */
  final String text;

  /**
   * Format the ansi sequences into a ready-to-output string.
   */
  String get ansi =>
      style.apply(background.colorize(foreground.colorize(text)));

  /**
   * Whether the ansi-formatted-text is empty.
   */
  bool get isEmpty => ansi.isEmpty;
  /**
   * Whether the ansi-formatted-text is not empty.
   */
  bool get isNotEmpty => ansi.isNotEmpty;

  /**
   * Length of the [ansi]-[String].
   */
  int get length => ansi.length;

  /**
   * Codeunits of the [ansi]-[String].
   */
  List<int> get codeUnits => ansi.codeUnits;

  /**
   * Whether the ansi string contains unallowed,
   * cursor manipulating sequences.
   */
  bool valid() =>
      !RegExp(r'\x1B$$[0-9;]*[^m]').hasMatch(text) &&
      !text.contains("\n") &&
      !text.contains("\r");

  /**
   * Wraps the [ansi] text literal into multiple lines to for-fill the requirements
   * of [maxLength]. With [breakpointCharacter]s, it could be specified where the
   * line breaks should preferably be set.
   */
  List<NatrixText> wrap(
    final int maxLength, [
    List<NatrixChar>? breakpointCharacter,
  ]) {
    breakpointCharacter ??= [NatrixChar(' ')];
    if (ansi.length < maxLength) {
      return [this];
    }
    final List<NatrixText> texts = [];

    String buffer = ansi;
    int breakpoint = 0;
    int count = 0;
    while (count < buffer.length) {
      if (buffer[count] == " ") {
        breakpoint = count + 1;
      }
      if (count < maxLength - 1) {
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

  NatrixText operator *(int other) {
    if (other < 1) {
      return NatrixText.empty();
    }
    final List<NatrixText> components = [];
    for (int i = 0; i < other; i++) {
      components.add(this);
    }
    return NatrixText.join(components);
  }

  NatrixText operator +(NatrixText other) {
    return NatrixText.join([this, other]);
  }

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

/**
 * Definition of the corresponding ANSI escape sequence values for their styles.
 */
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

/**
 * Definition of the corresponding ANSI escape sequence values for their colors.
 */
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
