
import 'dart:io' as io show stdout, stderr;

typedef VoidCallback = void Function();

class NatrixMountpoint {
  final int position;
  NatrixOutputStream issued;
  NatrixMountpoint({required this.position, required this.issued});
}

enum NatrixOutputStream {
  stderr(false),
  stdout(true);

  const NatrixOutputStream(this.isErr);
  final bool isErr;
}

/**
 *
 */
class NatrixOutputWriter {
  late final StringSink _stdout;
  late final StringSink _stderr;
  NatrixOutputWriter({StringSink? stdout, StringSink? stderr}) {
    this._stdout = stdout ?? io.stdout;
    this._stderr = stderr ?? io.stderr;
  }
  int line = 0;

  NatrixMountpoint newLine({
    final String? text,
    final NatrixOutputStream out = .stdout,
  }) {
    final NatrixMountpoint mount = NatrixMountpoint(
      position: line++,
      issued: out,
    );
    (out.isErr ? _stderr : _stdout).writeln(text ?? "");
    return mount;
  }

  void setLine({
    required final NatrixMountpoint mount,
    final String text = "",
  }) {
    final RegExp invalidEscape = RegExp(r'\x1B$$[0-9;]*[^m]');
    if (invalidEscape.hasMatch(text)) {
      throw Exception(
        "Unallowed character inside \"$text\". There can't be ANSI escape codes other than color related.",
      );
    }
    if (text.contains("\n")) {
      throw Exception(
        "Unallowed character inside \"$text\". Line breaks aren't allowed.",
      );
    }

    final int d = line - mount.position;
    (mount.issued.isErr ? _stderr : _stdout).write(
      "\x1B[${d}F\x1B[2K${text}\x1B[${d}E",
    );
  }
}
