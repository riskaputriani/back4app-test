ARG BASE_IMAGE=scrapinghub/scrapinghub-stack-scrapy:2.11
FROM ${BASE_IMAGE}

ENV PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    PLAYWRIGHT_BROWSERS_PATH=/ms-playwright

WORKDIR /app

COPY requirements.txt /app/requirements.txt

RUN pip install -r /app/requirements.txt \
    && python -m playwright install --with-deps chromium \
    && chmod -R 755 /ms-playwright

COPY . /app
