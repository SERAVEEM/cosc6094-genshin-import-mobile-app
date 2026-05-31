# Project Documentation: Genshin Import (Mobile Hybrid Solution)

**Course Code**: COSC6094 — Mobile Hybrid Solution  
**Frameworks**: Flutter SDK (Front-End) & Node.js Express (Back-End)  
**Database**: MySQL / Mock DB  
**Theme**: Genshin Impact Premium Dark Mode

---

## 1. System Overview
**Genshin Import** is a mobile hybrid e-commerce application designed for browsing and purchasing weapons and artifacts from Teyvat. The system uses a multi-tier client-server architecture:
* **Front-End**: Cross-platform mobile app built using **Flutter**.
* **Back-End**: RESTful API service built using **Node.js** and **Express**.
* **Database**: **MySQL** relational database (or built-in mock layer for development and testing).

The application features strict **Role-Based Access Control (RBAC)** divided into two personas:
1. **Regular User**: Browses catalog, views weapon specifications, adds items to wishlist, purchases items, and views purchase history with redeemable codes.
2. **Administrator**: Manages the store catalog with full CRUD capability (add, read, update, soft-delete products) and diagnoses system warnings via the local error logging console.

---

## 2. Feature Details & Creativity

### 1. In-Game Redemption Codes (Creativity Feature)
To mimic real-world gacha-merchandise interactions, after completing a purchase, the application generates a copyable, uniquely formatted redemption code (e.g. `GS-XXXX-XXXX-XXXX`). Users can copy this code to their clipboard from the confirmation modal or the transaction history screen.

### 2. Administrator Error Logging Console (Creativity Feature)
An independent system error log triggers whenever an error dialog is presented to the user. Admins can access the local console from the dashboard, inspect errors chronologically with timestamps, copy messages, and clear the database logs.

### 3. Native Google Sign-In with Developer Fallback
The login/register views support native Google Sign-In. To prevent emulator crashes on unconfigured platforms (where the debug SHA-1 signature is not registered in Google Console), the app catches platform exceptions and presents a fallback option allowing developers to log in using a mock Google Traveler profile.

---

## 3. Front-End (Flutter Mobile App) Page Index

The application implements **8 interactive pages**:
1. **Login Screen** (`login_screen.dart`): Handles manual email validation and native Google Sign-In with developer fallback.
2. **Register Screen** (`register_screen.dart`): Form validation for email format, password length, and match check.
3. **Home Screen** (`home_screen.dart`): Displays trending weapons list, categories filter, search bar, and wishlist tab.
4. **Detail Screen** (`detail_screen.dart`): Shows base stats, artifact ratings, descriptions, real-time stock status, and order bottom sheet sheet.
5. **History Screen** (`history_screen.dart`): Lists purchase records, total pricing, and copyable redemption codes.
6. **Admin Dashboard** (`admin_dashboard.dart`): Allows administrators to view all active items and delete/edit products.
7. **Weapon Form Screen** (`weapon_form.dart`): Admin form to insert/update weapons with validation checks.
8. **Error Logs Screen** (`error_logs_screen.dart`): Interactive log console showing timestamps and copy triggers.

### UI Components Used
* **Layouts**: `GridView`, `ListView`, `RefreshIndicator`, `Divider`
* **Input Fields**: `TextFormField` (with golden border decorations), `DropdownButtonFormField`
* **Containers**: Glassmorphic `Card` panels, rounded image thumbnails
* **Controls**: `ElevatedButton`, `TextButton`, `IconButton`, `BottomNavigationBar`

---

## 4. Data Validation Rules

The application implements strict data validation:

| Code | Trigger | Validation Rules | Error Message Shown |
| :--- | :--- | :--- | :--- |
| **VAL-01** | Auth Forms | Email must be non-empty and contain `@`. Password must be $\ge 6$ characters. | `"Format email tidak valid atau password terlalu pendek!"` |
| **VAL-02** | Admin Form | Name, price, and stock must be non-empty. Price and stock must be positive numbers ($> 0$). | `"Data produk tidak valid! Pastikan harga dan stok berupa angka positif."` |
| **VAL-03** | Order Form | Purchase quantity must be positive and less than or equal to current database stock. | `"Transaksi Gagal: Jumlah pembelian melebihi sisa stok yang tersedia!"` |

---

## 5. Back-End Endpoint Documentation (Node.js)

All endpoints utilize custom header bearer verification (`Authorization: Bearer <token>`).

### Public & Auth Endpoints
* `POST /api/auth/register` - Registers a local account (passwords are encrypted using **Bcrypt**).
* `POST /api/auth/login` - Validates credentials and returns a custom **20-character alphanumeric bearer token**.
* `POST /api/auth/oauth` - Connects/registers users using Google OAuth credentials.

### Protected Admin Endpoints
* `POST /api/weapons` - Inserts a new weapon/stats entry.
* `PUT /api/weapons/:id` - Updates weapon metadata or stock.
* `DELETE /api/weapons/:id` - Soft-deletes a product by writing a `deleted_at` timestamp.

### Protected Transaction Endpoints
* `GET /api/weapons` - Retrieves active weapons and stats catalog.
* `GET /api/weapons/:id` - Retrieves detailed stats for a single item.
* `POST /api/transactions` - Performs a transactional purchase (uses MySQL transaction control to guarantee atomicity of stock deduction).

---

## 6. How to Run & Setup

### Database Setup
1. Open XAMPP and start MySQL.
2. Initialize the database schema:
   ```bash
   cd backend
   npm run db:init
   ```

### Back-End Setup
1. Install server dependencies:
   ```bash
   cd backend
   npm install
   ```
2. Start the API server:
   ```bash
   npm run dev
   ```

### Front-End Setup
1. Get Flutter package dependencies:
   ```bash
   cd frontend
   flutter pub get
   ```
2. Run on connected device/emulator:
   ```bash
   flutter run
   ```

---

## 7. Asset References
* **Typography**: Plus Jakarta Sans (Google Fonts)
* **Images & Vector Graphics**: Custom game illustration assets matching standard Genshin Impact properties (Wolf's Gravestone, Mistsplitter, Jade Spear).
* **Icons**: Flutter Material Design Icons pack.
