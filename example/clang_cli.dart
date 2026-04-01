import 'package:natrix/core.dart';
import 'package:natrix/io.dart';
import 'package:natrix/theme.dart';

final NatrixCommand clang = NatrixCommand(
  id: "clang_cli",
  tooltip: "A C/C++/Objective-C compiler driver.",
  description:
      "A C language family frontend for LLVM. "
      "Invoke a sub-command or pass --help for usage information.",
  flags: [
    NatrixBoolFlag(
      acronym: NatrixChar("v"),
      id: "version",
      tooltip: "Print the clang version string and exit.",
    ),
    NatrixBoolFlag(
      id: "help",
      acronym: NatrixChar("h"),
      tooltip: "Print this help message and exit.",
    ),
  ],
  children: [
    NatrixCommand(
      id: "compile",
      tooltip:
          "Compile source files into .o files or an exe.",
      description:
          "Compile source files into .o files or an exe.",
      inheritFlags: true,
      flags: [
        NatrixTextFlag(
          id: "output",
          acronym: NatrixChar("o"),
          tooltip: "Path to the output file.",
        ),
        NatrixTextFlag(
          id: "optimize",
          acronym: NatrixChar("O"),
          tooltip: "Optimization level: 0 (none), 1, 2, or 3 (aggressive).",
        ),
        NatrixBoolFlag(
          id: "debug",
          acronym: NatrixChar("g"),
          tooltip: "Emit debug symbols for use with a debugger.",
        ),
        NatrixBoolFlag(
          id: "wall",
          acronym: NatrixChar("W"),
          tooltip: "Enable all compiler warning diagnostics.",
        ),
        NatrixTextFlag(
          id: "standard",
          acronym: NatrixChar("s"),
          tooltip: "Language standard to compile against (e.g. c++17, c11).",
        ),
        NatrixTextFlag(
          id: "include",
          acronym: NatrixChar("I"),
          tooltip: "Add a directory to the header search path.",
        ),
      ],
      callback: (options) {
        final NatrixTheme theme = NatrixDefaultTheme.of(options.getContext());
        final NatrixStdio io = NatrixStdio();
        io.writeLines(lines: theme.root.format());
        io.newLine();
      },
    ),
    NatrixCommand(
      id: "link",
      description:
          "Link .o files and libraries into an exe or shared library.",
      flags: [
        NatrixTextFlag(
          id: "output",
          acronym: NatrixChar("o"),
          tooltip: "Path to the linked output file.",
        ),
        NatrixTextFlag(
          id: "library",
          acronym: NatrixChar("l"),
          tooltip: "Name of a library to link against.",
        ),
        NatrixTextFlag(
          id: "library-path",
          acronym: NatrixChar("L"),
          tooltip: "Directory to search for libraries.",
        ),
        NatrixBoolFlag(
          id: "shared",
          acronym: NatrixChar("s"),
          tooltip: "Produce a shared library instead of an executable.",
        ),
      ],
      callback: (options) {},
    ),
    NatrixCommand(
      hidden: true,
      id: "format",
      description:
          "Format source files according to a configurable style guide.",
      flags: [
        NatrixTextFlag(
          id: "style",
          acronym: NatrixChar("s"),
          tooltip:
              "Formatting style preset: llvm, google, chromium, mozilla, or file.",
        ),
        NatrixBoolFlag(
          id: "inplace",
          acronym: NatrixChar("i"),
          tooltip: "Overwrite source files with formatted output in-place.",
        ),
        NatrixBoolFlag(
          id: "dry-run",
          acronym: NatrixChar("n"),
          tooltip: "Print formatted output without modifying any files.",
        ),
      ],
      callback: (options) {},
    ),
  ],
  callback: (options) {
    final NatrixTheme theme = NatrixDefaultTheme.of(options.getContext());
    final NatrixStdio io = NatrixStdio();
    io.writeLines(lines: theme.root.format());
    io.newLine();
  },
);

Future<void> main(List<String> args) async {
  await NatrixPipeline(arguments: args).run(clang);
}
