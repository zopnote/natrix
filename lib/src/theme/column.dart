import 'package:natrix/core.dart';
import 'package:natrix/theme.dart';

class NatrixColumn implements NatrixSection {
  final List<NatrixText> lines;
  const NatrixColumn({required this.lines});
  @override
  List<NatrixText> format() {
    if (isEmpty) {
      return const [];
    }
    final List<NatrixText> o = [];
    lines.forEach((l) => o.addAll(l.format()));
    return o;
  }

  @override
  bool get isEmpty => lines.isEmpty;
}