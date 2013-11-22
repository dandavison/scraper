request = require 'request'
cheerio = require 'cheerio'
util = require 'util'


class Scraper
    scrape: =>
        request uri: @domain + (@url or '/'), (error, response, body) =>
            data[@name] ?= {}
            if error
                msg = if response then "status code #{response.statusCode}" else "no response"
                data[@name]['Error'] = @make_fake_entry "#{@domain + @url} returned #{msg}"
                callback()
                return
            try
                @$ = cheerio.load body
                @body = body  # Make the raw data available in case parsing fails
                @_scrape()
            catch err
                console.log err
                data[@name]['Error'] = @make_fake_entry err
            finally
                callback()

    get_anchor_text: (a) -> @$(a).text()

    _scrape: =>
        url_getter = (a) =>
            href = a.attribs.href
            if href[0] is '/' then @domain + href else href
        for category, anchors of @get_anchors()
            # anchors may be native array or cheerio wrapped set
            if not (anchors instanceof Array)
                anchors = anchors.toArray()
            data[@name][category] = for a in anchors
                text: @get_anchor_text(a).trim()
                url: url_getter(a)

    make_fake_entry: (content) ->
        [text: content, url: '']


class AtlanticWire extends Scraper
    constructor: ->
        @name = 'Atlantic Wire'
        @domain = 'http://www.theatlanticwire.com'

    get_anchors: -> 'Most clicked': @$('.most-clicked li a')


class TheAtlantic extends Scraper
    constructor: ->
        @name = 'The Atlantic'
        @domain = 'http://www.theatlantic.com'
        @url = '/politics/'

    get_anchors: -> 'Most popular': @$('#mostPopular a')


class BBCUSandCanada extends Scraper
    constructor: ->
        @name = 'The BBC US & Canada (daily most popular)'
        @domain = 'http://www.bbc.co.uk'
        @url = '/news/world/us_and_canada/'

    get_anchors: -> 'Most popular': @$('#most-popular-category div li a').first()


class BBCUSandCanadaArticle extends Scraper
    constructor: ->
        @name = 'The BBC US & Canada'
        @domain = 'http://www.bbc.co.uk'
        @url = '/news/world-us-canada-16549624'

    get_anchors: ->
        anchors = {}
        for category in ['Shared', 'Read']
            $aa = @$("#most-popular .tab a")
            $aa = @$(a for a in $aa.toArray() when @$(a).text() is category)
            anchors[category] = $aa.parent().next().find('li a')
        anchors


class BingTrendingOnFacebook extends Scraper
    constructor: ->
        @name = 'Bing'
        @domain = 'http://www.bing.com/news'

    get_anchors: ->
        'Trending News on Facebook': @$('div.article[name="facebook"] a')


class TheBlazeSocial extends Scraper
    constructor: ->
        @name = 'The Blaze'
        @domain = 'http://www.theblaze.com'

    get_anchors: -> 'Social': @$('ul#tblz_ps_tab_social li a.tblz_ps_title')


class Breitbart extends Scraper
    constructor: ->
        @name = 'Breitbart'
        @domain = 'http://www.breitbart.com/'

    get_anchors: ->
        'Most Popular': @$('.disqus-popular-threads a')


class BusinessInsider extends Scraper
    constructor: ->
        @name = 'Business Insider'
        @domain = 'http://www.businessinsider.com'
        @url = '/politics'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['1', 'Read'], ['2', 'Commented']]
            anchors[name] = @$('h4:contains("Most Read")').parent().find("#sh-body#{category} ul li p a")
        anchors


class BuzzFeed extends Scraper
    constructor: ->
        @name = 'Buzzfeed'
        @domain = 'http://www.buzzfeed.com'
        @url = '/politics'

    get_anchors: ->
        validate = ->
            (@.attr('href').indexOf('/usr/homebrew/lib/node/jsdom') == -1) and \
            (@.attr('href').indexOf('twitter') == -1) and \
             @.find('h2').length > 0

        'Most viral in Politics': @$('.bf-widget div a').filter(validate)


class CBS extends Scraper
    constructor: ->
        @name = 'CBS'
        @domain = 'http://www.cbsnews.com'
        @url = '/2240-100_162-0.html'

    get_anchors: ->
        'Most Popular Stories and Blog Posts': @$('#mostPopularFullPage ol li a').toArray()[0...5]


class _CNN extends Scraper
    constructor: ->
        @name = '_CNN'
        @domain = 'http://www.cnn.com'

    get_anchors: ->
        # @$('#pmFacebook li a')
        "Popular on Facebook doesn't work due to facebook auth": []


