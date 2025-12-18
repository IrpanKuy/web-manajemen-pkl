# web-manajemen-pkl

#Laravel • Vue • Flutter • PostgreSQL • PostGIS

Aplikasi manajemen PKL berbasis Web & Mobile dengan dukungan data spasial (GIS).
Backend API → Laravel
Web Dashboard → Vue.js
Mobile App → Flutter
Database → PostgreSQL + PostGIS
Digunakan untuk mengelola siswa PKL, instansi, absensi, jurnal, dan lokasi instansi berbasis peta.

#Fitur Utama

Authentication (API Token)
Manajemen Siswa & Instansi PKL
Absensi & Jurnal Harian
Monitoring PKL via Dashboard
Lokasi Instansi PKL (GIS / Map)
Perhitungan jarak & koordinat (PostGIS)

#Tech Stack
Backend

Laravel 12
PHP 8.3
PostgreSQL
PostGIS (Spatial Database)
Laravel Sanctum
REST API

#Frontend Web

Vue 3
Vite
inertia
Tailwind CSS

#Mobile App

Flutter

Dart

Dio (HTTP Client)

Spatial (PostGIS)

Digunakan untuk:

Menyimpan koordinat instansi PKL

Query berbasis lokasi

Pengukuran jarak (ST_Distance)

Integrasi peta 



#Backend Setup (Laravel + PostGIS)

#1. Install Dependencies
cd Laravel
composer install

#2. Setup Environment
cp .env.example .env
php artisan key:generate

#3. Database Configuration (.env)
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=manajemen_pkl
DB_USERNAME=postgres
DB_PASSWORD=your_password


#Pastikan PostGIS extension aktif:
jika belum silakan baca dokumentasi https://postgis.net/documentation/getting_started

#4. Migration
php artisan migrate --seed

#5. Run Server
php artisan serve

#Frontend Web Setup (Vue)
cd frontend
npm install
npm run dev

#Mobile App Setup (Flutter)
cd flutter_app
flutter pub get
flutter run(jika pakai vscode ke file main.dart lalu run)


#Pastikan:

Flutter SDK siap
Android SDK terinstall

🧪 Environment Requirements

Flutter ≥ 3.38
PHP ≥ 8.3
Node.js ≥ 18
PostgreSQL ≥ 14
PostGIS ≥ 3

