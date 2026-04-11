# 🤖 AI Agent Context — Digital Library (Flutter)

> **AGENT INSTRUCTIONS**
> Read this file at the start of every session.
> When you create or modify any component, route, service, model, or color — **update the relevant section of this file** before ending your response.
> Never guess file locations or class names — everything is listed here.

---

## 🗂️ Project Overview

| Field     | Value                        |
| --------- | ---------------------------- |
| App Name  | Digital Library              |
| Framework | Flutter (Material 3)         |
| Backend   | REST API + MongoDB + MinIO   |
| Auth      | JWT via FlutterSecureStorage |
| Roles     | `client`, `admin`            |

---

## 🖼️ Assets

| Asset        | Path                         | Used In                    |
| ------------ | ---------------------------- | -------------------------- |
| App Logo PNG | `assets/images/app_logo.png` | Login + Signup header logo |
| App Icon PNG | `assets/images/app_logo.png` | Android/iOS launcher icon  |

> If the logo changes, replace the same file name/path to avoid breaking references.
> Launcher icon generation is configured in `pubspec.yaml` via flutter_launcher_icons.

---

## 📁 File Structure

```
lib/
├── core/
│   ├── api/
│   │   └── api_config.dart         # Base URL + endpoint constants
│   ├── utils/
│   │   ├── app_colors.dart         # All color constants + gradients
│   │   ├── toast_types.dart        # ToastType enum & per-type styling
│   │   └── toast_service.dart      # Global toast singleton
│   ├── navigation/
│   │   └── app_router.dart         # Named route definitions
│   ├── database/
│   ├── network/
│   │   └── dio_client.dart         # Shared Dio wrapper + interceptors
│   └── di/
├── ui/
│   ├── theme/
│   │   └── app_theme.dart          # ThemeData wired to AppColors
│   ├── components/
│   │   ├── toasts/
│   │   │   └── app_toast.dart      # Toast widget (slide-up + fade)
│   │   ├── modals/
│   │   │   └── app_modal.dart      # Reusable dialog + showAppModal()
│   │   └── navigation/
│   │       ├── app_sidebar.dart     # Role-based collapsible sidebar
│   │       └── library_app_bar.dart # Shared app bar (admin/client)
│   └── pages/
│       ├── session_gate_page.dart
│       ├── login_page.dart
│       ├── signup_page.dart
│       ├── client/
│       │   ├── client_layout.dart
│       │   ├── client_home_page.dart
│       │   ├── client_books_page.dart
│       │   ├── client_favorites_page.dart
│       │   └── client_cart_page.dart
│       └── admin/
│           ├── admin_layout.dart
│           ├── admin_home_page.dart
│           ├── admin_analytics_page.dart
│           ├── admin_books_page.dart
│           ├── admin_create_book_page.dart
│           ├── admin_book_detail_page.dart
│           ├── admin_users_page.dart
│           └── admin_user_detail_page.dart
├── models/
│   ├── avis_model.dart
│   ├── categorie_model.dart
│   ├── commande_model.dart
│   ├── lecture_model.dart
│   ├── ligne_commande_model.dart
│   ├── livre_model.dart
│   ├── menu_model.dart
│   └── user_model.dart
├── service/
│   ├── auth_api_service.dart
│   ├── auth_service.dart
│   ├── categorie_service.dart
│   ├── livre_service.dart
│   └── user_service.dart
└── main.dart
```

---

## 🎨 Color Palette

**Files:** `lib/core/utils/app_colors.dart`

```dart
// Always import like this:
import 'package:digital_library/core/utils/app_colors.dart';
```

### Token Reference