class CNNNewsPulse extends Scraper
    constructor: ->
        @name = 'CNN NewsPulse'
        @domain = 'http://newspulse.cnn.com/'

    get_anchor_text: (a) -> a.attribs.href

    get_anchors: ->
        'News': @$('a.nsFullStoryLink').filter (i) -> i < 5


class CrooksAndLiars extends Scraper
    constructor: ->
        @name = 'Crooks and Liars'
        @domain = 'http://crooksandliars.com'

    get_anchors: ->
        anchors = {}
        for category in ['day', 'week']
            anchors["Top Media: #{category}"] = @$("#topmedia-#{category} a:not(:has(img))")
        anchors


class DailyMail extends Scraper
    constructor: ->
        @name = 'Daily Mail'
        @domain = 'http://www.dailymail.co.uk'
        @url = '/ushome'

    get_anchors: ->
        'Most Read': @$('.news.tabbed-headlines .dm-tab-pane-hidden a').toArray()[0...3]


class _DailyBeast extends Scraper
    constructor: ->
        @name = '_Daily Beast'
        @domain = 'http://www.thedailybeast.com'
        @url = '/newsweek'

    get_anchors: ->
        "Site has changed": []


class DailyCaller extends Scraper
    constructor: ->
        @name = 'DailyCaller'
        @domain = 'http://dailycaller.com'
        @url = '/section/politics/'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['most-emailed', 'Most emailed'], ['most-popular', 'Most popular']]
            anchors[name] = @$("#widget-#{category} a")
        anchors


class DailyKos extends Scraper
    constructor: ->
        @name = 'DailyKos'
        @domain = 'http://www.dailykos.com'

    get_anchors: ->
        'Recommended': @$('#most-popular_div a.title')


class DrudgeReport extends Scraper
    constructor: ->
        @name = '_DrudgeReport'
        @domain = 'http://www.drudgereport.com'

    get_anchors: ->
        # drudge uses upper case tags which cheerio fails to parse
        @body = (@body
            .replace('<BR', '<br')
            .replace('</BR>', '</br>')
            .replace('<A', '<a')
            .replace('</A>', '</a>')
            .replace('HREF', 'href'))
        @$ = cheerio.load(@body)
        "Top Headlines": @$('#drudgeTopHeadlines a')


class FoxNews extends Scraper
    constructor: ->
        @name = 'Fox News: Politics'
        @domain = 'http://www.foxnews.com'

    get_anchors: ->
        'Fox News Now': @$('.trending-descending .dv-item a')



class Guardian extends Scraper
    constructor: ->
        @name = 'Guardian US'
        @domain = 'http://www.guardiannews.com'

    get_anchors: ->
        'Most viewed': @$('#most-viewed a')


class Gawker extends Scraper
    constructor: ->
        @name = 'Gawker'
        @domain = 'http://gawker.com/'

    get_anchors: ->
        "Top Stories": @$('.sidebar-content .headline a')


class HuffingtonPost extends Scraper
    constructor: ->
        @name = 'Huffington Post'
        @domain = 'http://www.huffingtonpost.com'

    get_anchors: ->
        'Most Popular': @$('a.most_popular_entry_title')


class LATimes extends Scraper
    constructor: ->
        @name = 'LA Times'
        @domain = 'http://www.latimes.com'

    get_anchors: ->
        'Most Viewed': @$(".mviewed a[href*='mostviewed']")


class TheNation extends Scraper
    constructor: ->
        @name = 'The Nation'
        @domain = 'http://www.thenation.com'
        @url = '/politics'

    get_anchors: ->
        "Most Read": this.$("#quicktabs_tabpage_most_block_0 a")


class NYDailyNews extends Scraper
    constructor: ->
        @name = 'NY Daily News'
        @domain = 'http://www.nydailynews.com'

    get_anchors: ->
        # These work in the browser, but not in jsdom?
        # 'Most Read': @$('#most-read-content div[style*="display: block"] a.gallery')
        # 'Most Shared': @$('#most-read-content div[style*="display: none"] a.gallery')
        'Most Read + Most Shared': @$('#most-read-content a.gallery').toArray()[0...10]


class NewYorkTimes extends Scraper
    constructor: ->
        @name = 'New York Times'
        @domain = 'http://www.nytimes.com'
        @url = '/pages/national/'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['mostEmailed', 'Most Emailed'], ['mostViewed', 'Most Viewed']]
            anchors[name] = @$("##{category} li a")
        anchors


