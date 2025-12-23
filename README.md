# 📚 Web Manajemen PKL

Aplikasi Manajemen Praktik Kerja Lapangan (PKL) dengan teknologi modern yang terintegrasi antara Web dan Mobile.

## 🛠 Teknologi yang Digunakan

| Teknologi      | Versi   | Keterangan                     |
| -------------- | ------- | ------------------------------ |
| **Flutter**    | >= 3.x  | Mobile App Development         |
| **Laravel**    | >= 10.x | Backend API                    |
| **Vue.js**     | >= 3.x  | Frontend Web Admin             |
| **PostgreSQL** | >= 14.x | Database Server                |
| **PostGIS**    | >= 3.x  | Ekstensi Geospasial PostgreSQL |
| **Laragon**    | >= 6.x  | Local Development Environment  |
| **DBeaver**    | >= 23.x | Database Management Tool       |

---

## 📌 Prasyarat Instalasi

Sebelum memulai, pastikan komputer Anda sudah menginstall:

### 1. Laragon

- Download: [https://laragon.org/download/](https://laragon.org/download/)
- Pilih versi **Full** untuk mendapatkan semua tools

### 2. PostgreSQL

- Download: [https://www.postgresql.org/download/windows/](https://www.postgresql.org/download/windows/)
- Ingat password yang Anda set saat instalasi

### 3. PostGIS

- Download: [https://postgis.net/install/](https://postgis.net/install/)
- Atau install melalui **Stack Builder** setelah install PostgreSQL

### 4. DBeaver

- Download: [https://dbeaver.io/download/](https://dbeaver.io/download/)
- Pilih versi **Community Edition** (gratis)

### 5. Flutter SDK

- Download: [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
- Tambahkan Flutter ke PATH environment variable

### 6. Node.js & NPM

- Download: [https://nodejs.org/](https://nodejs.org/)
- Pilih versi **LTS** yang direkomendasikan

---

## 🚀 Langkah Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/IrpanKuy/web-manajemen-pkl.git
cd web-manajemen-pkl
```

Atau jika sudah ada foldernya:

```bash
cd c:\laragon\www\web-manajemen-pkl
```

---

### 2. Setup Laragon

1. **Buka Laragon**
2. Klik **Menu** → **Preferences**
3. Pastikan **Document Root** mengarah ke `C:\laragon\www`
4. Klik **Start All** untuk menjalankan Apache dan postgresql

---

### 3. Setup PostgreSQL & PostGIS

#### a. Jalankan PostgreSQL Service

```bash
# Cek apakah PostgreSQL sudah berjalan
pg_isready

# Jika belum, jalankan service
net start postgresql-x64-14
```

#### b. Install PostGIS Extension

1. Buka **SQL Shell (psql)** atau gunakan DBeaver
2. Masuk dengan user `postgres`
3. Jalankan perintah:

```sql
-- Buat database baru
CREATE DATABASE db_manajemen_pkl;

-- Koneksi ke database
\c db_manajemen_pkl

-- Aktifkan PostGIS
CREATE EXTENSION postgis;
CREATE EXTENSION postgis_topology;

-- Verifikasi instalasi
SELECT PostGIS_Version();
```

---

### 4. Setup Database dengan DBeaver

#### a. Buat Koneksi Baru

1. Buka **DBeaver**
2. Klik **Database** → **New Database Connection**
3. Pilih **PostgreSQL**
4. Isi konfigurasi:

| Field    | Value                   |
| -------- | ----------------------- |
| Host     | `localhost`             |
| Port     | `5432`                  |
| Database | `db_manajemen_pkl`      |
| Username | `postgres`              |
| Password | (password saat install) |

5. Klik **Test Connection** untuk memastikan berhasil
6. Klik **Finish**

#### b. Verifikasi PostGIS

1. Buka SQL Editor (klik kanan pada database → SQL Editor)
2. Jalankan:

```sql
SELECT * FROM spatial_ref_sys LIMIT 5;
```

Jika muncul data, berarti PostGIS sudah aktif.

---

### 5. Setup Laravel Backend

```bash
# Masuk ke folder Laravel
cd Laravel

# Install dependencies
composer install

# Copy file environment
copy .env.example .env

# Generate application key
php artisan key:generate
```

#### Konfigurasi .env

Buka file `.env` dan sesuaikan:

```env
APP_NAME="Manajemen PKL"
APP_URL=http://localhost:8000

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=db_manajemen_pkl
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

#### Jalankan Migrasi & Seeder

```bash
# Jalankan migrasi database
php artisan migrate --seed
```

---

### 6. Setup Vue Frontend

Vue frontend terintegrasi dalam Laravel (menggunakan Vite):

```bash
# Masih di folder Laravel
cd Laravel

# Install dependencies NPM
npm install

# Build untuk development
npm run dev
```

---

### 7. Setup Flutter Mobile App

````bash
# Pindah ke folder Flutter
cd flutter_app

# Install dependencies
flutter pub get


#### Konfigurasi API URL
Default menggunakan url chrome bisa di skip jika pakai preview chrome
Buka file `lib/core/constants/api_constants.dart` dan sesuaikan:

```dart
class ApiConstants {
    // untuk chrome
    static const String baseUrl = 'http://127.0.0.1:8000/ap';

  // Untuk emulator Android
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Untuk HP fisik (ganti dengan IP komputer Anda)
  // static const String baseUrl = 'http://192.168.x.x:8000/api';
}
````

---

## ▶ Menjalankan Aplikasi

### Terminal 1: Laravel API Server

```bash
cd Laravel
php artisan serve --host=0.0.0.0 --port=8000
```

### Terminal 2: Vue Frontend (Vite)

```bash
cd Laravel
npm run dev
```

### Terminal 3: Flutter App

#gunakan chrome jika ingin cepat tapi beberapa fitur seperti file upload dan scan qr tidak berfungsi
#gunakan hp asli jika ingin semua fitur berfungsi

#### Jalankan di Chrome

```bash
cd flutter_app
flutter run
```

pilih chrome

abaikan saja jika ada peringatan error exist in your project

### Preview di HP Asli (Android)(opsional) bisa di skip jika menggunakan chrome

#### 📲 Untuk Android

##### Langkah 1: Aktifkan Developer Options di HP

1. Buka **Settings** → **About Phone**
2. Tap **Build Number** 7 kali hingga muncul "You are now a developer"
3. Kembali ke **Settings** → **Developer Options**
4. Aktifkan **USB Debugging**

##### Langkah 2: Hubungkan HP ke Komputer

1. Sambungkan HP menggunakan kabel USB
2. Pilih **File Transfer** atau **MTP** pada HP
3. jika tidak ada berarti USB tidak support
4. Konfirmasi dialog "Allow USB Debugging" di HP

##### Langkah 3: Verifikasi Koneksi

```bash
# Cek apakah HP terdeteksi
flutter devices
```

Output yang diharapkan:

```
SM A526B (mobile) • RFXXXXXXXX • android-arm64 • Android 13
```

##### Langkah 4: Jalankan Aplikasi

```bash
cd flutter_app
flutter run
```

Pilih device HP Anda jika ada multiple devices:

```bash
flutter run
```

##### Langkah 5: Konfigurasi Network untuk API

Karena HP dan komputer berbeda jaringan internal, ubah API URL(pastikan hp dan komputer di jaringan yang sama):

1. Cari IP Address komputer:

```bash
ipconfig
```

Cari **IPv4 Address** (contoh: `192.168.1.100`)

2. Update `api_constants.dart`:

```dart
static const String baseUrl = 'http://192.168.1.100:8000/api';
```

3. Pastikan Laravel berjalan dengan host 0.0.0.0:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

---

## 🔧 Troubleshooting

### Error: PostgreSQL Connection Refused

```bash
# Pastikan PostgreSQL service berjalan
net start postgresql-x64-14

# Cek status
pg_isready -h localhost -p 5432
```

### Error: Flutter Doctor Issues

```bash
# Jalankan dan ikuti saran yang diberikan
flutter doctor -v
```

### Error: Unable to Connect to API dari HP

1. Pastikan HP dan komputer di jaringan WiFi yang sama
2. Pastikan firewall mengizinkan port 8000
3. Cek IP komputer dengan `ipconfig`
4. Pastikan Laravel berjalan dengan `--host=0.0.0.0`

### Error: PostGIS Extension Not Found

```sql
-- Install ulang extension
DROP EXTENSION IF EXISTS postgis CASCADE;
CREATE EXTENSION postgis;
```

---

## 📞 Kontak & Support

Jika mengalami kendala, silakan hubungi saya 089683889798.

---

**Happy Coding! 🚀**
