
import 'package:natrix/core.dart';
import 'package:natrix/theme.dart';

class NatrixLine implements NatrixSection {
  final NatrixText text;

  const NatrixLine({required this.text});
  const NatrixLine.empty() : text = const NatrixText.empty();
  @override
  List<NatrixText> format() => isEmpty ? [] : [text];

  @override
  bool get isEmpty => text.isEmpty;
}