class _NewYorkTimesFrontPage extends Scraper
    constructor: ->
        @name = '_New York Times'
        @domain = 'http://www.nytimes.com'

    get_anchors: ->
        "Not possible: links created by javascript": []
        # # I think this one fails due to fancy ajax tabs.
        # 'Most Emailed': @$('#mostPopContentMostEmailed a')


class NPR extends Scraper
    constructor: ->
        @name = 'NPR'
        @domain = 'http://www.npr.org'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['viewed', 'Most Viewed']]
            anchors[name] = @$("#mostpopular .view#{category} ol li a")
        anchors


class PolicyMic extends Scraper
    constructor: ->
        @name = 'PolicyMic politics'
        @domain = 'http://www.policymic.com/politics'

    get_anchors: ->
        "Recommended stories": @$('.recommended-story a')


class _PoliticalWire extends Scraper
    constructor: ->
        @name = '_Political Wire'
        @domain = 'http://politicalwire.com'

    get_anchors: ->
        "Not possible: links created by javascript" : []


class Politico extends Scraper
    constructor: ->
        @name = 'Politico'
        @domain = 'http://www.politico.com'

    get_anchors: ->
        # cheerio can't parse politico. It loses the plot at a fragment of js starting at line 1554.
        subtree = @body.slice(@body.search('<div id="widgetPopularStories" class="widget widget-exclusive">'),
                              @body.search('</div><!--/widgetPopularStories-->'))
        @$ = cheerio.load(subtree)

        anchors = {}
        for [category, name] in [['StoriesBlogs', 'Stories/Blogs']]
            anchors[name] = @$("#popular#{category} ol li a").toArray()[0...10]
        anchors


class RealClearPolitics extends Scraper
    constructor: ->
        @name = 'Real Clear Politics'
        @domain = 'http://realclearpolitics.com'

    get_anchors: ->
        'Most Read': @$('#most-read-box a.most-read')


class Reason extends Scraper
    constructor: ->
        @name = 'Reason.com'
        @domain = 'http://reason.com/'

    get_anchors: ->
        'Most Viewed': @$('ul.stories[data-category="viewed"] a')


class Reddit extends Scraper
    constructor: ->
        @name = 'Reddit'
        @domain = 'http://www.reddit.com'
        @url = '/r/politics'

    get_anchors: ->
        'Hot': @$("#siteTable a.title").toArray()[0...10]


class _RollingStone extends Scraper
    constructor: ->
        @name = '_Rolling Stone'
        @domain = 'http://www.rollingstone.com'
        @url = '/politics'

    get_anchors: ->
        "Site has changed": []


class Salon extends Scraper
    constructor: ->
        @name = 'Salon'
        @domain = 'http://www.salon.com/'

    get_anchors: ->
        'Most Read': @$('aside.rightSidebar ul li.smr-post a').toArray()[0...5]


class Slate extends Scraper
    constructor: ->
        @name = 'Slate'
        @domain = 'http://www.slate.com'

    get_anchors: ->
        'Most Read & Most Shared': @$('.mostshared a')


class ThinkProgress extends Scraper
    constructor: ->
        @name = 'ThinkProgress'
        @domain = 'http://thinkprogress.org'

    get_anchors: ->
        'Facebook & Twitter (need to disect them)': @$('.popular li a')


class ThinkProgressSocial extends Scraper
    constructor: ->
        @name = 'ThinkProgress'
        @domain = 'http://thinkprogress.org'

    get_anchors: ->
        'Most Shared': @$('div#newswhip-trending .tp-progress-entry a')


class Upworthy extends Scraper
    constructor: ->
        @name = 'Upworthy'
        @domain = 'http://www.upworthy.com'

    get_anchors: ->
        'Featured': @$('.featured-row #slide-content a.thumb')

    get_anchor_text: (a) -> a.attribs.href[1...]


class USAToday extends Scraper
    constructor: ->
        @name = 'USA Today'
        @domain = 'http://www.usatoday.com'
        @url = '/news'

    get_anchors: ->
        "Most popular": @$('.most-popular-items .headline a')


class WashingtonExaminer extends Scraper
    constructor: ->
        @name = 'Washington Examiner'
        @domain = 'http://washingtonexaminer.com'

    get_anchors: ->
        'Most Read': @$('.mini-list a')


class WashingtonPost extends Scraper
    constructor: ->
        @name = 'Washington Post: Politics'
        @domain = 'http://www.washingtonpost.com'
        @url = '/politics'

    get_anchors: ->
        # FIXME: duplicated method
        $titles = @$('.most-post ul li span .title')
        $title = @$(title for title in $titles.toArray() when @$(title).text() is 'Most Popular')
        'Most Popular': $title.parent().next().find('a')


