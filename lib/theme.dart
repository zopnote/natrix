import 'package:natrix/core.dart';

import 'src/theme/line.dart';

export 'src/theme/atomics.dart';
export 'src/theme/default_theme.dart';
export 'src/theme/block.dart';
export 'src/theme/column.dart';
export 'src/theme/document.dart';
export 'src/theme/header.dart';
export 'src/theme/line.dart';
export 'src/theme/structure.dart';

extension NatrixTextFormatExtension on NatrixText {
  List<NatrixText> format() => isEmpty ? const [] : [this];
  NatrixLine asLineSection() => NatrixLine(text: this);
}
