import 'dart:async';

/// Represents the importance of its [Response].
enum Level {
  /**
   * If a [Response] has the [critical] [Level], it implies
   * the end of the working unit at this point. Whatever happened was a critical
   * error for the entire chain of steps.
   *
   * The user have to do something to make the working unit even work.
   */
  critical(4),
  /**
   * If a [Response] has the [error] [Level], it implies
   * the end of the current [Bubble]. Therefore you can say, that whatever happened
   * does influence the following [Step] to not be able to do their work.
   * The user
   *
   * The user have to do something to ensure the functionality of the currently working unit.
   */
  error(3),
  /**
   * If a [Response] has the [warning] [Level], it implies that something unexpected
   * happened, that does not hold the following steps back from doing their work,
   * but shouldn't really happen.
   *
   * The user should be aware of this response.
   */
  warning(2),

  /**
   * If a [Response] has the [default] [normal], it just wants to let you something know.
   * It isn't important that the user sees this, but if he wants to know whats going on,
   * he defiantly should take a look at this response.
   *
   * The user can take a look at this response.
   */
  normal(1),

  /**
   * If a [Response] has the [status] [Level], it just wants to let you something know.
   * It isn't important that the user sees this, but if he wants to know whats going on,
   * he defiantly should take a look at this response.
   *
   * The user can take a look at this response.
   */
  @Deprecated("Switch to Level.normal until status get's removed in the next major version.")
  status(1),
  /**
   * If a [Response] has the [verbose] [Level], it is just for debugging purposes or to find out,
   *
   * If the user wants extra information, they should look at this response.
   */
  verbose(0);
  const Level(this.value);
  final int value;
}

/**
 * A [Response] is a message send by a working unit, to communicate with its user.
 */
final class Response {
  /**
   * A [Response] is a message send by a working unit, to communicate with its user.
   */
  const Response([this.message = "", this.level = Level.verbose]);

  /// Importance of the message.
  final Level level;

  /// Message why this [Response] was even send.
  final String message;

  /// Returns if the level is greater than 3, what an error indicates.
  bool get isError => level.value >= 3;

  int get errorCode => isError ? 1 : 0;

  @override
  String toString() => message;
}

typedef ResponseCallback = FutureOr<void> Function(Response response);
