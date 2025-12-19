import scrapy
from scrapy_playwright.page import PageMethod


class DemoSpider(scrapy.Spider):
    name = "demo"
    start_urls = ["http://quotes.toscrape.com/js"]

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
            yield {
                "quote": quote.css("span.text::text").get(),
                "author": quote.css("small.author::text").get(),
            }
        next_page_url = response.css("nav li.next a::attr(href)").get()
        if next_page_url:
            yield scrapy.Request(
                response.urljoin(next_page_url),
                meta={
                    "playwright": True,
                    "playwright_page_methods": [PageMethod("wait_for_selector", "div.quote")],
                },
            )
