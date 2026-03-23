import 'dart:async';

abstract class NatrixTheme {
  const NatrixTheme();

  Stencil root();
  Stencil commandSyntax();
  Stencil flagSyntax();
}

class NatrixDefaultTheme extends NatrixTheme {
  const NatrixDefaultTheme();
}

class FlagStencil extends Stencil {
  @override
  Stencil build() {
    return TextStencil("");
  }
}

class ColumnStencil extends Stencil {
  final List<Stencil> children;
  final int padding;
  const ColumnStencil({required this.children, required this.padding});

  @override
  String? construct([Stencil Function()? candidate]) {

  }

  @override
  Stencil build() => throw UnimplementedError();
}

class TextStencil extends Stencil {
  final String text;
  const TextStencil(this.text);

  @override
  String? construct([Stencil Function()? candidate]) {
    return text;
  }

  @override
  Stencil build() => throw UnimplementedError();
}

abstract class Stencil {
  const Stencil();

  String? construct([Stencil candidate()?]) {
    return build().construct(candidate);
  }

  Stencil build();
}