| Token                               | Hex         | Role                                |
| ----------------------------------- | ----------- | ----------------------------------- |
| `AppColors.primary`                 | `#1A2B5E`   | Navy — headings, text, dark UI      |
| `AppColors.secondary`               | `#29B6D8`   | Cyan — buttons, links, interactive  |
| `AppColors.accent`                  | `#F5A623`   | Amber — highlights, CTAs, warnings  |
| `AppColors.background`              | `#E8F4FB`   | Ice Blue — scaffold background      |
| `AppColors.backgroundGradientStart` | `#C9E8F5`   | Soft Sky — gradient origin          |
| `AppColors.surface`                 | `#FFFFFF`   | White — cards, panels               |
| `AppColors.textPrimary`             | `#1A2B5E`   | Main body text                      |
| `AppColors.textSecondary`           | `#29B6D8`   | Accented / label text               |
| `AppColors.textMuted`               | `#7A9BB5`   | Hints, placeholders, captions       |
| `AppColors.border`                  | `#4029B6D8` | Cyan @ 25% — dividers, card borders |
| `AppColors.shadow`                  | `#1F1A2B5E` | Navy @ 12% — box shadows            |
| `AppColors.success`                 | `#29B6D8`   | Semantic success                    |
| `AppColors.warning`                 | `#F5A623`   | Semantic warning                    |
| `AppColors.error`                   | `#E05252`   | Semantic error                      |
| `AppColors.info`                    | `#29B6D8`   | Semantic info                       |

### Gradients

| Token                          | Colors                                          |
| ------------------------------ | ----------------------------------------------- |
| `AppColors.backgroundGradient` | `#C9E8F5` → `#E8F4FB` (top-left → bottom-right) |
| `AppColors.primaryGradient`    | `#29B6D8` → `#1A2B5E`                           |
| `AppColors.accentGradient`     | `#F5A623` → `#E8913A`                           |

---

## 🖼️ Theme

**File:** `lib/ui/theme/app_theme.dart`

```dart
// main.dart usage:
import 'package:digital_library/ui/theme/app_theme.dart';

MaterialApp(
  theme: AppTheme.light,
)
```

### What's covered in AppTheme.light

| Element                | Key Config                                              |
| ---------------------- | ------------------------------------------------------- |
| `AppBarTheme`          | White bg, Navy text, no elevation                       |
| `CardThemeData`        | White surface, `#4029B6D8` border, 16px radius          |
| `ElevatedButtonTheme`  | Navy bg, white text, 12px radius                        |
| `OutlinedButtonTheme`  | Navy text, Cyan border, 12px radius                     |
| `InputDecorationTheme` | White fill, Cyan focus border, 12px radius              |
| `BottomNavigationBar`  | White bg, Cyan selected, Muted unselected               |
| `ChipTheme`            | Ice Blue bg, Cyan selected, 8px radius                  |
| `DividerTheme`         | Cyan @ 25% opacity, 1px                                 |
| `TextTheme`            | Navy primaries, Cyan secondary titles, Muted small text |

> **Known fix:** Use `CardThemeData` (not `CardTheme`) in `ThemeData` — Material 3 requires `CardThemeData`.

---

## 🧩 Components

### ToastService

**Files:** `lib/core/utils/toast_service.dart`, `toast_types.dart`, `lib/ui/components/toasts/app_toast.dart`

```dart
ToastService.showSuccess('Login successful');
ToastService.showError('Email already exists');
ToastService.showInfo('Processing your request...');
ToastService.showWarning('This action cannot be undone');
```

- Auto-dismisses after 3 seconds
- Uses `scaffoldMessengerKey` in `main.dart`
- Types: Success (green), Error (red), Info (blue), Warning (orange)

---

### AppModal

**File:** `lib/ui/components/modals/app_modal.dart`

```dart
showAppModal(
  context: context,
  title: 'Confirm Action',
  content: const Text('Are you sure?'),
  actions: [
    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
    FilledButton(onPressed: () { /* action */ Navigator.pop(context); }, child: const Text('Confirm')),
  ],
);
```

- Scrollable content
- Dismissible X button in header
- Max width: 90% of screen

---

### AppSidebar

**File:** `lib/ui/components/navigation/app_sidebar.dart`

- Collapsible menu
- Role-based: `ClientLayout` / `AdminLayout`
- Uses callback-based index switching (`onMenuTap(index)`) inside shell layout
- Logout opens `AppModal` confirmation first, then clears navigation stack on confirm
- Driven by `MenuConfig` → `MenuSection` → `MenuItem` (see `models/menu_model.dart`)

### BookInfoCard

**File:** `lib/ui/components/cards/book_info_card.dart`

- Reusable book presentation card used in admin details
- Displays cover, title, authors, metadata chips, and description section
- Accepts `Livre` model directly (`BookInfoCard(livre: book)`)

### PdfPreviewCard

**File:** `lib/ui/components/cards/pdf_preview_card.dart`

