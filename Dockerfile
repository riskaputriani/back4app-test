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

FROM scrapinghub/scrapinghub-stack-scrapy:2.1
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install zip unzip

#============================================
# Google Chrome
#============================================
# can specify versions by CHROME_VERSION;
#  e.g. google-chrome-stable=53.0.2785.101-1
#       google-chrome-beta=53.0.2785.92-1
#       google-chrome-unstable=54.0.2840.14-1
#       latest (equivalent to google-chrome-stable)
#       google-chrome-beta  (pull latest beta)
#============================================
ARG CHROME_VERSION="google-chrome-stable"
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update -qqy \
  && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
  && rm /etc/apt/sources.list.d/google-chrome.list \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/*


#============================================
# Chrome Webdriver
#============================================
# can specify versions by CHROME_DRIVER_VERSION
# Latest released version will be used by default
#============================================
# ARG CHROME_DRIVER_VERSION
# RUN CHROME_STRING=$(google-chrome --version) \
#   && CHROME_VERSION_STRING=$(echo "${CHROME_STRING}" | grep -oP "\d+\.\d+\.\d+\.\d+") \
#   && CHROME_MAYOR_VERSION=$(echo "${CHROME_VERSION_STRING%%.*}") \
#   && wget --no-verbose -O /tmp/LATEST_RELEASE "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAYOR_VERSION}" \
#   && CD_VERSION=$(cat "/tmp/LATEST_RELEASE") \
#   && rm /tmp/LATEST_RELEASE \
#   && if [ -z "$CHROME_DRIVER_VERSION" ]; \
#      then CHROME_DRIVER_VERSION="${CD_VERSION}"; \
#      fi \
#   && CD_VERSION=$(echo $CHROME_DRIVER_VERSION) \
#   && echo "Using chromedriver version: "$CD_VERSION \
#   && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CD_VERSION/chromedriver_linux64.zip \
#   && rm -rf /opt/selenium/chromedriver \
#   && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
#   && rm /tmp/chromedriver_linux64.zip \
#   && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CD_VERSION \
#   && chmod 755 /opt/selenium/chromedriver-$CD_VERSION \
#   && sudo ln -fs /opt/selenium/chromedriver-$CD_VERSION /usr/bin/chromedriver

# ENV TERM xterm
# ENV SCRAPY_SETTINGS_MODULE cVehicles.settings
# RUN mkdir -p /app
# WORKDIR /app
# COPY ./requirements.txt /app/requirements.txt
# RUN pip install --no-cache-dir -r requirements.txt
# COPY . /app
# RUN python setup.py install


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