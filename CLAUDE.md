# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

A Flutter movie app (TMDB for movie data; Supabase for auth, watchlist and a realtime vote room). **Only the `flutter create` scaffold exists so far**: `lib/main.dart` is the default counter demo and `test/widget_test.dart` tests it. Nothing from the planned architecture is built yet. The sibling project `../weather_application` (Skycast) is the reference for the base code (Riverpod, go_router, Dio, `Result<T>`/`Failure`, l10n, theme); copy its patterns instead of inventing new ones.

`rule.md` (Vietnamese) holds the coding rules. **Follow it strictly.** The user wrote these rules; they aren't generic advice. `README.md` has the planned features.

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after editing freezed / json / @riverpod code (once those packages are added)
flutter gen-l10n                                           # after editing .arb files (once l10n is set up)
flutter analyze                                            # must be warning-free before commit
flutter test                                               # all tests
flutter test test/path/to_test.dart                        # single file
flutter test --plain-name "test name"                      # single test by name
flutter run
```

Lint uses `flutter_lints`; `analysis_options.yaml` excludes the platform folders. Generated files (`*.g.dart`, `*.freezed.dart`, l10n) are not committed, so generate them after cloning.

## Key rules (from rule.md)

- **File size limit: 600 lines** (generated files don't count). Under 600 lines, **don't split a file** unless code is reused elsewhere. Private sub-widgets (`_Foo`) stay in the file of the screen that uses them. No barrel files, no single-constant files.
- Only create folders when a real file goes into them. Layout: `lib/core/` + `lib/features/<feature>/{data,domain,presentation}`. **No usecase layer**: Riverpod `@riverpod` providers call repositories directly.
- Abstract interfaces only for repositories (in `domain/`, so tests can mock them).
- Errors: datasource catches `DioException` (or Supabase errors) and throws an app exception; repository wraps its body in `guard()` and returns `Result<T>` (`Ok` / `Err(Failure)`); UI uses `.when(data, loading, error)` with `AppErrorView`. No silent `catch (_) {}`.
- Dio is created in one place (`core/network/dio_client.dart`); no custom interceptors, only `LogInterceptor` in debug.
- Paginated TMDB lists: one notifier holds the loaded items + next page; never stitch pages in a widget.
- Colors and text styles come from `Theme` / `ThemeExtension`; UI strings from `context.l10n` (`.arb`, vi + en). Never hard-code either. Every data screen handles loading (skeleton), error (retry) and empty.
- Network images go through one shared widget with placeholder + error fallback, not scattered `Image.network`.
- Secrets (TMDB key, Supabase URL/anon key) come from `--dart-define-from-file`; commit only `*.example.json`. Every Supabase table has Row Level Security; never use the `service_role` key in the app. Credit TMDB in the README.
- Don't add a package when a few lines of code would do. Pure logic (mappers, repositories, pagination) needs unit tests with `mocktail`.
- Conventional Commits. Branch `feature/<name>` off `dev` and open PRs into `dev` (not `main`).
