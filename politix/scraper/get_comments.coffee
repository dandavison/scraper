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
            data[author] = []
            @scrape(author, url)

    scrape: (author, url) ->
        callback = (error, response, body) =>
            $ = cheerio.load(body)
            articles = $('article')
            for article in articles
                $article = $(article)
                title = $article.find('div.bd a h3').text()
                [day, comments] = $article.find('div.bd p span')
                day = $(day).siblings().text()
                comments = $(comments).text()
                data[author].push(
                    'day': day
                    'title': title
                    'comments': comments
                )
            @done++
            if @done = 4
                util.puts(JSON.stringify(data, null, 2))

        request(uri: url, callback)

data = {}
(new Politix).get_data()
