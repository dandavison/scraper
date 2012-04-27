request = require 'request'
jsdom = require 'jsdom'
util = require 'util'


class Scraper
    scrape: =>
        request uri: @domain + @url, (error, response, body) =>
            data[@name] ?= {}
            if error
                msg = if response then "status code #{response.statusCode}" else "no response"
                data[@name]['Error'] = @make_fake_entry "#{@domain + @url} returned #{msg}"
                callback()
                return
            jsdom.env
                html: body
                scripts: ["http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"],
                (error, window) =>
                    if error
                        data[@name]['Error'] = @make_fake_entry 'Error loading jquery'
                        callback()
                    else
                        global.$ = window.jQuery
                        try
                            @_scrape()
                        catch err
                            data[@name]['Error'] = @make_fake_entry err
                        finally
                            callback()

    get_anchor_text: (a) -> $(a).text()

    _scrape: =>
        url_getter = (a) =>
            if a.href[0] is '/' then @domain + a.href else a.href
        for category, $anchors of @get_anchors()
            data[@name][category] = for a in $anchors.toArray()
                {text: @get_anchor_text(a).trim(),
                url: url_getter(a)}

    make_fake_entry: (content) ->
        [text: content, url: '']


class AtlanticWire extends Scraper
    constructor: ->
        @name = 'Atlantic Wire'
        @domain = 'http://www.theatlanticwire.com'
        @url = '/'

    get_anchors: -> 'Most clicked': $('.most-clicked li a')


class TheAtlantic extends Scraper
    constructor: ->
        @name = 'The Atlantic'
        @domain = 'http://www.theatlantic.com'
        @url = '/politics/'

    get_anchors: -> 'Most popular': $('#mostPopular a')


class BBCUSandCanada extends Scraper
    constructor: ->
        @name = 'The BBC US & Canada (daily most popular)'
        @domain = 'http://www.bbc.co.uk'
        @url = '/news/world/us_and_canada/'

    get_anchors: -> 'Most popular': $('#most-popular-category div li a')[0..1]


class BBCUSandCanadaArticle extends Scraper
    constructor: ->
        @name = 'The BBC US & Canada'
        @domain = 'http://www.bbc.co.uk'
        @url = '/news/world-us-canada-16549624'

    get_anchors: ->
        anchors = {}
        for category in ['Shared', 'Read']
            $aa = $("#most-popular .tab a")
            $aa = $(a for a in $aa.toArray() when $(a).text() is category)
            anchors[category] = $aa.parent().next().find('li a')
        anchors


class TheBlaze extends Scraper
    constructor: ->
        @name = 'The Blaze'
        @domain = 'http://www.theblaze.com'
        @url = '/'

    get_anchors: -> 'Popular Stories': $('h3:contains(Popular Stories)').parent().find('li a.title')


class BusinessInsider extends Scraper
    constructor: ->
        @name = 'Business Insider'
        @domain = 'http://www.businessinsider.com'
        @url = '/politics'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['1', 'Read'], ['2', 'Commented']]
            anchors[name] = $('h4:contains("Most Read")').parent().find("#sh-body#{category} ul li p a")
        anchors


class BuzzFeed extends Scraper
    constructor: ->
        @name = 'Buzzfeed'
        @domain = 'http://www.buzzfeed.com'
        @url = '/politics'

    get_anchors: ->
        validate = ->
            (@.href.indexOf('/usr/homebrew/lib/node/jsdom') == -1) and \
            (@.href.indexOf('twitter') == -1)
        'Most viral in Politics': $('.bf-widget div a:has(h2)').filter(validate)


class CBS extends Scraper
    constructor: ->
        @name = 'CBS'
        @domain = 'http://www.cbsnews.com'
        @url = '/2240-100_162-0.html'

    get_anchors: ->
        'Most Popular Stories and Blog Posts': $('#mostPopularFullPage ol li a')


class CNN extends Scraper
    constructor: ->
        @name = 'CNN'
        @domain = 'http://www.cnn.com'
        @url = '/'

    get_anchors: ->
        "Popular on Facebook (doesn't work due to facebook auth)": $('#pmFacebook li a')


class CrooksAndLiars extends Scraper
    constructor: ->
        @name = 'Crooks and Liars'
        @domain = 'http://crooksandliars.com'
        @url = '/'

    get_anchors: ->
        anchors = {}
        for category in ['day', 'week']
            anchors["Top Media: #{category}"] = $("#topmedia-#{category} a:not(:has(img))")
        anchors


