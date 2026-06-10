# Dokumentasi Kode: Genshin Import Mobile App

## 1. Ringkasan Proyek

**Genshin Import** adalah aplikasi mobile hybrid bertema e-commerce merchandise Genshin Impact. Aplikasi ini memungkinkan pengguna melihat katalog senjata/artifact, melihat detail produk, menambahkan item ke wishlist, membeli item, menerima kode redeem, melihat riwayat transaksi, serta memberi komentar dan rating produk.

Proyek terdiri dari dua aplikasi utama:

- **Frontend**: aplikasi Flutter di folder `frontend/`.
- **Backend**: REST API Node.js Express di folder `backend/`.
- **Database**: MySQL dengan fallback mock database untuk kebutuhan pengembangan tertentu.

Arsitektur umumnya adalah client-server:

1. Flutter mengirim request HTTP ke API.
2. Backend Express memvalidasi request, menjalankan business logic, dan mengakses database.
3. MySQL menyimpan user, katalog produk, statistik produk, komentar, transaksi, token sesi, dan kode redeem.

## 2. Teknologi yang Digunakan

### Frontend

- **Flutter SDK** dengan Dart.
- **Provider** untuk state management.
- **http** untuk komunikasi REST API.
- **shared_preferences** untuk penyimpanan lokal token, user, wishlist, dan log error lokal.
- **google_sign_in** untuk login Google.
- **google_fonts** untuk styling font.

### Backend

- **Node.js** dengan ES Modules.
- **Express.js** sebagai HTTP server.
- **mysql2/promise** untuk koneksi MySQL async.
- **bcryptjs** untuk hashing dan verifikasi password.
- **uuid** untuk ID berbasis UUID.
- **crypto** bawaan Node.js untuk token sesi acak.
- **cors** dan **dotenv** untuk konfigurasi server.

## 3. Struktur Folder

```text
.
+-- DOCUMENTATION.md              # Dokumentasi lama berbahasa Inggris
+-- DOKUMENTASI_ID.md             # Dokumentasi kode berbahasa Indonesia
+-- backend/
|   +-- package.json              # Script dan dependency backend
|   +-- database/
|   |   +-- schema.sql            # Skema database dan seed data
|   |   +-- init_db.js            # Inisialisasi database
|   +-- src/
|   |   +-- app.js                # Entry point Express
|   |   +-- config/db.js          # Koneksi MySQL dan mock DB
|   |   +-- controllers/          # Handler request/response
|   |   +-- middleware/           # Auth, role guard, error handler
|   |   +-- repositories/         # Query SQL
|   |   +-- routes/               # Definisi endpoint
|   |   +-- services/             # Validasi dan business logic
|   +-- tests/
|       +-- api.http              # Koleksi request manual
|       +-- integration.js        # Test integrasi backend
+-- frontend/
|   +-- pubspec.yaml              # Dependency, asset, dan konfigurasi Flutter
|   +-- lib/
|   |   +-- main.dart             # Entry point aplikasi Flutter
|   |   +-- config/theme.dart     # Tema aplikasi
|   |   +-- models/               # Model data
|   |   +-- providers/            # State management Provider
|   |   +-- services/             # HTTP client dan local service
|   |   +-- views/                # Halaman UI
|   +-- assets/ dan asset/        # Gambar produk, ikon, auth, home
+-- design/                       # Referensi desain UI
```

## 4. Akun Seed

Database seed membuat dua akun awal. Password keduanya adalah `password123`.

| Role | Nama | Email | Password |
| --- | --- | --- | --- |
| Admin | Aimin Admin | `admin@gachamerch.com` | `password123` |
| User | Tabibito User | `user@gachamerch.com` | `password123` |

Password tidak disimpan sebagai teks asli di database. Nilai yang tersimpan adalah hash bcrypt.

## 5. Cara Menjalankan Proyek

### 5.1 Menjalankan Backend

Masuk ke folder backend:

```bash
cd backend
npm install
```

Konfigurasi default memakai MySQL lokal seperti XAMPP:

```ini
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=
DB_NAME=genshin_import
```

Inisialisasi database:

```bash
npm run db:init
```

Jalankan server:

```bash
npm run dev
```

Server berjalan di:

```text
http://localhost:3000
```

Endpoint health check:

- `GET /`
- `GET /api/health/db`

### 5.2 Menjalankan Frontend

Masuk ke folder frontend:

```bash
cd frontend
flutter pub get
flutter run
```

