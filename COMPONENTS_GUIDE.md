# Digital Library - Components & Design Guide

## Components Documentation

### 1. Toast Notifications

Toast notifications for displaying temporary feedback messages throughout the app. Auto-dismisses after 3 seconds.

#### Usage

```dart
// Success notification
ToastService.showSuccess('Login successful');

// Error notification
ToastService.showError('Email already exists');

// Info notification
ToastService.showInfo('Processing your request...');

// Warning notification
ToastService.showWarning('This action cannot be undone');
```

#### Features

- **Auto-dismiss**: Disappears after 3 seconds automatically
- **Manual close**: User can tap the close button
- **Animations**: Smooth slide-up and fade-in animations
- **Types**: Success (green), Error (red), Info (blue), Warning (orange)
- **App-wide access**: Call from any page without context parameters

#### Implementation Details

- **Location**: `/lib/ui/components/toasts/app_toast.dart`
- **Service**: `/lib/core/utils/toast_service.dart`
- **Types**: `/lib/core/utils/toast_types.dart`
- **Integration**: Uses `scaffoldMessengerKey` in `main.dart`

---

### 2. Modal Component

Reusable dialog component for displaying forms, confirmations, and content.

#### Usage

```dart
showAppModal(
  context: context,
  title: 'Confirm Action',
  content: const Text('Are you sure you want to proceed?'),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),
    FilledButton(
      onPressed: () {
        // Handle action
        Navigator.pop(context);
      },
      child: const Text('Confirm'),
    ),
  ],
);
```

#### Features

- **Configurable title**: Set any header text
- **Custom content**: Pass any Widget (forms, text, etc.)
- **Action buttons**: Multiple buttons with custom styling
- **Close button**: X button in header (dismissible option)
- **Scrollable content**: Handles long content gracefully
- **Responsive**: Respects screen width constraints

#### Implementation Details

- **Location**: `/lib/ui/components/modals/app_modal.dart`
- **Helper function**: `showAppModal()` in same file
- **Dialog pattern**: Material Design elevated dialog

---

## Sidebar Navigation

Role-based navigation with collapsible sidebar menu.

#### Features

- **Collapsible menu**: Toggle to show/hide menu items
- **Role-based menus**: Different menus for client/admin roles
- **Auto-routing**: Tap menu item to navigate
- **Logout handling**: Special logout item clears navigation stack
- **Layout integration**: `ClientLayout` and `AdminLayout` wrappers

#### Menu Pages Structure

```
lib/ui/pages/
├── client/
│   ├── client_home_page.dart
│   ├── client_books_page.dart
│   ├── client_favorites_page.dart
│   └── client_profile_page.dart
└── admin/
    ├── admin_home_page.dart
    ├── admin_analytics_page.dart
    ├── admin_books_page.dart
    ├── admin_users_page.dart
    └── admin_settings_page.dart
```

---

## Color Palette

Add your color palette below:

### Primary Colors

- **Primary**:
- **Secondary**:
- **Tertiary**:

### Semantic Colors

- **Success**:
- **Error**:
- **Warning**:
- **Info**:

### Neutral Colors

- **Background**:
- **Surface**:
- **OnPrimary**:
- **OnSecondary**:

### Additional Colors

- **Custom 1**:
- **Custom 2**:
- **Custom 3**:

---

## Theme Configuration

Current theme seed color: `Colors.teal`

Location: `/lib/main.dart`

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
  useMaterial3: true,
),
```

---

## File Structure Reference

```
lib/
├── core/
│   ├── utils/
│   │   ├── toast_types.dart        # Toast type enum & styling
│   │   └── toast_service.dart      # Toast singleton service
│   ├── navigation/
│   │   └── app_router.dart         # Named routing
│   ├── database/
│   ├── network/
│   └── di/
├── ui/
│   ├── components/
│   │   ├── toasts/
│   │   │   └── app_toast.dart      # Toast widget
│   │   ├── modals/
│   │   │   └── app_modal.dart      # Modal dialog widget
│   │   └── navigation/
│   │       └── app_sidebar.dart    # Sidebar drawer
│   └── pages/
│       ├── session_gate_page.dart
│       ├── login_page.dart
│       ├── signup_page.dart
│       ├── client/
│       │   ├── client_layout.dart
│       │   ├── client_home_page.dart
│       │   ├── client_books_page.dart
│       │   ├── client_favorites_page.dart
│       │   └── client_profile_page.dart
│       └── admin/
│           ├── admin_layout.dart
│           ├── admin_home_page.dart
│           ├── admin_analytics_page.dart
│           ├── admin_books_page.dart
│           ├── admin_users_page.dart
│           └── admin_settings_page.dart
├── models/
│   ├── user_model.dart
│   └── menu_model.dart
├── service/
│   ├── api_config.dart
│   ├── auth_api_service.dart
│   └── auth_service.dart
└── main.dart
```

---

## Quick Reference

| Component    | Purpose                      | Location                         | Usage                         |
| ------------ | ---------------------------- | -------------------------------- | ----------------------------- |
| AppToast     | Toast notifications          | `/lib/ui/components/toasts/`     | `ToastService.showSuccess()`  |
| AppModal     | Dialog forms & confirmations | `/lib/ui/components/modals/`     | `showAppModal()`              |
| AppSidebar   | Role-based menu navigation   | `/lib/ui/components/navigation/` | `ClientLayout`, `AdminLayout` |
| ToastService | Global toast management      | `/lib/core/utils/`               | Static methods                |
| AppRouter    | Named route definitions      | `/lib/core/navigation/`          | `Navigator.pushNamed()`       |

---

## Development Notes

- **Toast auto-dismiss**: 3 seconds (configurable per call)
- **Modal responsive**: Max width 90% of screen
- **Sidebar**: Uses `MenuConfig` with `MenuSection` and `MenuItem` models
- **Navigation**: Uses `pushReplacementNamed` for sidebar items (no back history)
- **Auth**: JWT tokens stored in `FlutterSecureStorage`
