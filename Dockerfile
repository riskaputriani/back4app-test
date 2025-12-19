# 1. Gunakan Base Image RESMI Zyte (Agar tidak error 127 / list-spiders missing)
FROM scrapinghub/scrapinghub-stack-scrapy:2.11

# 2. Switch ke ROOT user
# Secara default image Zyte pakai user 'nobody', kita perlu root untuk install browser
USER root

# 3. Setup Environment Variables
ENV TERM=xterm \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    # Set folder khusus browser agar tidak permission error
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

# 4. Install Dependency System (apt-get)
# Kita butuh ini agar command 'playwright install' nanti berhasil
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    libgbm-dev \
    && rm -rf /var/lib/apt/lists/*

# 5. Copy requirements & Install Python Libs
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

# 6. Install Playwright Browsers
# --with-deps akan otomatis download library Linux pendukung browser
RUN pip install scrapy-playwright \
    && mkdir -p $PLAYWRIGHT_BROWSERS_PATH \
    && playwright install chromium --with-deps \
    && chmod -R 777 $PLAYWRIGHT_BROWSERS_PATH

# 7. Copy Project Code
COPY . /app
RUN python setup.py install || true

# PENTING: Jangan ubah ENTRYPOINT. 
# Biarkan Zyte menggunakan entrypoint bawaan image scrapinghub-stack.