Base URL API ditentukan otomatis oleh `frontend/lib/services/api_service.dart`:

- Web/iOS/desktop: `http://localhost:3000/api`
- Android emulator: `http://10.0.2.2:3000/api`

Jika memakai perangkat Android fisik, base URL perlu disesuaikan ke alamat IP komputer yang menjalankan backend.

## 6. Arsitektur Backend

Backend memakai pola **route -> controller -> service -> repository -> database**.

### 6.1 Route

Route mendefinisikan alamat endpoint dan middleware yang digunakan.

- `authRoutes.js`: register, login, OAuth, me, logout.
- `weaponRoutes.js`: katalog produk, detail produk, komentar produk, CRUD admin.
- `transactionRoutes.js`: pembelian dan riwayat transaksi.

### 6.2 Controller

Controller bertugas membaca input dari `req`, memanggil service, lalu mengirim response JSON.

Contoh tanggung jawab controller:

- Mengambil `req.body`.
- Mengambil `req.params.id`.
- Mengambil user login dari `req.user`.
- Menentukan status HTTP seperti `200`, `201`, atau meneruskan error ke middleware.

### 6.3 Service

Service berisi business logic utama:

- Validasi format email dan password.
- Hash password dengan bcrypt.
- Generate token sesi 20 karakter.
- Validasi data produk.
- Validasi stok saat pembelian.
- Generate kode redeem.
- Update rating produk setelah komentar dibuat.

### 6.4 Repository

Repository memisahkan query SQL dari logic aplikasi. File repository bertanggung jawab menjalankan `SELECT`, `INSERT`, `UPDATE`, dan query join.

Manfaat pola ini:

- Controller tetap tipis.
- Business logic lebih mudah diuji.
- SQL terpusat dan tidak tersebar di UI/API handler.

### 6.5 Middleware

Backend memiliki dua middleware penting:

- `authMiddleware`: memvalidasi header `Authorization: Bearer <token>`.
- `roleMiddleware`: membatasi endpoint tertentu hanya untuk role tertentu, terutama admin.

Jika token tidak ada, format salah, atau token tidak ditemukan di database, API mengembalikan `401`. Jika user login tetapi bukan admin untuk endpoint admin, API mengembalikan `403`.

## 7. Autentikasi dan Otorisasi

### 7.1 Register Manual

Endpoint:

```http
POST /api/auth/register
```

Payload:

```json
{
  "name": "Nama User",
  "email": "user@example.com",
  "password": "password123"
}
```

Validasi:

- Email wajib ada dan mengandung `@`.
- Password minimal 6 karakter.
- Email tidak boleh sudah terdaftar.

Password akan di-hash menggunakan bcrypt dengan salt round 10.

### 7.2 Login Manual

Endpoint:

```http
POST /api/auth/login
```

Payload:

```json
{
  "email": "admin@gachamerch.com",
  "password": "password123"
}
```

Jika berhasil, backend membuat token sesi 20 karakter dengan:

```js
crypto.randomBytes(10).toString('hex')
```

Response:

```json
{
  "message": "Login berhasil!",
  "token": "contoh20karakterhex",
  "user": {
    "id": "uuid-user",
    "name": "Aimin Admin",
    "email": "admin@gachamerch.com",
    "role": "admin"
  }
}
```

Frontend menyimpan token ke `SharedPreferences` dengan key `auth_token`.

### 7.3 OAuth

Endpoint:

```http
POST /api/auth/oauth
```

Payload:

```json
{
  "email": "google_user@example.com",
  "name": "Google User",
  "oauth_id": "google-oauth-id"
}
```

Alur OAuth:

1. Backend mencari user berdasarkan `oauth_id`.
2. Jika tidak ada, backend mencari user dengan email yang sama.
3. Jika email sudah ada, backend menghubungkan `oauth_id` ke akun tersebut.
4. Jika belum ada akun, backend membuat user baru dengan role `user`.
5. Backend membuat token sesi baru dan mengembalikannya ke frontend.

### 7.4 Me dan Logout

Endpoint cek sesi:

```http
GET /api/auth/me
Authorization: Bearer <token>
```

Endpoint logout:

```http
POST /api/auth/logout
Authorization: Bearer <token>
```

Logout menghapus `session_token` di database dan frontend juga menghapus token lokal.

## 8. Endpoint API

### 8.1 Auth

