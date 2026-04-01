
import 'package:natrix/core.dart';
import 'package:natrix/theme.dart';

class NatrixDocument implements NatrixSection {
  final NatrixSection header;
  final NatrixStructure content;
  final NatrixSection footer;

  const NatrixDocument({
    required this.header,
    required this.content,
    required this.footer,
  });
  @override
  List<NatrixText> format() =>
      NatrixStructure(padding: 1, sections: [header, content, footer]).format();

  @override
  bool get isEmpty => header.isEmpty && content.isEmpty && footer.isEmpty;
}