- Reusable inline PDF preview component for book detail pages
- Fetches presigned URL with `LivreService.getLivrePdfUrl(livreId)` (`GET /livres/:id/lire`)
- Downloads PDF and renders it with `flutter_pdfview`
- Uses a larger viewport for readability and provides explicit zoom in / zoom out controls
- Provides previous/next page controls with live page index (`current / total`) to guarantee page swapping

---

## Navigation Architecture

The app has 3 navigation layers:

Layer 1 — Auth (no drawer, no layout)

- SessionGatePage, LoginPage, SignupPage
- Uses pushReplacementNamed to enter the shell

Layer 2 — Shell (ClientLayout / AdminLayout)

- Single StatefulWidget with \_selectedIndex and a \_pages list
- Pages are swapped via setState(\_selectedIndex = index), NOT Navigator
- The drawer calls onMenuTap(index) which updates index and closes drawer
- The router only ever registers '/client' and '/admin', never individual pages
- New shell pages must be added to \_pages list and MenuConfig only

Layer 3 — Detail pages (no drawer, back button)

- Sit on top of the shell via Navigator.pushNamed
- Must be registered in app_router.dart
- User presses back → lands back in the shell at the same index

## Navigating to a shell page from a button

Use ClientLayoutNotifier (ChangeNotifier) to switch pages from anywhere
inside the shell without passing callbacks:

context.read<ClientLayoutNotifier>().switchPage(1);

ClientLayoutNotifier lives in lib/core/navigation/client_layout_notifier.dart
It is provided at the ClientLayout level via ChangeNotifierProvider.

## Navigation Rule Table

| Scenario                                      | Method                                                              |
| --------------------------------------------- | ------------------------------------------------------------------- |
| Tap drawer item                               | onMenuTap(index) inside AppSidebar                                  |
| Button inside shell page → another shell page | context.read<ClientLayoutNotifier>().switchPage(index)              |
| Button inside shell page → detail page        | Navigator.pushNamed(context, '/route')                              |
| Detail page → back to shell                   | Navigator.pop(context)                                              |
| Login success → shell                         | Navigator.pushReplacementNamed(context, '/client')                  |
| Logout → login                                | Navigator.pushNamedAndRemoveUntil(context, '/login', (\_) => false) |

## Updated app_router.dart routes

| Route              | Page                | Notes                                   |
| ------------------ | ------------------- | --------------------------------------- |
| /                  | SessionGatePage     | entry point                             |
| /login             | LoginPage           |                                         |
| /signup            | SignupPage          |                                         |
| /client            | ClientLayout        | shell, supports `initialIndex` argument |
| /admin             | AdminLayout         | shell, supports `initialIndex` argument |
| /admin/user/detail | AdminUserDetailPage | Layer 3 detail page                     |
| /admin/book/create | AdminCreateBookPage | Layer 3 detail page                     |
| /admin/book/detail | AdminBookDetailPage | Layer 3 detail page                     |
| /client/cart       | ClientCartPage      | Layer 3 detail page                     |

Any route beyond these is a Layer 3 detail page and must be registered here.

---

## 🔌 Services & API

**Files:** `lib/service/` + `lib/core/api/`

| File                       | Responsibility                                                                                                                    |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| `core/api/api_config.dart` | Base URL + endpoint constants (`auth`, `users`, `livres`)                                                                         |
| `auth_api_service.dart`    | Raw HTTP calls for login/signup/refresh + safe parsing for map/string/primitive error payloads + FR/EN password key compatibility |
| `auth_service.dart`        | Auth logic, JWT storage via SecureStorage                                                                                         |
| `categorie_service.dart`   | Category fetch/create for admin book creation flow                                                                                |
| `user_service.dart`        | User fetch/edit/delete flows                                                                                                      |
| `livre_service.dart`       | Livre list/detail/read-url/review/admin CRUD with multipart upload                                                                |

