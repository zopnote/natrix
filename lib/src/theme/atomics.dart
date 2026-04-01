import 'package:natrix/core.dart';

/**
 * The [NatrixTheme] class serves as an interface definition for a
 * standard CLI theme. It can, of course, be extended and modified.
 *
 * However, it's recommended that every implementation
 * supports the absolute minimum specified here.
 */
abstract class NatrixTheme {
  const NatrixTheme.of(this.context);

  /**
   * The [NatrixContext] for the current execution of the [NatrixPipeline].
   */
  final NatrixContext context;

  /**
   * The [root] is the [NatrixSection] that is to be formatted and displayed
   * when a user either calls the application’s root command (provided this
   * does not already have a function and would simply displays a motd) or
   * when the root is accessed via the help command.
   */
  NatrixSection get root;

  /**
   * The [syntax] is the syntax of a single command,
   * including all its associated elements.
   */
  NatrixSection get syntax;

  /**
   * The [header] is the header of a helper request relating to a command.
   */
  NatrixSection get header;

  /**
   * The [footer] is the footer of a help request regarding a command.
   */
  NatrixSection get footer;

  /**
   * The [usage] is usually a single line
   * that briefly outlines the command's syntax.
   */
  NatrixSection get usage;

  /**
   * [flags] is a section that lists applicable [NatrixFlag]s.
   */
  NatrixSection get flags;

  /**
   * [commands] is a section that lists applicable sub-[NatrixCommand]s.
   */
  NatrixSection get commands;
}

/**
 * A [NatrixSection] serves as an interface definition for objects that describe a
 * section of text.
 */
abstract interface class NatrixSection {
  const NatrixSection();

  /**
   * Whether this [NatrixSection] contains actual content that should
   * be displayed or not.
   */
  bool get isEmpty;

  /**
   * Returns a [List] of formatted [NatrixText] ready for output.
   */
  List<NatrixText> format();
}




