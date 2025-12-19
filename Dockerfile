# Pilih base image Scrapy Cloud yang cocok
# (tag stack-nya sesuaikan dengan project kamu)
FROM zyte/scrapy:2.13-20250721

# Install python deps
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Install Playwright browser binaries (chromium saja biar kecil)
RUN python -m playwright install chromium

# (opsional) kalau butuh sistem dependencies untuk browser,
# biasanya perlu "install-deps", tapi ini tergantung base image:
# RUN python -m playwright install-deps && python -m playwright install chromium