class WashingtonPostOpinions extends Scraper
    constructor: ->
        @name = 'Washington Post: Opinions'
        @domain = 'http://www.washingtonpost.com'
        @url = '/opinions'

    get_anchors: ->
        # FIXME: duplicated method
        $titles = @$('.most-post ul li span .title')
        $title = @$(title for title in $titles.toArray() when @$(title).text() is 'Most Popular')
        'Most Popular': $title.parent().next().find('a')


class Wonkette extends Scraper
    constructor: ->
        @name = 'Wonkette'
        @domain = 'http://wonkette.com'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['most_read_box', 'Most Read'], ['most_commented_box', 'Most Commented']]
            anchors[name] = @$("##{category} ul li a")
        anchors


class WSJ extends Scraper
    constructor: ->
        @name = 'WSJ'
        @domain = 'http://online.wsj.com'
        @url = '/public/page/news-world-business.html'

    get_anchors: ->
        "Most popular": @$('.trendingNow h2 a')


class WSJWashwire extends Scraper
    constructor: ->
        @name = 'WSJ: washwire'
        @domain = 'http://blogs.wsj.com'
        @url = '/washwire/'

    get_anchor_text: (a) ->
        text_getter = (a) ->
            text = a.attribs.href
            if text[text.length - 1] == '/'
                text = text.slice(0, text.length - 1)
            text.split('/').pop()

        @$(a).text() or text_getter(a)

    get_anchors: ->
        'Trending Now': @$('.trendingNow ul.newsItem li h2 a')


class TheWeek extends Scraper
    constructor: ->
        @name = 'The Week'
        @domain = 'http://theweek.com'

    get_anchors: ->
        anchors = {}
        for [category, name] in [['mostRead', 'Most Read'], ['mostEmailed', 'Most Emailed']]
            anchors[name] = @$("##{category} a")
        anchors


class Yahoo extends Scraper
    constructor: ->
        @name = 'Yahoo'
        @domain = 'http://news.yahoo.com'
        @url = '/most-popular'

    get_anchors: ->
        'Most popular': @$(".most-popular-ul li div.txt a:not(a.more)").toArray()[0...15]


scraper_classes = [
    TheAtlantic,
#   AtlanticWire,
    BBCUSandCanadaArticle,
    BBCUSandCanada,
#    TheBlaze,
#    BusinessInsider,
    BuzzFeed,
#    _CNN, # Popular on Facebook requires facebook access
#    CNNNewsPulse,
#    CBS,
#    CrooksAndLiars,  # wasn't using
#    _DailyBeast,
#    DailyCaller,
    DailyKos,
    DailyMail,
    DrudgeReport,
#    FoxNews,
    Guardian,
#    _Gawker, # was latest not most popular
    HuffingtonPost,
#    LATimes
    TheNation,
    NYDailyNews
    NewYorkTimes,
#    _NewYorkTimesFrontPage,  # Defeated by ajax tabs?
#    NPR,
#    _PoliticalWire,  # Not working, js-populated links
    Politico,
    RealClearPolitics,
    Reddit,
#    _RollingStone,  # Site has changed
    Slate,
#    ThinkProgress,
    USAToday
#    WashingtonExaminer,
    WashingtonPost,
    WashingtonPostOpinions,
#    Wonkette,  #inappropriate!
    WSJ,
    WSJWashwire,
    TheWeek,
#    Yahoo,
]

scraper_classes_social = [
    BingTrendingOnFacebook,
    # Breitbart,
    BuzzFeed,
    DailyKos,
    DrudgeReport,
    FoxNews,
    # Gawker,
    HuffingtonPost,
    NewYorkTimes,
    # PolicyMic,
    Politico,
    Reason,
    Reddit,
    Salon,
    Slate,
    TheAtlantic,
    TheBlazeSocial,
    # ThinkProgressSocial,
    Upworthy,
    USAToday,
    WashingtonPost,
    WashingtonPostOpinions,
    WSJ,
]

scraper_classes = scraper_classes_social

global.data = {}
global.count = scraper_classes.length
global.callback = ->
    if --count is 0
        util.puts JSON.stringify(data, null, 2)
        process.exit(0)

# On heroku, responses must be delivered within 30s
setTimeout (->
    global.count = -1
    util.puts JSON.stringify(data, null, 2)
    process.exit(0)),
    20 * 1000

for scraper_cls in scraper_classes
    (new scraper_cls).scrape()
