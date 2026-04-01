import 'package:natrix/core.dart';
import 'package:natrix/theme.dart';

class NatrixStructure implements NatrixSection {

  const NatrixStructure({
    required this.sections,
    this.padding = 1,
    this.spacePrefix = 0,
  });

  const NatrixStructure.empty()
    : sections = const [],
      padding = 0,
      spacePrefix = 0;

  final List<NatrixSection> sections;
  final int padding;
  final int spacePrefix;

  @override
  bool get isEmpty => sections.isEmpty;

  @override
  List<NatrixText> format() {
    if (isEmpty) {
      return const [];
    }

    final List<NatrixText> o = [];
    final NatrixText prefix = NatrixText(' ') * spacePrefix;
    int i = 0;

    final List<NatrixSection> stuffed = [];

    sections.forEach((e) {
      if (!e.isEmpty) {
        stuffed.add(e);
      }
    });
    stuffed.forEach((s) {
      s.format().forEach((text) {
        o.add(prefix + text);
      });
      if (i < stuffed.length - 1) {
        for (int n = 0; n < padding; n++) {
          o.add(NatrixText.empty());
        }
      }
      i++;
    });
    return o;
  }
}
