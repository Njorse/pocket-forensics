/// Utility class to wrap result data.
///
/// Evaluate the result using a switch statement:
/// ```dart
/// switch (result) {
///   case Ok():
///     print(result.value);
///   case Error():
///     print(result.error);
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Creates an instance of Result containing a value.
  factory Result.ok(T value) => Ok(value);

  /// Creates an instance of Result containing an error.
  factory Result.error(Exception error) => Error(error);

  /// Convenience method to cast to [Ok].
  Ok<T> get asOk => this as Ok<T>;

  /// Convenience method to cast to [Error].
  Error<T> get asError => this as Error<T>;
}

/// Subclass of [Result] for success values.
final class Ok<T> extends Result<T> {
  const Ok(this.value);

  /// The returned value.
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Subclass of [Result] for errors.
final class Error<T> extends Result<T> {
  const Error(this.error);

  /// The returned error.
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