| Method | Endpoint | Akses | Fungsi |
| --- | --- | --- | --- |
| `POST` | `/api/auth/register` | Public | Membuat akun user lokal |
| `POST` | `/api/auth/login` | Public | Login email/password |
| `POST` | `/api/auth/oauth` | Public | Login/register OAuth |
| `GET` | `/api/auth/me` | User/Admin | Mengambil user dari token aktif |
| `POST` | `/api/auth/logout` | User/Admin | Menghapus sesi token |

### 8.2 Weapons / Products

| Method | Endpoint | Akses | Fungsi |
| --- | --- | --- | --- |
| `GET` | `/api/weapons` | Public | Mengambil katalog produk aktif |
| `GET` | `/api/weapons/:id` | User/Admin | Mengambil detail produk |
| `POST` | `/api/weapons` | Admin | Membuat produk baru |
| `PUT` | `/api/weapons/:id` | Admin | Mengubah produk |
| `DELETE` | `/api/weapons/:id` | Admin | Soft-delete produk |
| `GET` | `/api/weapons/:id/comments` | Public | Mengambil komentar produk |
| `POST` | `/api/weapons/:id/comments` | User/Admin | Menambah komentar dan rating |

### 8.3 Transactions

| Method | Endpoint | Akses | Fungsi |
| --- | --- | --- | --- |
| `POST` | `/api/transactions` | User/Admin | Membeli produk |
| `GET` | `/api/transactions/history` | User/Admin | Melihat riwayat transaksi user login |

## 9. Database

Database utama bernama `genshin_import`.

### 9.1 Tabel `users`

Menyimpan akun aplikasi.

| Kolom | Fungsi |
| --- | --- |
| `id` | UUID user |
| `name` | Nama user |
| `email` | Email unik |
| `password` | Hash bcrypt untuk login manual |
| `oauth_id` | ID provider OAuth |
| `role` | `admin` atau `user` |
| `session_token` | Token sesi aktif |

### 9.2 Tabel `weapons`

Menyimpan data produk.

| Kolom | Fungsi |
| --- | --- |
| `id` | UUID/string ID produk |
| `name` | Nama produk |
| `type` | Kategori produk, misalnya Sword, Claymore, Bow |
| `description` | Deskripsi produk |
| `stock` | Jumlah stok |
| `image` | Asset thumbnail |
| `price` | Harga |
| `banner` | Asset banner detail |
| `showcase1..3` | Asset gambar showcase |
| `deleted_at` | Penanda soft delete |

Soft delete berarti produk tidak benar-benar dihapus dari database. Produk hanya diberi timestamp `deleted_at`, sehingga data transaksi historis tetap valid.

### 9.3 Tabel `weapon_stats`

Menyimpan statistik tambahan produk.

| Kolom | Fungsi |
| --- | --- |
| `weapon_id` | Foreign key ke `weapons` |
| `ratings` | Rating tampilan |
| `dmg` | Nilai damage |
| `crit_rate` | Critical rate |
| `crit_dmg` | Critical damage |

### 9.4 Tabel `comments`

Menyimpan review produk.

| Kolom | Fungsi |
| --- | --- |
| `id` | UUID komentar |
| `weapon_id` | Produk yang dikomentari |
| `user_id` | User pembuat komentar |
| `rating` | Rating 1 sampai 5 |
| `content` | Isi komentar |
| `created_at` | Waktu komentar dibuat |

Setelah komentar dibuat, backend menghitung rata-rata rating produk dan memperbarui `weapon_stats.ratings`.

### 9.5 Tabel `transactions`

Menyimpan riwayat pembelian.

| Kolom | Fungsi |
| --- | --- |
| `id` | UUID transaksi |
| `user_id` | User pembeli |
| `weapon_id` | Produk yang dibeli |
| `quantity` | Jumlah item |
| `total_price` | Total harga |
| `redeem_code` | Kode redeem hasil pembelian |
| `created_at` | Waktu transaksi |

## 10. Alur Pembelian

Alur pembelian berada di `transactionService.js`.

1. Frontend mengirim `weapon_id` dan `quantity` ke `POST /api/transactions`.
2. `authMiddleware` memastikan user sudah login.
3. Service memvalidasi `weapon_id` dan `quantity`.
4. Backend membuka koneksi database dan memulai transaksi.
5. Produk diambil dengan query `SELECT ... FOR UPDATE` agar row stok terkunci.
6. Backend mengecek apakah produk aktif dan stok cukup.
7. Jika stok tidak cukup, transaksi di-rollback dan API mengembalikan error `422`.
8. Jika stok cukup, backend mengurangi stok.
9. Backend membuat record transaksi.
10. Backend membuat kode redeem dengan format `GS-XXXX-XXXX-XXXX`.
11. Database commit.
12. Frontend menampilkan transaksi dan kode redeem.

