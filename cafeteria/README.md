# OnTheWay - Cafeteria Management & Ordering System

OnTheWay is a premium, full-featured cafeteria management and ordering system built with Flutter. It provides a seamless experience for both customers (browsing and ordering) and cafeteria staff (managing orders and stock).

## 🚀 Key Features

### 🛒 Customer App
- **Menu Browsing**: Browse items by categories with a rich, responsive UI.
- **Customization**: Personalize orders with variants (e.g., size, extras).
- **Cart Management**: Add, remove, and manage item quantities easily.
- **Favorites**: Save your favorite drinks and snacks for quick access.
- **Order Tracking**: Track current orders and view historical order data.
- **Wallet System**: Check balance and top up for faster payments.

### 🛠️ Admin Panel (Cafeteria Staff)
- **Analytics Dashboard**: Real-time overview of active orders, total revenue, and pending payments.
- **Order Management**: Process incoming orders, update status, and filter by date or payment status.
- **Menu & Stock Control**: Add new items, edit existing ones, and manage stock levels (including variant-specific stock).
- **Settings**: Quick access to theme and language toggles directly from the panel.

### 🔐 Authentication
- **Multi-Role Support**: Different flows for College Staff (Customers) and Cafeteria Staff (Admins).
- **Social Login**: Integration with Google and Microsoft (Outlook) for easy sign-up.
- **Secure Session**: Token-based authentication with auto-routing on app launch.

### 🌍 Global Features
- **Theming**: Premium Light and Dark modes.
- **Localization**: Full support for English and Arabic (RTL support).
- **Responsiveness**: Optimized for various screen sizes.

---

## 🛠️ Tech Stack & Packages

The project follows **Clean Architecture** principles and uses the following industry-standard packages:

- **State Management**: `flutter_bloc` & `equatable` (BLoC pattern for predictable state).
- **Networking**: `dio` (Robust HTTP client with interceptors).
- **Dependency Injection**: `get_it` (Service locator for decoupling).
- **Local Storage**: `shared_preferences` (Persisting tokens, roles, and settings).
- **Functional Programming**: `dartz` (Using `Either` for error handling).
- **Localization**: `flutter_localizations` & `intl` (ARB files for multi-language).
- **Animations**: `animate_do` (Smooth UI transitions).
- **OAuth**: `google_sign_in` & `aad_oauth` (Azure AD for Microsoft login).

---

## 🎨 Customization Guide

If you want to customize the project to fit your specific needs, here is where to look:

### 🔗 API Configuration
To point the app to your own backend server:
- Open `lib/core/constants/api.dart`.
- Update `baseUrl` and specific `EndPoints`.

### 🎨 Colors & Branding
To change the primary brand colors:
- Open `lib/core/constants/colors.dart`.
- Modify `TColors.primary`, `TColors.secondary`, etc.
- The app uses these constants across both light and dark themes.

### 🌓 Theme Customization
To adjust specific widget styles (buttons, text fields):
- Check `lib/core/theme/theme.dart`.
- Look into sub-folders in `lib/core/theme/widget_themes/` for detailed component styles.

### 🌐 Localization (Adding Languages)
To add a new language or change existing text:
1.  Go to `lib/l10n/`.
2.  Edit `app_en.arb` (English) or `app_ar.arb` (Arabic).
3.  Add a new `.arb` file for a different language (e.g., `app_fr.arb`).
4.  Run `flutter gen-l10n` to update the generated localization files.

### 🖼️ Assets
- **Icons/Logos**: Update files in `assets/icons/`.
- **Images**: Update files in `assets/images/`.
- **Image Paths**: Update `lib/core/constants/image_strings.dart` to reflect new filenames.

---

## 🏁 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/your-repo/cafeteria.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run code generation** (for localization and models if applicable):
    ```bash
    flutter gen-l10n
    ```
4.  **Run the app**:
    ```bash
    flutter run
    ```

---

## 🏗️ Project Structure
```text
lib/
├── core/            # Common constants, themes, routing, and network handlers
├── features/        # Feature-driven modules (Auth, Home, Admin, etc.)
│   ├── [feature]/
│   │   ├── data/           # Models, Repositories, Data Sources
│   │   ├── domain/         # Entities, Use Cases, Repository Interfaces
│   │   └── presentation/   # BLoCs, Pages, Widgets
├── l10n/            # Localization files (.arb)
└── main.dart        # Entry point
```

---

## 🔙 Backend

The backend for OnTheWay is located in the `cic-backend/` directory. It is built with **Node.js** and **Express.js**, using **MongoDB** for data persistence.

### 🛠️ Backend Tech Stack
- **Framework**: Express.js
- **Database**: MongoDB (via Mongoose)
- **Authentication**: Better Auth
- **Utilities**: Nodemailer (Email), Morgan (Logging), Biome (Linting/Formatting)
- **Runtime**: Node.js with TypeScript (`tsx`/`tsup`)

### ⚙️ Backend Setup
1.  **Navigate to the backend directory**:
    ```bash
    cd cic-backend
    ```
2.  **Install dependencies**:
    ```bash
    npm install
    ```
3.  **Environment Variables**:
    - Create a `.env` file in the `cic-backend` root.
    - Configure your `MONGODB_URI`, `AUTH_SECRET`, and email settings (SMTP).
4.  **Run in development mode**:
    ```bash
    npm run dev
    ```

---
Made with ❤️ by the OnTheWay Team.
