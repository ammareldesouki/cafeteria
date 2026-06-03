# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**OnTheWay** — a cafeteria management system for CIC (Canadian International College). The Flutter app supports two roles: **customers** (browse menu, cart, orders, favourites) and **admin/cafeteria staff** (manage menu items, stock, variants, orders, and view analytics).

The backend lives in `cic-backend/` (Node.js + Express + MongoDB). The Flutter app lives in `cafeteria/`.

---

## Common Commands

All commands run from the `cafeteria/` directory:

```bash
# Install dependencies
flutter pub get

# Regenerate localization files (required after editing .arb files)
flutter gen-l10n

# Run the app
flutter run

# Analyze code
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/test_file.dart
```

### Backend (run from `cic-backend/`)

```bash
npm run dev        # nodemon dev server (NODE_ENV=development)
npm run build      # bundle with tsup → dist/
npm start          # run production build (dist/server.js)
npm run check      # Biome lint + format check
npm run format     # Biome auto-format
npm run lint       # Biome lint only
```

---

## Backend Architecture

`cic-backend/` is a TypeScript Express 5 + Mongoose (MongoDB) API, bundled with `tsup`, linted/formatted with **Biome** (not ESLint/Prettier). Layered structure under `src/`:

- `routes/` — one file per resource (`menu`, `cart`, `order`, `wallet`, `analytics`, `admin`, `cafeteria`, `favorite`, `user`, `health`), wired in `routes/index.ts`. Auth has both `betterAuth.routes.ts` and `auth.custom.routes.ts`.
- `controllers/` → `services/` → `repositories/` — request handling, business logic, and data access respectively.
- `middlewares/`, `config/` (env, DB connection), `utils/`, `types/`, `integration/`, `docs/`.

**Auth**: uses [`better-auth`](https://better-auth.com) plus custom routes; the app and better-auth share a single Mongo connection (`config/env.ts`). The Flutter app authenticates against this and stores the JWT (see SharedPreferences `auth_token`). Deployed on Railway/PM2 (`ecosystem.config.js`, `railway.json`).

---

## Architecture

**Clean Architecture** with feature-driven modules. Every feature under `lib/features/` follows this exact layer structure:

```
feature/
├── data/
│   ├── data_sources/    # API calls (DIO) and local storage (SharedPreferences)
│   ├── models/          # JSON-serializable models extending domain entities
│   └── repositories/    # Implements domain repository interfaces
├── domain/
│   ├── entities/        # Pure business objects (no JSON)
│   ├── repositories/    # Abstract interfaces
│   └── use_cases/       # One class per operation, returns Either<Failure, T>
└── presentation/
    ├── manager/         # BLoC: *_bloc.dart, *_event.dart, *_state.dart
    ├── pages/           # Full screens
    └── widgets/         # Feature-local reusable widgets
```

**Cross-cutting concerns** live in `lib/core/`:
- `route/` — Centralized named-route navigation (`AppRouter.generateRoute`)
- `network/` — `NetworkDioHandler` singleton (DIO + interceptors + token management)
- `theme/` — Material 3 themes + `ThemeBloc`
- `local/` — `LocaleBloc` for language switching (en/ar)
- `constants/` — API endpoints, colors, storage keys
- `widgets/` — Shared UI components

**Dependency injection**: `GetIt` service locator (`sl`). All registrations live in `lib/features/auth/di/injaction.dart`'s `setupLocator()`, called from `main.dart`.

---

## State Management

**BLoC pattern** (flutter_bloc 9.1.1) everywhere. Each feature has its own BLoC. BLoC instances are registered as `LazySingleton` via `GetIt` and injected at the route level inside `AppRouter.generateRoute()` using `BlocProvider.value(value: sl<XBloc>())`.

Global BLoCs (`ThemeBloc`, `LocaleBloc`) are provided at the root in `my_app.dart`.

---

## Routing

Named routes with `onGenerateRoute`. Route names are constants in `lib/core/route/route_name.dart`. The generator in `lib/core/route/app_route.dart` handles argument passing and wraps pages with their required BLoC providers.

When adding a new route: add its constant to `RouteNames`, add a `case` in `AppRouter.generateRoute()`, and provide the BLoC(s) it needs.

---

## Networking

- Base URL: defined by `ApiConstants.baseUrl` in `lib/core/constants/`. Currently points at the deployed Railway backend (`https://cafeteria-production-85c5.up.railway.app/api/v1`). For local backend dev, switch to `http://10.0.2.2:3001/api/v1` (Android emulator) / `http://localhost:3001/api/v1` (iOS simulator)
- Auth token is injected automatically by `NetworkDioHandler` as `Authorization: Bearer <token>`
- Token persistence: stored/retrieved via `SharedPreferences` with key `auth_token`
- Error handling: all repository methods return `Either<Failure, T>` (dartz)

---

## Localization

ARB files are the source of truth: `lib/l10n/app_en.arb` (template) and `lib/l10n/app_ar.arb`. After editing them, run `flutter gen-l10n` to regenerate `app_localizations.dart` and language-specific files. Arabic uses RTL layout, toggled in `my_app.dart` based on `LocaleBloc` state.

---

## Firebase

`firebase_options.dart` is **gitignored** (contains API keys). It is generated by FlutterFire CLI. Web/macOS/Windows/Linux platforms throw `UnsupportedError`. Only Firebase Core is initialized — it is groundwork for future services, not actively used for data.

---

## Key Dependencies

| Package | Role |
|---------|------|
| `flutter_bloc` | BLoC state management |
| `get_it` | Service locator / DI |
| `dartz` | `Either` for error handling |
| `dio` | HTTP client |
| `google_sign_in` | Google OAuth |
| `aad_oauth` | Microsoft/Azure AD OAuth (template, not fully wired) |
| `shared_preferences` | Persisting token, theme, locale |
| `mocktail` | Test mocking |

---

## SharedPreferences Keys

| Key | Value |
|-----|-------|
| `auth_token` | JWT bearer token |
| `user_id` | Current user ID |
| `user_role` | `customer` or `admin` |
| `theme_mode` | `light` or `dark` |
| `locale_code` | `en` or `ar` |