Penggunaan transaksi database mencegah kondisi race saat dua pembelian terjadi bersamaan pada produk yang sama.

## 11. Validasi Bisnis

| Kode | Area | Aturan |
| --- | --- | --- |
| VAL-01 | Auth | Email wajib valid, password minimal 6 karakter |
| VAL-02 | Admin product form | Nama, harga, stok wajib valid; harga dan stok harus positif |
| VAL-03 | Pembelian | Quantity harus positif dan tidak boleh melebihi stok |
| VAL-04 | Komentar | Rating harus 1-5, komentar 3-500 karakter |

Contoh pesan error:

- `Format email tidak valid atau password terlalu pendek!`
- `Data produk tidak valid! Pastikan harga dan stok berupa angka positif.`
- `Transaksi Gagal: Jumlah pembelian melebihi sisa stok yang tersedia!`
- `Rating harus berupa angka dari 1 sampai 5.`

## 12. Arsitektur Frontend

Frontend memakai pola **model -> service -> provider -> view**.

### 12.1 Model

Model berada di `frontend/lib/models/`.

- `User`: id, name, email, role.
- `Weapon`: data produk, asset gambar, harga, stok, statistik.
- `Transaction`: data pembelian, total harga, kode redeem, metadata produk.
- `ProductComment`: komentar, rating, user pembuat, waktu pembuatan.

Model bertugas mengubah JSON API menjadi object Dart melalui factory `fromJson`.

### 12.2 Service

Service berada di `frontend/lib/services/`.

- `ApiService`: menentukan base URL, membuat header HTTP, menyimpan/mengambil token.
- `AuthService`: register, login, OAuth, me, logout.
- `WeaponService`: katalog, detail, create, update, delete produk.
- `TransactionService`: purchase dan history.
- `CommentService`: list komentar dan create komentar.
- `ErrorLogService`: menyimpan log error lokal di `SharedPreferences`.

Service tidak menyimpan state UI. Tugasnya hanya melakukan IO dan parsing response.

### 12.3 Provider

Provider berada di `frontend/lib/providers/`.

- `AuthProvider`: status login, user aktif, role admin, loading auth.
- `WeaponProvider`: daftar produk, filter kategori, pencarian, operasi admin.
- `TransactionProvider`: riwayat transaksi dan status pembelian.
- `WishlistProvider`: wishlist lokal berbasis ID produk.
- `CommentProvider`: komentar per produk dan status submit komentar.

Semua provider memakai `ChangeNotifier`, lalu UI bereaksi melalui `Provider`/`Consumer`.

### 12.4 View

View berada di `frontend/lib/views/`.

Halaman utama:

- `home_screen.dart`: home, katalog, search, kategori, wishlist, navigasi bawah.
- `login_screen.dart`: login email/password, Google login, mock login fallback.
- `register_screen.dart`: registrasi akun dan OAuth.
- `detail_screen.dart`: detail produk, rating, komentar, checkout, wishlist.
- `history_screen.dart`: daftar transaksi dan kode redeem.
- `admin_dashboard.dart`: panel admin untuk kelola katalog.
- `weapon_form.dart`: form tambah/edit produk.
- `error_logs_screen.dart`: konsol log error lokal.

Komponen reusable:

- `glass_text_field.dart`
- `get_button.dart`
- `error_dialog.dart`
- `loading_skeleton.dart`
- Widget home seperti `weapon_hero_card.dart`, `trending_item_tile.dart`, dan `category_chip.dart`.

## 13. State dan Penyimpanan Lokal

Frontend menyimpan beberapa data lokal:

| Key | Isi | Lokasi |
| --- | --- | --- |
| `auth_token` | Bearer token API | `ApiService` |
| `auth_user` | JSON user aktif | `AuthProvider` |
| `wishlist_items` | List ID produk wishlist | `WishlistProvider` |
| `error_logs` | List log error lokal | `ErrorLogService` |

Saat aplikasi dibuka, `AuthProvider` mencoba membaca token lalu memanggil `/auth/me`. Jika token tidak valid, token dan user lokal dihapus.

## 14. Role-Based Access Control

Aplikasi membedakan user biasa dan admin berdasarkan `role`.

### User biasa

User dapat:

