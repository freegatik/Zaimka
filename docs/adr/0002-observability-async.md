# ADR 0002: Логи и потоки

**Статус:** принято.

Логи: `os.Logger` (`AppLogger`), не `print`. UI и `@MainActor`-хранилище на главном потоке; фон — `async`/`await`. Ошибка дискового SwiftData → fallback in-memory + лог; полный отказ — `fatalError`.

`PrivacyInfo.xcprivacy`: UserDefaults (настройки Face ID и т.п.).
