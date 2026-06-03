# Panduan Deployment PO Scheduler

Dokumen ini berisi panduan langkah demi langkah untuk melakukan *deployment* aplikasi PO Scheduler (Frontend React & Backend Laravel) ke *server production* (misal: VPS Ubuntu dengan Nginx).

## 1. Persyaratan Server (Server Requirements)
Pastikan server Anda sudah terinstall komponen berikut:
- **OS**: Ubuntu 22.04 / 24.04 (Rekomendasi)
- **Web Server**: Nginx
- **PHP**: Versi 8.2 atau lebih baru beserta ekstensi (`bcmath`, `ctype`, `fileinfo`, `json`, `mbstring`, `openssl`, `pdo`, `tokenizer`, `xml`, `curl`, `zip`, `gd/imagick` untuk render PDF).
- **Database**: MySQL 8.0+ atau PostgreSQL 14+
- **Node.js**: Versi 18 LTS atau 20 LTS (termasuk `npm`)
- **Composer**: Versi 2.x

---

## 2. Deployment Backend (Laravel)

1. **Clone/Copy Repository**
   Pindahkan *source code* aplikasi ke server Anda. Asumsikan kita menaruhnya di direktori `/var/www/po-app`.
   ```bash
   cd /var/www/po-app/backend
   ```

2. **Install Dependensi PHP**
   Install *package* tanpa *dev dependencies*:
   ```bash
   composer install --optimize-autoloader --no-dev
   ```

3. **Konfigurasi Environment (.env)**
   Salin file `.env.example` menjadi `.env` dan sesuaikan konfigurasinya:
   ```bash
   cp .env.example .env
   nano .env
   ```
   Pastikan variabel krusial berikut diubah:
   ```env
   APP_ENV=production
   APP_DEBUG=false
   APP_URL=https://domain-anda.com

   # Konfigurasi SPA Auth Sanctum
   FRONTEND_URL=https://domain-anda.com
   SANCTUM_STATEFUL_DOMAINS=domain-anda.com

   # Konfigurasi Database
   DB_CONNECTION=mysql # atau pgsql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=nama_db
   DB_USERNAME=user_db
   DB_PASSWORD=password_db
   ```

4. **Generate App Key & Storage Link**
   Jalankan perintah berikut untuk mengamankan enkripsi session dan mengekspos direktori storage ke publik:
   ```bash
   php artisan key:generate
   php artisan storage:link
   ```

5. **Migrasi Database**
   Jalankan migrasi tabel (pastikan database sudah dibuat sebelumnya):
   ```bash
   php artisan migrate --force
   ```

6. **Optimasi Aplikasi (Cache)**
   Untuk mempercepat performa di *production*, *cache* semua *config*, *route*, dan *view*:
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

7. **Konfigurasi Hak Akses (Permissions)**
   Berikan hak akses agar web server Nginx dapat menulis (*write*) ke folder *storage*:
   ```bash
   sudo chown -R www-data:www-data /var/www/po-app/backend
   sudo chmod -R 775 /var/www/po-app/backend/storage
   sudo chmod -R 775 /var/www/po-app/backend/bootstrap/cache
   ```

---

## 3. Deployment Frontend (React + Vite)

Frontend perlu di-*build* menjadi file statis (HTML/CSS/JS) agar bisa di-*serve* oleh Nginx secara langsung dan cepat.

1. **Masuk ke Direktori Frontend**
   ```bash
   cd /var/www/po-app/frontend
   ```

2. **Install Dependensi Node**
   ```bash
   npm install
   ```

3. **Konfigurasi Environment Frontend**
   Karena *request* API akan diproses (proxy) oleh Nginx melalui domain utama yang sama, Anda tidak perlu mengubah URL ke sub-domain. Pemanggilan *fetch* ke `/api` sudah cukup.

4. **Build Frontend untuk Production**
   Jalankan perintah *build*:
   ```bash
   npm run build
   ```
   Setelah selesai, file hasil *build* statis akan berada di dalam folder `/var/www/po-app/frontend/dist`. Folder inilah yang akan kita ekspos ke publik melalui Nginx.

---

## 4. Konfigurasi Web Server (Nginx)

Pendekatan terbaik untuk aplikasi SPA (Single Page Application) dengan Laravel Sanctum adalah menyatukan keduanya dalam satu domain. Nginx akan bertugas:
- Menyajikan (*serve*) file statis React untuk URL secara default.
- Meneruskan (*proxy*) rute yang berawalan `/api` atau `/sanctum` langsung ke aplikasi Laravel.

1. **Buat file konfigurasi Nginx baru:**
   ```bash
   sudo nano /etc/nginx/sites-available/po-app
   ```

2. **Masukkan konfigurasi berikut:**
   *(Catatan: Sesuaikan `server_name`, jalur path file, dan versi *PHP-FPM* yang Anda gunakan)*

   ```nginx
   server {
       listen 80;
       server_name domain-anda.com;
       
       # Document Root diarahkan langsung ke hasil build React
       root /var/www/po-app/frontend/dist;
       index index.html;

       # Log
       error_log  /var/log/nginx/po-app-error.log;
       access_log /var/log/nginx/po-app-access.log;

       # Handle rute React (SPA Fallback - Lempar kembali ke index.html)
       location / {
           try_files $uri $uri/ /index.html;
       }

       # Proxy request backend ke Laravel Public Folder
       location ~ ^/(api|sanctum) {
           alias /var/www/po-app/backend/public;
           try_files $uri $uri/ @backend;

           location ~ \.php$ {
               include snippets/fastcgi-php.conf;
               # Sesuaikan path soket ini dengan versi PHP yang Anda gunakan (contoh: php8.2-fpm.sock)
               fastcgi_pass unix:/var/run/php/php8.2-fpm.sock; 
               fastcgi_param SCRIPT_FILENAME $request_filename;
               include fastcgi_params;
           }
       }

       # Internal rewrite agar Laravel dapat membaca struktur endpoint /api
       location @backend {
           rewrite /api/(.*)$ /api/index.php?/$1 last;
           rewrite /sanctum/(.*)$ /sanctum/index.php?/$1 last;
       }
   }
   ```

3. **Aktifkan Konfigurasi & Restart Nginx**
   ```bash
   sudo ln -s /etc/nginx/sites-available/po-app /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

---

## 5. Konfigurasi SSL (HTTPS)
Aplikasi modern (terutama yang menggunakan Autentikasi / _Cookie stateful_) sangat wajib menggunakan SSL/HTTPS di lingkup *production*. Anda bisa memasangnya secara gratis menggunakan **Certbot**:

```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx

# Jalankan instalasi sertifikat
sudo certbot --nginx -d domain-anda.com
```

Certbot akan otomatis memodifikasi konfigurasi Nginx Anda untuk menambahkan lapisan keamanan HTTPS.

## Selesai! 🎉
Aplikasi **PO Scheduler** sekarang dapat diakses dengan stabil dan aman melalui `https://domain-anda.com`.
