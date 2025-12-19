# 1. Gunakan image Python bersih, jangan image Zyte Stack
FROM python:3.11-slim

# 2. Set Environment Variables
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    # Penting: Beritahu Python untuk membaca modul dari folder /app
    PYTHONPATH="/app" \
    # Folder khusus untuk browser Playwright
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 3. Install dependency sistem (Linux) yang dibutuhkan Playwright
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# 4. Siapkan folder kerja
WORKDIR /app

# 5. Copy requirements dan install
COPY requirements.txt /app/requirements.txt
RUN pip install -r requirements.txt

# 6. Install Playwright + Browsernya
# Kita install browser ke folder khusus agar rapi
RUN mkdir -p $PLAYWRIGHT_BROWSERS_PATH \
    && pip install scrapy-playwright \
    && playwright install chromium --with-deps \
    && chmod -R 777 $PLAYWRIGHT_BROWSERS_PATH

# 7. Copy seluruh kode project (termasuk scrapy.cfg)
COPY . /app

# 8. VERIFIKASI (PENTING)
# Perintah ini untuk mengecek saat build apakah spider terdeteksi
# Jika ini error, build akan berhenti
RUN scrapy list