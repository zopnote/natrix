import 'package:natrix/natrix.dart';
import 'package:natrix/src/writer.dart';

abstract class NatrixTheme {
  final NatrixStdio writer;
  const NatrixTheme.at(this.writer);

  void printRootHelp();
  void printSingleCommandHelp();
  void printFlagHelp(NatrixFlag flag);
}

class NatrixDefaultTheme extends NatrixTheme {
  const NatrixDefaultTheme.at(super.writer) : super.at();
  static const int allowedUnitLength = 24;

  @override
  void printFlagHelp(final NatrixFlag flag) {
    if (flag.id.length > 22) {
      throw Exception(
        "The length of a flags identifier "
        "shouldn't exceed 22 characters.",
      );
    }
    final NatrixMount mount = writer.newLine();
    String output = "";
    output += flag.acronym != null ? "-${flag.acronym}, " : " " * 4;
    output += "--${flag.id}";
    output += " " * (allowedUnitLength - flag.id.length - 2);

    if (flag.tooltip.length > 50) {}
  }

  @override
  void printRootHelp() {
    // TODO: implement printRootHelp
  }

  @override
  void printSingleCommandHelp() {
    // TODO: implement printSingleCommandHelp
  }
}
