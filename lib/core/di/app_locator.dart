import 'package:get_it/get_it.dart';

/// FinFlow's service locator. Wired in [main] before `runApp` so any
/// feature can `locator<T>()` without passing instances through props.
///
/// Keep this thin — only register collaborators that meet ALL of:
///   * Stateful across the app lifetime
///   * Used by more than one feature
///   * Cheap to share OR genuinely a singleton
///
/// Per-feature transient objects (BLoCs, controllers) still live in
/// `BlocProvider` / widget trees.
final GetIt locator = GetIt.instance;
