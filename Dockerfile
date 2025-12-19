FROM scrapinghub/scrapinghub-stack-scrapy:2.13-20250721

ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PLAYWRIGHT_BROWSERS_PATH=/scrapinghub/.cache/ms-playwright \
    SCRAPY_SETTINGS_MODULE=google_scraper.settings

WORKDIR /app

COPY requirements.txt /app/requirements.txt
RUN pip install -r /app/requirements.txt \
 && python -m playwright install --with-deps chromium

COPY . /app
RUN pip install -e .