- `AuthInterceptor` excludes `/auth/login` and `/auth/signup` from token injection.
- Auth requests are also sent with `Options(extra: {'requiresAuth': false})` to force public access.
- Token read key is `auth_token` (with fallback to legacy `access_token`).
- Default base URL currently: Android uses Railway HTTPS API, iOS/macOS uses local Wi-Fi IP `http://172.23.0.144:8000/api`.
- Presigned file URLs from backend that start with `http://localhost:9000` are normalized in `LivreService` to use `ApiConfig.minioUrl`.
- `ApiConfig.minioUrl` is configurable via `MINIO_URL` environment variable.
- Book creation page uses `file_picker` to attach PDF + cover image before calling `LivreService.creerLivre()`.
- Book creation fetches categories from `/categories`, allows selecting from dropdown, and supports creating a new category inline (admin).
- Never use port `9000`/`9001` for API base URL (reserved for MinIO services).
- For iOS development over HTTP, ATS is enabled in `ios/Runner/Info.plist`.

---

## 📦 Models

| File                        | Class / Types                                        | Notes                                           |
| --------------------------- | ---------------------------------------------------- | ----------------------------------------------- |
| `user_model.dart`           | `User`                                               | User data model                                 |
| `menu_model.dart`           | `MenuConfig`, `MenuSection`, `MenuItem`              | Sidebar nav structure                           |
| `categorie_model.dart`      | `Categorie`                                          | Category entity                                 |
| `avis_model.dart`           | `Avis`                                               | Embedded review entity                          |
| `livre_model.dart`          | `Livre`                                              | Book entity (supports populated or id category) |
| `ligne_commande_model.dart` | `LigneCommande`                                      | Embedded order line snapshot                    |
| `commande_model.dart`       | `Commande`, `CommandeStatut`, `CommandeStatutMapper` | Order aggregate + status mapping                |
| `lecture_model.dart`        | `Lecture`                                            | Reading progress entity                         |

---

## ⚙️ Infrastructure (Docker)

**File:** `docker-compose.yml`

| Service | Image         | Ports          | Credentials (default)      |
| ------- | ------------- | -------------- | -------------------------- |
| MongoDB | `mongo:7`     | `27017`        | admin / admin123           |
| MinIO   | `minio/minio` | `9000`, `9001` | minioadmin / minioadmin123 |

Volumes: `mongodb_data`, `minio_data`

---

## 📋 Quick Component Reference

| Component           | File Path                                           | Usage                                               |
| ------------------- | --------------------------------------------------- | --------------------------------------------------- |
| `AppColors`         | `lib/core/utils/app_colors.dart`                    | `AppColors.primary`                                 |
| `AppTheme`          | `lib/ui/theme/app_theme.dart`                       | `AppTheme.light`                                    |
| `AppToast`          | `lib/ui/components/toasts/app_toast.dart`           | `ToastService.showSuccess()`                        |
| `AppModal`          | `lib/ui/components/modals/app_modal.dart`           | `showAppModal()`                                    |
| `AppSidebar`        | `lib/ui/components/navigation/app_sidebar.dart`     | `ClientLayout`, `AdminLayout`                       |
| `AdminBookGridCard` | `lib/ui/components/cards/admin_book_grid_card.dart` | Reusable admin book grid tile (cover, title, price) |
| `BookInfoCard`      | `lib/ui/components/cards/book_info_card.dart`       | Reusable book detail section                        |
| `PdfPreviewCard`    | `lib/ui/components/cards/pdf_preview_card.dart`     | Reusable inline PDF preview                         |
| `LibraryAppBar`     | `lib/ui/components/navigation/library_app_bar.dart` | Shared app bar (admin/client)                       |
| `ToastService`      | `lib/core/utils/toast_service.dart`                 | Static methods                                      |
| `AppRouter`         | `lib/core/navigation/app_router.dart`               | `Navigator.pushNamed()`                             |

---

## ✅ Agent Rules

1. **Always use `AppColors.*` tokens** — never hardcode hex values in widgets.
2. **Always use `AppTheme.light`** — never use `ColorScheme.fromSeed()`.
3. **Use `CardThemeData`** not `CardTheme` in `ThemeData` (Material 3).
4. **Toast feedback on every async action** — success, error, or info.
5. **New page?** → Add it to the File Structure and Navigation table above.
6. **New component?** → Add it to the Components section and Quick Reference table above.
7. **New color/gradient?** → Add it to `AppColors` and the Color Palette table above.
8. **New service?** → Add it under Services & API above.
9. **New model?** → Add it under Models above.
10. **Navigation** uses single-shell state in layouts: sidebar calls `onMenuTap(index)` and pages switch via `setState`, not route pushes.
