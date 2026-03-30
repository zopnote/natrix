import 'dart:io' as io show stdout, stderr, stdin;
import 'package:natrix/src/core/text.dart'
    show NatrixText, NatrixColor, NatrixStyle;

class NatrixMount {
  final int position;
  final NatrixStdoutSink output;
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

class NatrixStdoutSink {
  static final NatrixStdoutSink stderr = NatrixStdoutSink(io.stderr);
  static final NatrixStdoutSink stdout = NatrixStdoutSink(io.stdout);

  const NatrixStdoutSink(this.sink);
  final StringSink sink;

  @override
  int get hashCode => sink.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! NatrixStdoutSink) {
      return false;
    }
    return this.sink == other.sink;
  }
}

class NatrixStdio {
  int _totalLinesWritten = 0;

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
      position: _totalLinesWritten++,
      output: NatrixStdoutSink.stdout,
    );
    mount.output.sink.write(
      "${prefix.ansi}"
      "${inputForegroundColor.ansiForegroundSequence}"
      "${inputBackgroundColor.ansiBackgroundSequence}"
      "${inputStyle.ansiStartSequence}",
    );
    final String input = io.stdin.readLineSync() ?? "";
    mount.output.sink.write(
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

  Iterable<NatrixMount> writeLines({
    final List<NatrixText> lines = const [],
    final NatrixStdoutSink? output,
  }) {
    if (lines.isEmpty) {
      return [];
    }
    final List<NatrixMount> mounts = [];
    for (final NatrixText t in lines) {
      mounts.add(newLine(text: t, output: output));
    }
    return mounts;
  }

  NatrixMount newLine({
    final NatrixText text = const NatrixText.empty(),
    final NatrixStdoutSink? output,
  }) {
    if (!text.valid()) {
      throw Exception(_invalidMessage(text));
    }
    final NatrixMount mount = NatrixMount(
      position: _totalLinesWritten++,
      output: output ?? NatrixStdoutSink.stdout,
    );
    mount.output.sink.write("${text.ansi}\n");
    return mount;
  }

  void setLine({
    required final NatrixMount mount,
    final NatrixText text = const NatrixText.empty(),
  }) {
    if (!text.valid()) {
      throw Exception(_invalidMessage(text));
    }
    final int d = _totalLinesWritten - mount.position;
    mount.output.sink.write("\x1B[${d}F\x1B[2K${text}\x1B[${d}E");
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
  int get hashCode => _totalLinesWritten.hashCode;
}