- Melihat katalog.
- Melihat detail produk setelah login untuk endpoint detail.
- Menambah wishlist.
- Membeli produk.
- Melihat riwayat transaksi.
- Membuat komentar/rating.

### Admin

Admin dapat:

- Melakukan semua fitur user.
- Membuat produk.
- Mengubah produk.
- Soft-delete produk.
- Mengakses dashboard admin.
- Melihat dan menghapus log error lokal.

Pada frontend, tab pertama di bottom navigation berubah menjadi admin dashboard jika `authProvider.isAdmin == true`.

## 15. Error Handling

### Backend

Backend memakai `errorMiddleware` untuk menyamakan format error JSON. Service membuat `Error`, lalu menambahkan `statusCode`. Controller meneruskan error memakai `next(error)`.

Contoh response error:

```json
{
  "message": "Produk tidak ditemukan!"
}
```

### Frontend

Service Flutter mengecek status code. Jika bukan `2xx`, service mencoba membaca `message` dari response JSON dan melemparkannya sebagai `Exception`.

Provider menyimpan pesan error di `errorMessage`. UI dapat menampilkan error melalui dialog/snackbar. `ErrorLogService` juga bisa menyimpan error ke penyimpanan lokal agar admin dapat melihatnya dari layar error log.

## 16. Fitur Kreativitas

### 16.1 Kode Redeem

Setelah pembelian berhasil, backend membuat kode redeem:

```text
GS-XXXX-XXXX-XXXX
```

Kode ini disimpan di transaksi dan tampil di confirmation/history screen.

### 16.2 Admin Error Logging Console

Aplikasi menyimpan error dialog ke local storage. Admin dapat membuka halaman log untuk:

- Melihat error terbaru.
- Menyalin pesan error.
- Menghapus log.

### 16.3 Mock Login Fallback

Login/register mendukung Google Sign-In. Jika emulator atau platform belum dikonfigurasi untuk Google Sign-In, UI menyediakan fallback mock login agar pengembangan tetap bisa berjalan.

## 17. Testing

### Backend

Backend memiliki test integrasi:

```bash
cd backend
npm run test
```

Test mencakup:

- Health check.
- Login admin.
- Login user.
- CRUD admin.
- Pembelian dan pengurangan stok.
- Soft delete produk.

Request manual tersedia di:

```text
backend/tests/api.http
```

### Frontend

Frontend memiliki widget test dasar di:

```text
frontend/test/widget_test.dart
```

Jalankan dengan:

```bash
cd frontend
flutter test
```

## 18. Catatan Pengembangan

Hal yang perlu diperhatikan saat mengembangkan proyek ini:

- Jangan menyimpan password plaintext di database.
- Gunakan `ApiService.getHeaders()` untuk endpoint yang butuh token.
- Jika menambah endpoint protected, pasang `authMiddleware`.
- Jika endpoint hanya untuk admin, tambahkan `roleMiddleware(['admin'])`.
- Jika menambah field produk di database, update juga:
  - `schema.sql`
  - repository terkait
  - service create/update
  - model `Weapon`
  - form admin jika field perlu diinput
- Jika menambah data lokal Flutter, definisikan key dengan jelas agar tidak bentrok.
- Untuk Android emulator, `localhost` backend harus diakses dari Flutter sebagai `10.0.2.2`.

## 19. Ringkasan Alur Data

Contoh alur login:

```text
LoginScreen
  -> AuthProvider.login()
  -> AuthService.login()
  -> POST /api/auth/login
  -> authController.login()
  -> authService.login()
  -> userRepository.findByEmail()
  -> bcrypt.compare()
  -> userRepository.updateSessionToken()
  -> token disimpan di SharedPreferences
```

Contoh alur katalog:

```text
HomeScreen
  -> WeaponProvider.fetchCatalog()
  -> WeaponService.getCatalog()
  -> GET /api/weapons
  -> weaponController.getCatalog()
  -> weaponService.getCatalog()
  -> weaponRepository.findAllActive()
  -> List<Weapon> tampil di UI
```

Contoh alur pembelian:

```text
DetailScreen
  -> TransactionProvider.purchaseItem()
  -> TransactionService.purchaseItem()
  -> POST /api/transactions
  -> authMiddleware
  -> transactionController.purchaseItem()
  -> transactionService.purchaseItem()
  -> SELECT produk FOR UPDATE
  -> validasi stok
  -> update stok
  -> insert transaksi + redeem code
  -> commit
  -> transaksi tampil di UI
```
