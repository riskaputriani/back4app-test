# ---------------------------------------------------------------
# 1. GUNAKAN IMAGE TERBARU (Wajib ganti ke 2.13)
# ---------------------------------------------------------------
# Versi 2.1 menyebabkan error apt-get 404. Versi 2.13 menggunakan Debian baru.
FROM scrapinghub/scrapinghub-stack-scrapy:2.13

# ---------------------------------------------------------------
# 2. PINDAH KE USER ROOT
# ---------------------------------------------------------------
# Image Zyte default-nya user 'nobody', kita butuh root untuk install
USER root

# ---------------------------------------------------------------
# 3. SETTING ENVIRONMENT
# ---------------------------------------------------------------
ENV TERM=xterm \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    # Folder khusus untuk browser Playwright agar rapi
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright \
    # Ganti dengan nama module settings project Anda jika perlu
    SCRAPY_SETTINGS_MODULE=cVehicles.settings

# ---------------------------------------------------------------
# 4. INSTALL DEPENDENCY LINUX (Pengganti Chrome Manual)
# ---------------------------------------------------------------
# Playwright butuh library sistem ini.
# Karena kita pakai image 2.13, apt-get update PASTI BERHASIL.
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    libgbm-dev \
    libnss3 \
    libxss1 \
    libasound2 \
    fonts-liberation \
    libappindicator3-1 \
    libatk-bridge2.0-0 \
    libgtk-3-0 \
    zip \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------
# 5. SETUP PROJECT & INSTALL PYTHON
# ---------------------------------------------------------------
WORKDIR /app
COPY requirements.txt /app/requirements.txt

# Install library python
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install scrapy-playwright

# ---------------------------------------------------------------
# 6. INSTALL BROWSER PLAYWRIGHT (Pengganti Chromedriver)
# ---------------------------------------------------------------
# Perintah ini otomatis download Chromium versi yang cocok
RUN mkdir -p $PLAYWRIGHT_BROWSERS_PATH \
    && playwright install chromium --with-deps \
    && chmod -R 777 $PLAYWRIGHT_BROWSERS_PATH

# ---------------------------------------------------------------
# 7. COPY KODE & FINISHING
# ---------------------------------------------------------------
COPY . /app
RUN python setup.py install || true

# Verifikasi agar deploy di Zyte terdeteksi sukses
RUN scrapy list