# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**remainder** (余数) — a Flutter application targeting Android, iOS, Web, Windows, Linux, and macOS. Currently at scaffold stage (counter template). Dart SDK ^3.11.5.

## Commands

```bash
flutter run                     # Run on connected device / emulator
flutter run -d chrome           # Run on web (Chrome)
flutter run -d windows          # Run on Windows desktop
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run a single test file
flutter analyze                 # Static analysis (uses flutter_lints)
flutter build apk               # Build Android APK
flutter build web               # Build for web
```

## Architecture

Single-file app at `lib/main.dart`. Entry point is `main()` → `MyApp` (MaterialApp) → `MyHomePage` (StatefulWidget).

Lint rules come from `package:flutter_lints/flutter.yaml` configured in `analysis_options.yaml`.