class DailyBeast extends Scraper
    constructor: ->
        @name = 'Daily Beast'
        @domain = 'http://www.thedailybeast.com'
        @url = '/newsweek'

    get_anchors: ->
        'Most Popular': $('header:contains(Most Popular)').next().find('li a')


class DailyCaller extends Scraper
    constructor: ->
        @name = 'DailyCaller'
        @domain = 'http://dailycaller.com'
        @url = '/section/politics/'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['most-emailed', 'Most emailed'], ['most-popular', 'Most popular']]
            anchors[name] = $("#widget-#{category} .category-headline .blue a")
        anchors


class FoxNews extends Scraper
    constructor: ->
        @name = 'Fox News: Politics'
        @domain = 'http://www.foxnews.com'
        @url = '/politics'

    get_anchors: ->
        'Trending in Politics': $('.trending-descending li a')


class Gawker extends Scraper
    constructor: ->
        @name = 'Gawker'
        @domain = 'http://gawker.com/'
        @url = '/'

    get_anchors: ->
        anchors = {}
        # for [category, name] in [['popular', 'Most Popular'], ['commented', 'Most Commented']]
        #     # $("li#switch_#{category} a").click()
        #     anchors[name] = $('a.headline')
        # anchors
        'Default': $('a.headline')


class HuffingtonPost extends Scraper
    constructor: ->
        @name = 'Huffington Post'
        @domain = 'http://www.huffingtonpost.com'
        @url = '/'

    get_anchors: ->
        'Most Popular': $('.snp_most_popular_entry_desc a').not(-> @.href.indexOf('javascript') is 0)


class TheNation extends Scraper
    constructor: ->
        @name = 'The Nation'
        @domain = 'http://www.thenation.com'
        @url = '/politics'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['most-read', 'Most Read'], ['most-commented', 'Most Commented']]
            anchors[name] = $("##{category} ul div li a")
        anchors


class NewYorkTimes extends Scraper
    constructor: ->
        @name = 'New York Times'
        @domain = 'http://www.nytimes.com'
        @url = '/pages/national/'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['mostEmailed', 'Most Emailed'], ['mostViewed', 'Most Viewed']]
            anchors[name] = $("##{category} li a")
        anchors


class NewYorkTimesFrontPage extends Scraper
    constructor: ->
        @name = 'New York Times'
        @domain = 'http://www.nytimes.com'
        @url = '/'

    get_anchors: ->
        # I think this one fails due to fancy ajax tabs.
        'Most Emailed': $('#mostPopContentMostEmailed a')


class NPR extends Scraper
    constructor: ->
        @name = 'NPR'
        @domain = 'http://www.npr.org'
        @url = '/'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['viewed', 'Most Viewed'], ['comm', 'Most Commented (not working)'], ['mostViewed', 'Most Recommended (not working)']]
            anchors[name] = $("#mostpopular .view#{category} ol li a")
        anchors


class PoliticalWire extends Scraper
    constructor: ->
        @name = 'Political Wire'
        @domain = 'http://politicalwire.com'
        @url = '/'

    get_anchors: ->
        # Not working; links populated by js on page load
        'Most Popular Stories': $('#popularthreads a')


class Politico extends Scraper
    constructor: ->
        @name = 'Politico'
        @domain = 'http://www.politico.com'
        @url = '/'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['MostRead', 'Most Read'], ['MostEmailed', 'Most Emailed'], ['MostCommented', 'Most Commented']]
            anchors[name] = $("#popular#{category} ol li a")
        anchors


class RealClearPolitics extends Scraper
    constructor: ->
        @name = 'Real Clear Politics'
        @domain = 'http://realclearpolitics.com'
        @url = '/'

    get_anchors: ->
        'Most Read': $('#most-read-box a.most-read')


class RollingStone extends Scraper
    constructor: ->
        @name = 'Rolling Stone'
        @domain = 'http://www.rollingstone.com'
        @url = '/politics'

    get_anchors: ->
        'Most Popular': $('h2:contains("Most Popular")').parent().find('div ul.politics li a:not(:has(img))')


class Slate extends Scraper
    constructor: ->
        @name = 'Slate'
        @domain = 'http://www.slate.com'
        @url = '/'

    get_anchors: ->
        'Most Read & Most Shared (need to disect them)': $('.most_read_and_commented li a').filter (a) -> a.href isnt 'javascript:void(0)'


class ThinkProgress extends Scraper
    constructor: ->
        @name = 'ThinkProgress'
        @domain = 'http://thinkprogress.org'
        @url = '/'

    get_anchors: ->
        'Facebook & Twitter (need to disect them)': $('.popular li a')


