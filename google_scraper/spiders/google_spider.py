import scrapy

from google_scraper.items import GoogleTitleItem


class GoogleSpider(scrapy.Spider):
    name = "google"
    allowed_domains = ["google.com"]
    start_urls = ["https://www.google.com/"]

    def parse(self, response):
        title = response.css("title::text").get()
        item = GoogleTitleItem()
        item["title"] = title.strip() if title else None
        yield item
