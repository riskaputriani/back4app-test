import scrapy


class GoogleTitleItem(scrapy.Item):
    title = scrapy.Field()


class QuoteItem(scrapy.Item):
    text = scrapy.Field()
    author = scrapy.Field()
