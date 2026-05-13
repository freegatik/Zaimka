<p align="center">
  <img src="Zaimka/Presentation/Common/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon~ios-marketing.png" alt="Zaimka" width="200" height="200" />
</p>

# Zaimka

Учёт кредитов и займов. Swift 6, UIKit + SwiftUI, SwiftData.

[![Build](https://github.com/freegatik/Zaimka/actions/workflows/build.yml/badge.svg)](https://github.com/freegatik/Zaimka/actions/workflows/build.yml)
[![Tests](https://github.com/freegatik/Zaimka/actions/workflows/test.yml/badge.svg)](https://github.com/freegatik/Zaimka/actions/workflows/test.yml)
[![Lint](https://github.com/freegatik/Zaimka/actions/workflows/lint.yml/badge.svg)](https://github.com/freegatik/Zaimka/actions/workflows/lint.yml)

## Сборка

Требования: Xcode 16, iOS 17.6+.

```bash
git clone https://github.com/freegatik/Zaimka.git
cd Zaimka
git config core.hooksPath .githooks
brew install xcodegen swiftlint swiftformat
xcodegen generate
open Zaimka.xcodeproj
```

Схема **Zaimka**, симулятор iPhone.

## Структура

Слои: Presentation → Domain → Data. Подробнее: [docs/adr/](docs/adr/).

## Тесты

Сейчас автотесты есть только у **калькулятора** (вся цепочка до экрана), у функции **форматирования сумм** и у **проверки строк** из локализации. **База (SwiftData), список кредитов, детали долга и пароль** тестами не покрыты — при правках там ошибки можно не заметить сразу.

`Cmd+U` или workflow **Unit Tests** в CI.

## Код

`swiftformat .`, `swiftlint`. В CI — SwiftFormat **0.61** и флаг `--disable redundantViewBuilder` (SwiftUI). Локально подойдёт и 0.58; для того же набора правил, что в CI, см. `.github/scripts/install-swiftformat.sh`.

## Прочее

[CONTRIBUTING.md](CONTRIBUTING.md). Подпись в Xcode — свой Team. Секреты не в git (см. `.gitignore`).

## Лицензия

Исходный код распространяется на условиях [MIT License](LICENSE): разрешено свободное использование и модификация при сохранении уведомления об авторских правах. Полный текст — в файле `LICENSE` в корне репозитория.
