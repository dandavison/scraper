request = require 'request'
cheerio = require 'cheerio'
util = require 'util'


class Politix
    constructor: ->
        @name = 'Politix'
        @domain = 'http://politix.topix.com'
        @done = 0

    get_data: ->
        for author in ['politixmayday', 'politixdain', 'politixmary', 'politixdavid']
            url = "#{ @domain }/profile/#{ author }"
            @scrape(author, url)

    scrape: (author, url) ->
        callback = (error, response, body) =>
            $ = cheerio.load(body)
            articles = $('article')
            for article in articles
                $article = $(article)
                title = $article.find('div.bd a h3').text()
                [timestamp, comments] = (span.next.data for span in $article.find('div.bd p.margint5 span'))
                data.push(
                    'author': author
                    'title': title
                    'timestamp': timestamp
                    'comments': comments
                )
            @done++
            if @done == 4
                util.puts(JSON.stringify(data, null, 2))
                process.exit(0)

        request(uri: url, callback)

data = []
(new Politix).get_data()
