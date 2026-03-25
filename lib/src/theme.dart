
import 'dart:io';

abstract class NatrixTheme {
  const NatrixTheme();

  Stencil root();
  Stencil commandSyntax();
  Stencil flagSyntax();
}
