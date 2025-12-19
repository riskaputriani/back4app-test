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

ARG BASE_IMAGE=scrapinghub/scrapinghub-stack-scrapy:2.11
FROM ${BASE_IMAGE}

ENV HOME=/scrapinghub \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PLAYWRIGHT_BROWSERS_PATH=/scrapinghub/.cache/ms-playwright

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN mkdir -p "$PLAYWRIGHT_BROWSERS_PATH" \
 && pip install -r /app/requirements.txt \
 && python -m playwright install chromium \
 && chmod -R 755 "$PLAYWRIGHT_BROWSERS_PATH"

# pastikan semua source masuk ke /app
COPY . /app

# debug: pastikan spider kebaca (boleh hapus setelah beres)
RUN scrapy list