class WashingtonExaminer extends Scraper
    constructor: ->
        @name = 'Washington Examiner'
        @domain = 'http://washingtonexaminer.com'
        @url = '/'

    get_anchors: ->
        'Most Popular': $(".view-popular div ul li a")


class WashingtonPost extends Scraper
    constructor: ->
        @name = 'Washington Post: Politics'
        @domain = 'http://www.washingtonpost.com'
        @url = '/politics'

    get_anchors: ->
        # FIXME: duplicated method
        $titles = $('.most-post ul li span .title')
        $title = $(title for title in $titles.toArray() when $(title).text() is 'Most Popular')
        'Most Popular': $title.parent().next().find('a')


class WashingtonPostOpinions extends Scraper
    constructor: ->
        @name = 'Washington Post: Opinions'
        @domain = 'http://www.washingtonpost.com'
        @url = '/opinions'

    get_anchors: ->
        # FIXME: duplicated method
        $titles = $('.most-post ul li span .title')
        $title = $(title for title in $titles.toArray() when $(title).text() is 'Most Popular')
        'Most Popular': $title.parent().next().find('a')


class Wonkette extends Scraper
    constructor: ->
        @name = 'Wonkette'
        @domain = 'http://wonkette.com'
        @url = '/'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['most_read_box', 'Most Read'], ['most_commented_box', 'Most Commented']]
            anchors[name] = $("##{category} ul li a")
        anchors


class WSJ extends Scraper
    constructor: ->
        @name = 'WSJ'
        @domain = 'http://online.wsj.com'
        @url = '/public/page/news-world-business.html'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['mostRead', 'Most Read'], ['mostEmailed', 'Most Emailed'], ['mostCommented', 'Most Commented']]
            anchors[name] = $("#mostPopularTab_panel_#{category} ul li a")
        anchors


class WSJWashwire extends Scraper
    constructor: ->
        @name = 'WSJ: washwire'
        @domain = 'http://blogs.wsj.com'
        @url = '/washwire/'

    get_anchor_text: (a) ->
        text_getter = (a) ->
            text = a.href
            if text[text.length - 1] == '/'
                text = text.slice(0, text.length - 1)
            text.split('/').pop()

        $(a).text() or text_getter(a)

    get_anchors: ->
        anchors = {}
        for category in ['Commented', 'Read']
            # Find the id of the tab with the corresponding title;
            # the links are in a div whose id is determined by the tab id.
            $aa = $(".mostPopular .tab a")
            tab_id = $(a for a in $aa.toArray() when $(a).text() is category).parent().attr("id")
            panel_id = tab_id.replace('_tab_', '_panel_')
            anchors[category] = $("##{panel_id} li a")
        anchors


class TheWeek extends Scraper
    constructor: ->
        @name = 'The Week'
        @domain = 'http://theweek.com'
        @url = '/'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['mostRead', 'Most Read'], ['mostEmailed', 'Most Emailed']]
            anchors[name] = $("##{category} a")
        anchors


class Yahoo extends Scraper
    constructor: ->
        @name = 'Yahoo'
        @domain = 'http://news.yahoo.com'
        @url = '/most-popular'

    get_anchors: ->
        'Most popular': $(".most-popular-ul li div.txt a:not(a.more)")


SCRAPER_CLASSES = [
    TheAtlantic,
    AtlanticWire,
    BBCUSandCanadaArticle,
    BBCUSandCanada,
    TheBlaze,
    BusinessInsider,
    BuzzFeed,
#    CNN, # Popular on Facebook requires facebook access
    CBS,
#    CrooksAndLiars, # wasn't using
    DailyBeast,
    DailyCaller,
    FoxNews,
#    Gawker, # was latest not most popular
    HuffingtonPost,
    TheNation,
    NewYorkTimes,
#    NewYorkTimesFrontPage, # Defeated by ajax tabs?
    NPR,
#    PoliticalWire, # Not working, js-populated links
    Politico,
    RealClearPolitics,
    RollingStone,
    Slate,
    ThinkProgress,
    WashingtonExaminer,
    WashingtonPost,
    WashingtonPostOpinions,
#    Wonkette, #inappropriate!
    WSJ,
    WSJWashwire,
    TheWeek,
    Yahoo,
]


global.data = {}
global.count = SCRAPER_CLASSES.length
global.callback = ->
    if --count is 0 then util.puts JSON.stringify(data, null, 2)

for scraper_cls in SCRAPER_CLASSES
    (new scraper_cls).scrape()
