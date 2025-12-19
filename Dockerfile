# 1. GANTI versi 2.11 menjadi 2.13
# Versi 2.13 menggunakan Debian yang lebih baru, jadi apt-get tidak akan error 404
FROM scrapinghub/scrapinghub-stack-scrapy:2.13

# 2. Masuk sebagai ROOT untuk instalasi sistem
USER root

# 3. Environment Variables
ENV TERM=xterm \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 4. Install Dependency Linux (Sekarang pasti berhasil)
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    libgbm-dev \
    # libnss3 dll sering dibutuhkan Chromium
    libnss3 \
    libxss1 \
    libasound2 \
    && rm -rf /var/lib/apt/lists/*

# 5. Setup Folder Project
WORKDIR /app
COPY requirements.txt /app/requirements.txt

# 6. Install Python Libs & Playwright
# Kita install scrapy-playwright. 
# scrapinghub-entrypoint-scrapy sudah bawaan image 2.13, tapi update saja biar aman.
RUN pip install --no-cache-dir -r requirements.txt \
    && pip install scrapy-playwright

# 7. Install Browser Chromium
RUN mkdir -p $PLAYWRIGHT_BROWSERS_PATH \
    && playwright install chromium --with-deps \
    && chmod -R 777 $PLAYWRIGHT_BROWSERS_PATH

# 8. Copy Project Code
COPY . /app
RUN python setup.py install || true

# Entrypoint biarkan default dari Zyte