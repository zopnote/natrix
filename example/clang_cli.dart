import 'package:natrix/core.dart';

final NatrixCommand clang = NatrixCommand(
  // A root command doesn't require an identifier.
  // Tooltips aren't anytimes required too. If not specified,
  // the first 37 characters of the description will be
  // applied to the field.
  tooltip: "A C/C++/Objective-C compiler driver.",
  // Description will be displayed, when a more detailed usage advice is requested.
  description:
      "A C language family frontend for LLVM. "
      "Invoke a sub-command or pass --help for usage information.",
  // If not other specified,
  // the subcommands won't inherit the superior command's flags.
  flags: [
    NatrixBoolFlag(
      id: "version",
      acronym: NatrixChar("v"),
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
      description:
          "Compile one or more source files into object files or a single executable.",
      // If it is wanted to inherit the superior flags,
      // inheritFlags have to be true.
      inheritFlags: true,
      flags: [
        NatrixTextFlag(
          id: "output",
          // Flags does not require an acronym.
          // It is an optional one-char-short-form
          // of the command and has to be unique too.
          acronym: NatrixChar("o"),
          tooltip: "Path to the output file.",
        ),
        // The implementation of this one is kind of wrong.
        // Own types, like enums or any other class should get an
        // own Flag class with it's parser and formatter to better
        // handle inputs.
        // Here the "parsing step" happens later which is not intended,
        // but it would work without side effects of course.
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
      // self is required to refer back to the command. E.g. for Syntax
      // messages. To see more about these
      // parameters look inside the NatrixPipeline.
      callback: (options) {
      },
    ),
    NatrixCommand(
      id: "link",
      description:
          "Link object files and static libraries into a single executable or shared library.",
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
      callback: (options) {

      },
    ),
    NatrixCommand(
      // An command can also be hidden. In the default implementation
      // of message output, a command wouldn't be displayed in usage advices if
      // hidden is turned on.
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
  callback: (options) {options.theme;},
  id: "clang_cli",
);

Future<void> main(List<String> args) async {
  await NatrixPipeline(arguments: args).run(clang);
}
