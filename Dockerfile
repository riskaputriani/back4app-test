# Gunakan Python 3.11 versi ringan (Linux Debian)
FROM python:3.11-slim

# --- BAGIAN 1: KONFIGURASI ENVIRONMENT ---
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    # Penting: Agar Python bisa import codingan Anda dari folder /app
    PYTHONPATH="/app" \
    # Lokasi khusus untuk menyimpan browser Playwright
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# --- BAGIAN 2: INSTALL DEPENDENCY LINUX ---
# Playwright butuh library-library ini agar Chrome bisa jalan di server
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# --- BAGIAN 3: SETUP PROJECT ---
WORKDIR /app

# Copy requirements dulu agar caching Docker efisien
COPY requirements.txt /app/requirements.txt

# --- BAGIAN 4: INSTALL PYTHON LIBS & BROWSER ---
# Install library Python TERMASUK 'scrapinghub-entrypoint-scrapy'
RUN pip install -r requirements.txt

# Install Browser Chromium dan dependency-nya
RUN mkdir -p $PLAYWRIGHT_BROWSERS_PATH \
    && playwright install chromium --with-deps \
    && chmod -R 777 $PLAYWRIGHT_BROWSERS_PATH

# --- BAGIAN 5: COPY KODE & FINALISASI ---
COPY . /app

# Test run untuk memastikan Spider terdeteksi saat build
# Kalau perintah ini error, deploy pasti gagal. Kalau sukses, deploy aman.
RUN scrapy list