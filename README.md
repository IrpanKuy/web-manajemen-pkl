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

# 🔧 PROSES 1: Setup Laragon dan PostgreSQL

Proses ini akan memandu Anda untuk menginstall dan mengkonfigurasi Laragon sebagai local development environment beserta PostgreSQL dan PostGIS.

## 📌 Prasyarat Proses 1

Sebelum memulai, pastikan komputer Anda sudah menginstall:

### 1. Laragon

- Download: [https://www.filehorse.com/download-laragon/74355/download/](https://www.filehorse.com/download-laragon/74355/download/)
- versi 6 untuk versi gratis

### 2. DBeaver

- Download: [https://dbeaver.io/download/](https://dbeaver.io/download/)
- Pilih versi **Community Edition** (gratis)
- DBeaver digunakan untuk manajemen database secara visual

---

## 🐘 Langkah 1.1: Install PostgreSQL di Laragon

Laragon secara default tidak menyertakan PostgreSQL, jadi kita perlu menambahkannya secara manual.

### Metode A: Menggunakan Quick Add (Rekomendasi)

1. **Buka Laragon**
2. Klik kanan pada jendela Laragon
3. Pilih **Tools** → **Quick Add** → **postgresql**
4. Tunggu proses download selesai
5. Restart Laragon

### Metode B: Install Manual

1. **Download PostgreSQL Binaries**

   - Kunjungi: [https://www.enterprisedb.com/download-postgresql-binaries](https://www.enterprisedb.com/download-postgresql-binaries)
   - Pilih versi **PostgreSQL 14.x** atau lebih baru untuk Windows x64
   - Download file zip (bukan installer .exe)

2. **Ekstrak ke Folder Laragon**

   - Ekstrak file zip yang sudah didownload
   - Pindahkan folder hasil ekstrak ke:
     ```
     C:\laragon\bin\postgresql
     ```
   - Struktur folder seharusnya seperti:
     ```
     C:\laragon\bin\postgresql\postgresql-xx.x\
     ├── bin\
     ├── lib\
     ├── share\
     └── ...
     ```

3. **Inisialisasi Database Cluster**

   Buka terminal dari Laragon (klik kanan → Terminal) dan jalankan:

   ```bash
   # Masuk ke folder bin PostgreSQL
   cd C:\laragon\bin\postgresql\postgresql-xx.x\bin

   # Inisialisasi database cluster
   initdb -D "C:\laragon\data\postgresql" -U postgres -W -E UTF8
   ```

   Anda akan diminta memasukkan password untuk user `postgres`. **Ingat password ini!**

4. **Konfigurasi Laragon untuk PostgreSQL**

   - Buka Laragon
   - Klik **Menu** → **Preferences** → **Services & Ports**
   - Pastikan PostgreSQL sudah terdeteksi
   - Ubah port jika diperlukan (default: 5432)

5. **Jalankan PostgreSQL**
   - Klik kanan pada Laragon → **PostgreSQL** → **Start PostgreSQL**
   - Atau klik **Start All**

---

## 🌍 Langkah 1.2: Setup Database dan PostGIS dengan DBeaver

Setelah PostgreSQL berjalan, gunakan DBeaver untuk membuat database dan menginstall ekstensi PostGIS.

### Step 1: Download PostGIS Bundle

Sebelum bisa mengaktifkan PostGIS di database, Anda harus menginstall PostGIS terlebih dahulu:

1. **Kunjungi halaman download PostGIS**

   - URL: [https://download.osgeo.org/postgis/windows/](https://download.osgeo.org/postgis/windows/)
   - Pilih folder sesuai versi PostgreSQL Anda (contoh: `pg14/` untuk PostgreSQL 14)

2. **Download file installer**

   - Download file seperti: `postgis-bundle-pg14x64-setup-3.x.x.exe`
   - Sesuaikan dengan versi PostgreSQL yang terinstall

3. **Jalankan installer PostGIS**
   - Double-click file yang sudah didownload
   - Saat installer bertanya lokasi PostgreSQL, arahkan ke:
     ```
     C:\laragon\bin\postgresql\postgresql-xx.x
     ```
   - Centang semua komponen yang ingin diinstall
   - Klik **Next** dan selesaikan proses instalasi

---

### Step 2: Buat Koneksi Database di DBeaver

1. **Buka DBeaver**

2. **Buat Koneksi Baru**

   - Klik **Database** → **New Database Connection**
   - Atau klik ikon **plug** dengan tanda **+** di toolbar

3. **Pilih PostgreSQL**

   - Pada dialog "Select your database", pilih **PostgreSQL**
   - Klik **Next**

4. **Isi Konfigurasi Koneksi**

   | Field    | Value       |
   | -------- | ----------- |
   | Host     | `localhost` |
   | Port     | `5432`      |
   | Database | `postgres`  |
   | Username | `postgres`  |
   | Password | (kosongkan) |

5. **Test Koneksi**

   - Klik tombol **Test Connection...**
   - Jika diminta download driver PostgreSQL, klik **Download**
   - Pastikan muncul pesan "Connected" ✓

6. **Simpan Koneksi**
   - Klik **Finish**
   - Koneksi akan muncul di panel sebelah kiri

---

### Step 3: Buat Database Baru

1. **Expand koneksi PostgreSQL** di panel kiri

2. **Buat Database**

   - Klik kanan pada **Databases** → **Create New Database**
   - Atau klik kanan pada koneksi → **Create** → **Database**

3. **Isi Nama Database**

   - Database name: `db_manajemen_pkl`
   - Owner: `postgres`
   - Encoding: `UTF8` (default)

4. **Klik OK** untuk membuat database

5. **Refresh** panel kiri untuk melihat database baru

---

### Step 4: Install Ekstensi PostGIS

1. **Koneksi ke Database yang Baru Dibuat**

   - Di panel kiri, expand **Databases**
   - Klik kanan pada `db_manajemen_pkl` → **SQL Editor** → **New SQL Script**

2. **Jalankan Query untuk Install PostGIS**

   Ketik query berikut di SQL Editor:

   ```sql
   -- Install ekstensi PostGIS
   CREATE EXTENSION IF NOT EXISTS postgis;
   CREATE EXTENSION IF NOT EXISTS postgis_topology;
   ```

3. **Execute Query**

   - Tekan **Ctrl + Enter** untuk menjalankan query
   - Atau klik tombol **Execute SQL Statement** (ikon play ▶️)

4. **Verifikasi Instalasi PostGIS**

   Jalankan query berikut untuk memastikan PostGIS terinstall:

   ```sql
   -- Cek versi PostGIS
   SELECT PostGIS_Version();
   ```

   Output yang diharapkan:

   ```
   3.x USE_GEOS=1 USE_PROJ=1 USE_STATS=1
   ```

---

## ✅ Checklist Proses 1

Sebelum lanjut ke Proses 2, pastikan:

- [ ] Laragon sudah terinstall dan berjalan
- [ ] PostgreSQL sudah terinstall di Laragon dan bisa diakses
- [ ] Database `db_manajemen_pkl` sudah dibuat
- [ ] Ekstensi PostGIS sudah aktif di database
- [ ] `SELECT PostGIS_Version();` menampilkan versi PostGIS

---

# 🌐 PROSES 2: Setup Projek Web (Laravel + Vue)

Proses ini akan memandu Anda untuk melakukan clone repository dan setup projek Laravel sebagai backend API serta Vue.js sebagai frontend.

## 📌 Prasyarat Proses 2

Sebelum memulai, pastikan komputer Anda sudah menginstall:

### 1. nodejs v18.x +

### 2. php v8.2 +

### Cek Instalasi

Buka terminal dan verifikasi:

```bash
node -v
php -v

```

---

## 📥 Langkah 2.1: Clone Repository

1. **Buka Terminal Laragon**

   - Klik kanan pada Laragon → **Terminal**

2. **Masuk ke Document Root**

   ```bash
   cd C:\laragon\www
   ```

3. **Clone Repository**

   ```bash
   git clone https://github.com/IrpanKuy/web-manajemen-pkl.git
   ```

4. **Masuk ke Folder Project**
   ```bash
   cd web-manajemen-pkl
   ```
5. **Open Code editor**
   ```bash
   code .
   ```

---

## 🔧 Langkah 2.2: Setup Laravel Backend

1. **Masuk ke Folder Laravel**

   ```bash
   cd Laravel
   ```

2. **Install PHP Dependencies**

   ```bash
   composer install
   ```

   Tunggu proses selesai (mungkin membutuhkan beberapa menit)

3. **Buat File Environment**

   ```bash
   copy .env.example .env
   ```

4. **Generate Application Key**
   ```bash
   php artisan key:generate
   ```

---

## ⚙ Langkah 2.3: Konfigurasi Environment (.env)

Buka file `.env` di folder Laravel dengan text editor (VS Code, Notepad++, dll) dan sesuaikan konfigurasi berikut:

```env
APP_NAME="Manajemen PKL"
APP_ENV=local
APP_KEY=base64:xxxxx  # sudah di-generate otomatis
APP_DEBUG=true
APP_URL=http://localhost:8000

# Konfigurasi Database PostgreSQL
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=db_manajemen_pkl
DB_USERNAME=postgres
DB_PASSWORD=your_password_here

# Ubah "your_password_here" dengan password PostgreSQL Anda
```

**Penting:** Pastikan `DB_PASSWORD` sesuai dengan password yang Anda set saat install PostgreSQL!

---

## 🗃 Langkah 2.4: Migrasi Database

Jalankan migrasi untuk membuat tabel-tabel yang diperlukan:

```bash
# Pastikan masih di folder Laravel
cd Laravel

# Jalankan migrasi dan seeder
php artisan migrate --seed
```

Jika berhasil, Anda akan melihat output seperti:

```
Migrating: 2024_xx_xx_xxxxxx_create_users_table
Migrated:  2024_xx_xx_xxxxxx_create_users_table
...
Database seeding completed successfully.
```

---

## 🎨 Langkah 2.5: Setup Vue Frontend

Vue.js terintegrasi dalam Laravel menggunakan Vite sebagai build tool.

1. **Install NPM Dependencies**

   ```bash
   # Masih di folder Laravel
   npm install
   ```

2. **Verifikasi Instalasi**
   ```bash
   npm list vue
   ```

---

## ▶ Langkah 2.6: Menjalankan Aplikasi Web

Anda membutuhkan **2 terminal** untuk menjalankan aplikasi:

### Terminal 1: Laravel API Server

```bash
cd C:\laragon\www\web-manajemen-pkl\Laravel

# Jalankan server Laravel
php artisan serve --host=0.0.0.0 --port=8000
```

Output yang diharapkan:

```
Starting Laravel development server: http://0.0.0.0:8000
```

### Terminal 2: Vue Frontend (Vite Dev Server)

Buka terminal baru dari Laragon dan jalankan:

```bash
cd C:\laragon\www\web-manajemen-pkl\Laravel

# Jalankan Vite development server
npm run dev
```

Output yang diharapkan:

```
VITE v5.x.x ready in xxx ms

➜  Local:   http://localhost:5173/
➜  Network: http://xxx.xxx.xxx.xxx:5173/
```

### Akses Aplikasi

- **Backend API**: [http://localhost:8000](http://localhost:8000)
- **Frontend Admin**: [http://localhost:5173](http://localhost:5173) atau sesuai URL dari Vite

---

## ✅ Checklist Proses 2

Sebelum lanjut ke Proses 3, pastikan:

- [ ] Repository sudah di-clone
- [ ] `composer install` berhasil tanpa error
- [ ] File `.env` sudah dikonfigurasi dengan benar
- [ ] `php artisan migrate --seed` berhasil
- [ ] `npm install` berhasil tanpa error
- [ ] Laravel server berjalan di port 8000
- [ ] Vite dev server berjalan

---

# 📱 PROSES 3: Setup Mobile App (Flutter)

Proses ini akan memandu Anda untuk setup Flutter development environment dan menjalankan aplikasi mobile PKL.

## 📌 Prasyarat Proses 3

Sebelum memulai, pastikan komputer Anda sudah menginstall:

### 1. Flutter SDK

- Download: [https://docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
- Ekstrak ke lokasi yang mudah diakses (contoh: `C:\flutter`)
- Tambahkan Flutter ke PATH environment variable:
  1. Buka **System Properties** → **Environment Variables**
  2. Di **User variables**, pilih **Path** → **Edit**
  3. Klik **New** dan tambahkan: `C:\flutter\bin`
  4. Klik **OK** untuk menyimpan

### 2. Google Chrome (untuk preview web)

- Download: [https://www.google.com/chrome/](https://www.google.com/chrome/)
- Install dengan opsi default

### 3. Android Studio (Opsional, untuk preview di HP)

- Download: [https://developer.android.com/studio](https://developer.android.com/studio)
- Install dengan komponen default
- Jalankan Android Studio dan install Android SDK

### Verifikasi Instalasi Flutter

Buka terminal baru dan jalankan:

```bash
flutter doctor
```

Untuk preview menggunakan **Chrome**, pastikan output menunjukkan:

```
[✓] Flutter (Channel stable, 3.x.x)
[✓] Chrome - develop for the web
```

Untuk preview menggunakan **HP Android**, pastikan juga:

```
[✓] Android toolchain - develop for Android devices
[✓] Connected device (1 available)
```

Jika ada tanda [!] atau [✗], ikuti saran yang diberikan untuk memperbaiki.

---

## 📦 Langkah 3.1: Install Dependencies Flutter

1. **Buka Terminal Baru**

2. **Masuk ke Folder Flutter App**

   ```bash
   cd C:\laragon\www\web-manajemen-pkl\flutter_app
   ```

3. **Install Dependencies**

   ```bash
   flutter pub get
   ```

4. **Generate Kode yang Diperlukan** (jika menggunakan build_runner)
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

---

## 🔧 Langkah 3.2: Konfigurasi API URL

Buka file `lib/core/constants/api_constants.dart` dan sesuaikan URL sesuai cara preview yang Anda gunakan:

```dart
class ApiConstants {
  // ============================================
  // PILIH SALAH SATU SESUAI CARA PREVIEW ANDA
  // ============================================

  // UNTUK CHROME (default)
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // UNTUK EMULATOR ANDROID
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // UNTUK HP FISIK (ganti dengan IP komputer Anda)
  // static const String baseUrl = 'http://192.168.x.x:8000/api';
}
```

---

## 🌐 Langkah 3.3: Preview di Chrome (Rekomendasi untuk Development)

Chrome adalah cara tercepat untuk preview aplikasi Flutter selama development.

### Menjalankan Aplikasi

```bash
# Pastikan sudah di folder flutter_app
cd C:\laragon\www\web-manajemen-pkl\flutter_app

# Jalankan aplikasi
flutter run
```

Saat muncul pilihan device, pilih **Chrome**:

```
Connected devices:
1. Windows (desktop)
2. Chrome (web)
3. Edge (web)

Choose a device:
```

Ketik `2` dan tekan Enter untuk memilih Chrome.

### Catatan Penting untuk Chrome

⚠️ **Beberapa fitur tidak berfungsi di Chrome:**

- Upload file (seperti upload foto)
- Scan QR Code
- Akses kamera/galeri

Untuk testing fitur-fitur tersebut, gunakan HP asli (lihat Langkah 3.4)

### Hot Reload

Saat aplikasi berjalan di Chrome:

- Tekan `r` di terminal untuk **hot reload** (reload cepat)
- Tekan `R` untuk **hot restart** (restart penuh)
- Tekan `q` untuk keluar

---

## 📲 Langkah 3.4: Preview di HP Asli (Opsional)

Jika Anda ingin testing semua fitur termasuk kamera dan upload file, gunakan HP Android asli.

### Step 1: Aktifkan Developer Options di HP

1. Buka **Settings** → **About Phone**
2. Cari **Build Number** dan tap **7 kali berturut-turut**
3. Akan muncul notifikasi "You are now a developer!"
4. Kembali ke **Settings** → **Developer Options** (atau System → Developer Options)
5. Aktifkan opsi berikut:
   - **USB Debugging**: ON
   - **Install via USB**: ON (jika ada)

### Step 2: Hubungkan HP ke Komputer

1. Sambungkan HP menggunakan **kabel USB data** (bukan kabel charging biasa)
2. Di HP, pilih mode **File Transfer (MTP)** atau **Transfer files**
3. Jika muncul dialog "Allow USB Debugging?", centang "Always allow" dan tap **OK**

💡 **Tips:** Jika tidak muncul dialog di HP, coba:

- Cabut dan pasang ulang kabel USB
- Gunakan kabel USB yang berbeda
- Coba port USB yang berbeda di komputer

### Step 3: Verifikasi Koneksi

```bash
flutter devices
```

Output yang diharapkan:

```
2 connected devices:

SM A526B (mobile)  • RFXXXXXXXX • android-arm64  • Android 13
Chrome (web)       • chrome     • web-javascript • Google Chrome
```

Nama device akan berbeda sesuai tipe HP Anda.

### Step 4: Konfigurasi Network untuk HP

Karena HP dan komputer adalah device berbeda, Anda perlu menggunakan IP Address komputer.

1. **Cari IP Address Komputer**

   ```bash
   ipconfig
   ```

   Cari **IPv4 Address** di bagian WiFi atau Ethernet:

   ```
   Wireless LAN adapter Wi-Fi:
      IPv4 Address. . . . . . . . : 192.168.1.100
   ```

2. **Update API URL**

   Buka `lib/core/constants/api_constants.dart`:

   ```dart
   class ApiConstants {
     // Ganti dengan IP komputer Anda
     static const String baseUrl = 'http://192.168.1.100:8000/api';
   }
   ```

3. **Pastikan HP dan Komputer di WiFi yang Sama**
   - HP dan komputer harus terhubung ke jaringan WiFi yang sama
   - Atau bisa menggunakan mobile hotspot

### Step 5: Jalankan di HP

```bash
cd C:\laragon\www\web-manajemen-pkl\flutter_app

flutter run
```

Pilih device HP Anda dari daftar, atau langsung specify device:

```bash
flutter run -d RFXXXXXXXX
```

(Ganti `RFXXXXXXXX` dengan device ID dari `flutter devices`)

### Step 6: Pastikan Laravel Accessible

Laravel harus berjalan dengan host `0.0.0.0` agar bisa diakses dari HP:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

---

## ✅ Checklist Proses 3

Pastikan sebelum testing:

- [ ] `flutter doctor` tidak ada error critical
- [ ] `flutter pub get` berhasil
- [ ] API URL sudah dikonfigurasi sesuai cara preview
- [ ] Laravel server berjalan dengan `--host=0.0.0.0`

Untuk Chrome:

- [ ] Chrome terinstall
- [ ] Aplikasi berjalan di Chrome

Untuk HP (Opsional):

- [ ] Developer Options aktif
- [ ] USB Debugging aktif
- [ ] HP terdeteksi di `flutter devices`
- [ ] HP dan komputer di jaringan yang sama

---

# 🔧 Troubleshooting

## PostgreSQL Issues

### Error: Connection Refused

```bash
# Pastikan PostgreSQL service berjalan
net start postgresql-x64-14

# Cek status
pg_isready -h localhost -p 5432
```

### Error: PostGIS Extension Not Found

```sql
-- Cek ekstensi yang tersedia
SELECT * FROM pg_available_extensions WHERE name LIKE 'postgis%';

-- Jika ada, install ulang
DROP EXTENSION IF EXISTS postgis CASCADE;
CREATE EXTENSION postgis;
```

## Laravel Issues

### Error: Could not find driver

Pastikan ekstensi `pdo_pgsql` aktif di PHP:

1. Buka `php.ini` di folder Laragon
2. Cari dan uncomment: `extension=pdo_pgsql`
3. Restart Laragon

## Flutter Issues

### Error: Flutter Doctor Issues

```bash
# Jalankan dan ikuti saran yang diberikan
flutter doctor -v
```

### Error: Unable to Connect to API dari HP

1. Pastikan HP dan komputer di jaringan WiFi yang sama
2. Pastikan firewall Windows mengizinkan port 8000:
   - Control Panel → Windows Defender Firewall → Allow an app
   - Atau nonaktifkan sementara untuk testing
3. Cek IP komputer sudah benar di `api_constants.dart`
4. Pastikan Laravel berjalan dengan `--host=0.0.0.0`

### Error: Build Failed with Existing File Conflict

```bash
# Hapus cache dan rebuild
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

---

# 📞 Kontak & Support

Jika mengalami kendala, silakan hubungi saya di **089683889798**.

---

**Happy Coding! 🚀**
