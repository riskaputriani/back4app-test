# Gunakan Python version yang sesuai (misal 3.11)
FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1

# 1. Install dependency sistem Linux yang wajib untuk Playwright & Browser
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# 2. Copy requirements.txt dan install library Python
COPY requirements.txt /app/requirements.txt
WORKDIR /app
RUN pip install --no-cache-dir -r requirements.txt

# 3. Install Playwright & Browser (INI BAGIAN TERPENTING)
# Perintah ini akan mendownload binary Chromium ke dalam image
RUN pip install scrapy-playwright
RUN playwright install chromium
RUN playwright install-deps chromium

# 4. Copy sisa kode project
COPY . /app

# 5. Entrypoint (Zyte akan meng-override ini saat job jalan, tapi ini standard)
ENTRYPOINT ["scrapy"]

# ARG BASE_IMAGE=scrapinghub/scrapinghub-stack-scrapy:2.11
# FROM ${BASE_IMAGE}

# ENV HOME=/scrapinghub \
#     PYTHONUNBUFFERED=1 \
#     PIP_DISABLE_PIP_VERSION_CHECK=1 \
#     PIP_NO_CACHE_DIR=1 \
#     PLAYWRIGHT_BROWSERS_PATH=/scrapinghub/.cache/ms-playwright

# WORKDIR /app

# COPY requirements.txt /app/requirements.txt

# RUN mkdir -p "$PLAYWRIGHT_BROWSERS_PATH" \
#     && pip install -r /app/requirements.txt \
#     && python -m playwright install --with-deps chromium \
#     && chmod -R 755 "$PLAYWRIGHT_BROWSERS_PATH"

# COPY . /app
