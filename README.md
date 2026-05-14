<p align="center">
  <img src="Zaimka/Presentation/Common/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon~ios-marketing.png" alt="Zaimka" width="200" height="200" />
</p>

# Zaimka

Loan and debt tracker. Swift 6, UIKit + SwiftUI, SwiftData.

[![Build](https://github.com/freegatik/Zaimka/actions/workflows/build.yml/badge.svg)](https://github.com/freegatik/Zaimka/actions/workflows/build.yml)
[![Tests](https://github.com/freegatik/Zaimka/actions/workflows/test.yml/badge.svg)](https://github.com/freegatik/Zaimka/actions/workflows/test.yml)
[![Lint](https://github.com/freegatik/Zaimka/actions/workflows/lint.yml/badge.svg)](https://github.com/freegatik/Zaimka/actions/workflows/lint.yml)

## Build

Requirements: Xcode 16, iOS 17.6+.

```bash
git clone https://github.com/freegatik/Zaimka.git
cd Zaimka
git config core.hooksPath .githooks
brew install xcodegen swiftlint swiftformat
xcodegen generate
open Zaimka.xcodeproj
```

Select the **Zaimka** scheme and an iPhone simulator.

## Architecture

Layers: Presentation → Domain → Data. Details: [docs/adr/](docs/adr/).

## Tests

Currently, automated tests cover only the **calculator** (full chain down to the screen), the **amount formatting** function, and **localization string validation**. **Database (SwiftData), loan list, debt details, and password flow** are not covered — regressions there can go unnoticed.

Run with `Cmd+U` or via the **Unit Tests** workflow in CI.

## Code style

`swiftformat .`, `swiftlint`. CI uses SwiftFormat **0.61** with `--disable redundantViewBuilder` (SwiftUI). Local 0.58 works too; for the exact rule set used in CI see `.github/scripts/install-swiftformat.sh`.

## Misc

See [CONTRIBUTING.md](CONTRIBUTING.md). Use your own Team for Xcode signing. Secrets are kept out of git (see `.gitignore`).

## License

Source code is released under the [MIT License](LICENSE): free to use and modify provided the copyright notice is preserved. Full text is in the `LICENSE` file at the repository root.
