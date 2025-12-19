import scrapy
from scrapy_playwright.page import PageMethod

from google_scraper.items import QuoteItem


class JsQuotesSpider(scrapy.Spider):
    name = "js_quotes"
    allowed_domains = ["quotes.toscrape.com"]
    start_urls = ["https://quotes.toscrape.com/js/"]

    def start_requests(self):
        for url in self.start_urls:
            yield scrapy.Request(
                url,
                meta={
                    "playwright": True,
                    "playwright_page_methods": [PageMethod("wait_for_selector", "div.quote")],
                },
            )

    def parse(self, response):
        for quote in response.css("div.quote"):
            item = QuoteItem()
            item["text"] = quote.css("span.text::text").get()
            item["author"] = quote.css("small.author::text").get()
            yield item
