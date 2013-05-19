// Generated by CoffeeScript 1.4.0
(function() {
  var AtlanticWire, BBCUSandCanada, BBCUSandCanadaArticle, BusinessInsider, BuzzFeed, CBS, CNN, CNNNewsPulse, CrooksAndLiars, DailyBeast, DailyCaller, DailyKos, DailyMail, DrudgeReport, FoxNews, Gawker, HuffingtonPost, LATimes, NPR, NYDailyNews, NewYorkTimes, NewYorkTimesFrontPage, PoliticalWire, Politico, RealClearPolitics, Reddit, RollingStone, SCRAPER_CLASSES, Scraper, Slate, TheAtlantic, TheBlaze, TheNation, TheWeek, ThinkProgress, USAToday, WSJ, WSJWashwire, WashingtonExaminer, WashingtonPost, WashingtonPostOpinions, Wonkette, Yahoo, cheerio, request, scraper_cls, util, _i, _len,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  request = require('request');

  cheerio = require('cheerio');

  util = require('util');

  Scraper = (function() {

    function Scraper() {
      this._scrape = __bind(this._scrape, this);

      this.scrape = __bind(this.scrape, this);

    }

    Scraper.prototype.scrape = function() {
      var _this = this;
      return request({
        uri: this.domain + (this.url || '/')
      }, function(error, response, body) {
        var msg, _name, _ref;
        if ((_ref = data[_name = _this.name]) == null) {
          data[_name] = {};
        }
        if (error) {
          msg = response ? "status code " + response.statusCode : "no response";
          data[_this.name]['Error'] = _this.make_fake_entry("" + (_this.domain + _this.url) + " returned " + msg);
          callback();
          return;
        }
        try {
          _this.$ = cheerio.load(body);
          _this.body = body;
          return _this._scrape();
        } catch (err) {
          console.log(err);
          return data[_this.name]['Error'] = _this.make_fake_entry(err);
        } finally {
          callback();
        }
      });
    };

    Scraper.prototype.get_anchor_text = function(a) {
      return this.$(a).text();
    };

    Scraper.prototype._scrape = function() {
      var a, anchors, category, url_getter, _ref, _results,
        _this = this;
      url_getter = function(a) {
        var href;
        href = a.attribs.href;
        if (href[0] === '/') {
          return _this.domain + href;
        } else {
          return href;
        }
      };
      _ref = this.get_anchors();
      _results = [];
      for (category in _ref) {
        anchors = _ref[category];
        if (!(anchors instanceof Array)) {
          anchors = anchors.toArray();
        }
        _results.push(data[this.name][category] = (function() {
          var _i, _len, _results1;
          _results1 = [];
          for (_i = 0, _len = anchors.length; _i < _len; _i++) {
            a = anchors[_i];
            _results1.push({
              text: this.get_anchor_text(a).trim(),
              url: url_getter(a)
            });
          }
          return _results1;
        }).call(this));
      }
      return _results;
    };

    Scraper.prototype.make_fake_entry = function(content) {
      return [
        {
          text: content,
          url: ''
        }
      ];
    };

    return Scraper;

  })();

  AtlanticWire = (function(_super) {

    __extends(AtlanticWire, _super);

    function AtlanticWire() {
      this.name = 'Atlantic Wire';
      this.domain = 'http://www.theatlanticwire.com';
    }

    AtlanticWire.prototype.get_anchors = function() {
      return {
        'Most clicked': this.$('.most-clicked li a')
      };
    };

    return AtlanticWire;

  })(Scraper);

  TheAtlantic = (function(_super) {

    __extends(TheAtlantic, _super);

    function TheAtlantic() {
      this.name = 'The Atlantic';
      this.domain = 'http://www.theatlantic.com';
      this.url = '/politics/';
    }

    TheAtlantic.prototype.get_anchors = function() {
      return {
        'Most popular': this.$('#mostPopular a')
      };
    };

    return TheAtlantic;

  })(Scraper);

  BBCUSandCanada = (function(_super) {

    __extends(BBCUSandCanada, _super);

    function BBCUSandCanada() {
      this.name = 'The BBC US & Canada (daily most popular)';
      this.domain = 'http://www.bbc.co.uk';
      this.url = '/news/world/us_and_canada/';
    }

    BBCUSandCanada.prototype.get_anchors = function() {
      return {
        'Most popular': this.$('#most-popular-category div li a').first()
      };
    };

    return BBCUSandCanada;

  })(Scraper);

  BBCUSandCanadaArticle = (function(_super) {

    __extends(BBCUSandCanadaArticle, _super);

    function BBCUSandCanadaArticle() {
      this.name = 'The BBC US & Canada';
      this.domain = 'http://www.bbc.co.uk';
      this.url = '/news/world-us-canada-16549624';
    }

    BBCUSandCanadaArticle.prototype.get_anchors = function() {
      var $aa, a, anchors, category, _i, _len, _ref;
      anchors = {};
      _ref = ['Shared', 'Read'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        category = _ref[_i];
        $aa = this.$("#most-popular .tab a");
        $aa = this.$((function() {
          var _j, _len1, _ref1, _results;
          _ref1 = $aa.toArray();
          _results = [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            a = _ref1[_j];
            if (this.$(a).text() === category) {
              _results.push(a);
            }
          }
          return _results;
        }).call(this));
        anchors[category] = $aa.parent().next().find('li a');
      }
      return anchors;
    };

    return BBCUSandCanadaArticle;

  })(Scraper);

  TheBlaze = (function(_super) {

    __extends(TheBlaze, _super);

    function TheBlaze() {
      this.name = 'The Blaze';
      this.domain = 'http://www.theblaze.com';
    }

    TheBlaze.prototype.get_anchors = function() {
      return {
        'Popular Stories': this.$('h3:contains(Popular Stories)').parent().find('li a.title')
      };
    };

    return TheBlaze;

  })(Scraper);

  BusinessInsider = (function(_super) {

    __extends(BusinessInsider, _super);

    function BusinessInsider() {
      this.name = 'Business Insider';
      this.domain = 'http://www.businessinsider.com';
      this.url = '/politics';
    }

    BusinessInsider.prototype.get_anchors = function() {
      var anchors, category, name, _i, _len, _ref, _ref1;
      anchors = {};
      _ref = [['1', 'Read'], ['2', 'Commented']];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], category = _ref1[0], name = _ref1[1];
        anchors[name] = this.$('h4:contains("Most Read")').parent().find("#sh-body" + category + " ul li p a");
      }
      return anchors;
    };

    return BusinessInsider;

  })(Scraper);

  BuzzFeed = (function(_super) {

    __extends(BuzzFeed, _super);

    function BuzzFeed() {
      this.name = 'Buzzfeed';
      this.domain = 'http://www.buzzfeed.com';
      this.url = '/politics';
    }

    BuzzFeed.prototype.get_anchors = function() {
      var validate;
      validate = function() {
        return (this.attr('href').indexOf('/usr/homebrew/lib/node/jsdom') === -1) && (this.attr('href').indexOf('twitter') === -1) && this.find('h2').length > 0;
      };
      return {
        'Most viral in Politics': this.$('.bf-widget div a').filter(validate)
      };
    };

    return BuzzFeed;

  })(Scraper);

  CBS = (function(_super) {

    __extends(CBS, _super);

    function CBS() {
      this.name = 'CBS';
      this.domain = 'http://www.cbsnews.com';
      this.url = '/2240-100_162-0.html';
    }

    CBS.prototype.get_anchors = function() {
      return {
        'Most Popular Stories and Blog Posts': this.$('#mostPopularFullPage ol li a').toArray().slice(0, 5)
      };
    };

    return CBS;

  })(Scraper);

  CNN = (function(_super) {

    __extends(CNN, _super);

    function CNN() {
      this.name = 'CNN';
      this.domain = 'http://www.cnn.com';
    }

    CNN.prototype.get_anchors = function() {
      return {
        "Popular on Facebook (doesn't work due to facebook auth)": this.$('#pmFacebook li a')
      };
    };

    return CNN;

  })(Scraper);

  CNNNewsPulse = (function(_super) {

    __extends(CNNNewsPulse, _super);

    function CNNNewsPulse() {
      this.name = 'CNN NewsPulse';
      this.domain = 'http://newspulse.cnn.com/';
    }

    CNNNewsPulse.prototype.get_anchor_text = function(a) {
      return a.attribs.href;
    };

    CNNNewsPulse.prototype.get_anchors = function() {
      return {
        'News': this.$('a.nsFullStoryLink').filter(function(i) {
          return i < 5;
        })
      };
    };

    return CNNNewsPulse;

  })(Scraper);

  CrooksAndLiars = (function(_super) {

    __extends(CrooksAndLiars, _super);

    function CrooksAndLiars() {
      this.name = 'Crooks and Liars';
      this.domain = 'http://crooksandliars.com';
    }

    CrooksAndLiars.prototype.get_anchors = function() {
      var anchors, category, _i, _len, _ref;
      anchors = {};
      _ref = ['day', 'week'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        category = _ref[_i];
        anchors["Top Media: " + category] = this.$("#topmedia-" + category + " a:not(:has(img))");
      }
      return anchors;
    };

    return CrooksAndLiars;

  })(Scraper);

  DailyMail = (function(_super) {

    __extends(DailyMail, _super);

    function DailyMail() {
      this.name = 'Daily Mail';
      this.domain = 'http://www.dailymail.co.uk';
      this.url = '/ushome';
    }

    DailyMail.prototype.get_anchors = function() {
      return {
        'Most Read': this.$('.news.tabbed-headlines .dm-tab-pane-hidden a').toArray().slice(0, 3)
      };
    };

    return DailyMail;

  })(Scraper);

  DailyBeast = (function(_super) {

    __extends(DailyBeast, _super);

    function DailyBeast() {
      this.name = 'Daily Beast';
      this.domain = 'http://www.thedailybeast.com';
      this.url = '/newsweek';
    }

    DailyBeast.prototype.get_anchors = function() {
      return {
        'Most Popular': this.$('header:contains(Most Popular)').next().find('li a')
      };
    };

    return DailyBeast;

  })(Scraper);

  DailyCaller = (function(_super) {

    __extends(DailyCaller, _super);

    function DailyCaller() {
      this.name = 'DailyCaller';
      this.domain = 'http://dailycaller.com';
      this.url = '/section/politics/';
    }

    DailyCaller.prototype.get_anchors = function() {
      var anchors, category, name, _i, _len, _ref, _ref1;
      anchors = {};
      _ref = [['most-emailed', 'Most emailed'], ['most-popular', 'Most popular']];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], category = _ref1[0], name = _ref1[1];
        anchors[name] = this.$("#widget-" + category + " a");
      }
      return anchors;
    };

    return DailyCaller;

  })(Scraper);

  DailyKos = (function(_super) {

    __extends(DailyKos, _super);

    function DailyKos() {
      this.name = 'DailyKos';
      this.domain = 'http://www.dailykos.com';
    }

    DailyKos.prototype.get_anchors = function() {
      return {
        'Recommended': this.$('#most-popular_div a.title')
      };
    };

    return DailyKos;

  })(Scraper);

  DrudgeReport = (function(_super) {

    __extends(DrudgeReport, _super);

    function DrudgeReport() {
      this.name = 'DrudgeReport';
      this.domain = 'http://www.drudgereport.com';
    }

    DrudgeReport.prototype.get_anchors = function() {
      return {
        'Other headlines': this.$('tt b a'),
        'All links': this.$('a')
      };
    };

    return DrudgeReport;

  })(Scraper);

  FoxNews = (function(_super) {

    __extends(FoxNews, _super);

    function FoxNews() {
      this.name = 'Fox News: Politics';
      this.domain = 'http://www.foxnews.com';
      this.url = '/politics';
    }

    FoxNews.prototype.get_anchors = function() {
      return {
        'Trending in Politics': this.$('.trending li a')
      };
    };

    return FoxNews;

  })(Scraper);

  Gawker = (function(_super) {

    __extends(Gawker, _super);

    function Gawker() {
      this.name = 'Gawker';
      this.domain = 'http://gawker.com/';
    }

    Gawker.prototype.get_anchors = function() {
      var anchors;
      anchors = {};
      return {
        'Default': this.$('a.headline')
      };
    };

    return Gawker;

  })(Scraper);

  HuffingtonPost = (function(_super) {

    __extends(HuffingtonPost, _super);

    function HuffingtonPost() {
      this.name = 'Huffington Post';
      this.domain = 'http://www.huffingtonpost.com';
    }

    HuffingtonPost.prototype.get_anchors = function() {
      return {
        'Most Popular': this.$('a.most_popular_entry_title')
      };
    };

    return HuffingtonPost;

  })(Scraper);

  LATimes = (function(_super) {

    __extends(LATimes, _super);

    function LATimes() {
      this.name = 'LA Times';
      this.domain = 'http://www.latimes.com';
    }

    LATimes.prototype.get_anchors = function() {
      return {
        'Most Viewed': this.$(".mviewed a[href*='mostviewed']"),
        'Most Emailed': this.$("a[href*='MostEmailed']")
      };
    };

    return LATimes;

  })(Scraper);

  TheNation = (function(_super) {

    __extends(TheNation, _super);

    function TheNation() {
      this.name = 'The Nation';
      this.domain = 'http://www.thenation.com';
      this.url = '/politics';
    }

    TheNation.prototype.get_anchors = function() {
      var anchors, category, name, _i, _len, _ref, _ref1;
      anchors = {};
      _ref = [['most-read', 'Most Read'], ['most-commented', 'Most Commented']];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], category = _ref1[0], name = _ref1[1];
        anchors[name] = this.$("#" + category + " ul div li a");
      }
      return anchors;
    };

    return TheNation;

  })(Scraper);

  NYDailyNews = (function(_super) {

    __extends(NYDailyNews, _super);

    function NYDailyNews() {
      this.name = 'NY Daily News';
      this.domain = 'http://www.nydailynews.com';
    }

    NYDailyNews.prototype.get_anchors = function() {
      return {
        'Most Read + Most Shared': this.$('#most-read-content a.gallery').toArray().slice(0, 10)
      };
    };

    return NYDailyNews;

  })(Scraper);

  NewYorkTimes = (function(_super) {

    __extends(NewYorkTimes, _super);

    function NewYorkTimes() {
      this.name = 'New York Times';
      this.domain = 'http://www.nytimes.com';
      this.url = '/pages/national/';
    }

    NewYorkTimes.prototype.get_anchors = function() {
      var anchors, category, name, _i, _len, _ref, _ref1;
      anchors = {};
      _ref = [['mostEmailed', 'Most Emailed'], ['mostViewed', 'Most Viewed']];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], category = _ref1[0], name = _ref1[1];
        anchors[name] = this.$("#" + category + " li a");
      }
      return anchors;
    };

    return NewYorkTimes;

  })(Scraper);

  NewYorkTimesFrontPage = (function(_super) {

    __extends(NewYorkTimesFrontPage, _super);

    function NewYorkTimesFrontPage() {
      this.name = 'New York Times';
      this.domain = 'http://www.nytimes.com';
    }

    NewYorkTimesFrontPage.prototype.get_anchors = function() {
      return {
        'Most Emailed': this.$('#mostPopContentMostEmailed a')
      };
    };

    return NewYorkTimesFrontPage;

  })(Scraper);

  NPR = (function(_super) {

    __extends(NPR, _super);

    function NPR() {
      this.name = 'NPR';
      this.domain = 'http://www.npr.org';
    }

    NPR.prototype.get_anchors = function() {
      var anchors, category, name, _i, _len, _ref, _ref1;
      anchors = {};
      _ref = [['viewed', 'Most Viewed'], ['comm', 'Most Commented (not working)'], ['mostViewed', 'Most Recommended (not working)']];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], category = _ref1[0], name = _ref1[1];
        anchors[name] = this.$("#mostpopular .view" + category + " ol li a");
      }
      return anchors;
    };

    return NPR;

  })(Scraper);

  PoliticalWire = (function(_super) {

    __extends(PoliticalWire, _super);

    function PoliticalWire() {
      this.name = 'Political Wire';
      this.domain = 'http://politicalwire.com';
    }

    PoliticalWire.prototype.get_anchors = function() {
      return {
        'Most Popular Stories': this.$('#popularthreads a')
      };
    };

    return PoliticalWire;

  })(Scraper);

  Politico = (function(_super) {

    __extends(Politico, _super);

    function Politico() {
      this.name = 'Politico';
      this.domain = 'http://www.politico.com';
    }

    Politico.prototype.get_anchors = function() {
      var anchors, category, name, subtree, _i, _len, _ref, _ref1;
      subtree = this.body.slice(this.body.search('<div id="widgetPopularStories" class="widget widget-exclusive">'), this.body.search('</div><!--/widgetPopularStories-->'));
      this.$ = cheerio.load(subtree);
      anchors = {};
      _ref = [['StoriesBlogs', 'Stories/Blogs']];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], category = _ref1[0], name = _ref1[1];
        anchors[name] = this.$("#popular" + category + " ol li a").toArray().slice(0, 10);
      }
      return anchors;
    };

    return Politico;

  })(Scraper);

  RealClearPolitics = (function(_super) {

    __extends(RealClearPolitics, _super);

    function RealClearPolitics() {
      this.name = 'Real Clear Politics';
      this.domain = 'http://realclearpolitics.com';
    }

    RealClearPolitics.prototype.get_anchors = function() {
      return {
        'Most Read': this.$('#most-read-box a.most-read')
      };
    };

    return RealClearPolitics;

  })(Scraper);

  Reddit = (function(_super) {

    __extends(Reddit, _super);

    function Reddit() {
      this.name = 'Reddit';
      this.domain = 'http://www.reddit.com';
      this.url = '/r/politics';
    }

    Reddit.prototype.get_anchors = function() {
      return {
        'Hot': this.$("#siteTable a.title").toArray().slice(0, 10)
      };
    };

    return Reddit;

  })(Scraper);

  RollingStone = (function(_super) {

    __extends(RollingStone, _super);

    function RollingStone() {
      this.name = 'Rolling Stone';
      this.domain = 'http://www.rollingstone.com';
      this.url = '/politics';
    }

    RollingStone.prototype.get_anchors = function() {
      return {};
    };

    return RollingStone;

  })(Scraper);

  Slate = (function(_super) {

    __extends(Slate, _super);

    function Slate() {
      this.name = 'Slate';
      this.domain = 'http://www.slate.com';
    }

    Slate.prototype.get_anchors = function() {
      return {
        'Most Read & Most Shared (need to disect them)': this.$('.most_read_and_commented li a').filter(function() {
          return this.attr('href') !== 'javascript:void(0)';
        })
      };
    };

    return Slate;

  })(Scraper);

  ThinkProgress = (function(_super) {

    __extends(ThinkProgress, _super);

    function ThinkProgress() {
      this.name = 'ThinkProgress';
      this.domain = 'http://thinkprogress.org';
    }

    ThinkProgress.prototype.get_anchors = function() {
      return {
        'Facebook & Twitter (need to disect them)': this.$('.popular li a')
      };
    };

    return ThinkProgress;

  })(Scraper);

  USAToday = (function(_super) {

    __extends(USAToday, _super);

    function USAToday() {
      this.name = 'USA Today';
      this.domain = 'http://www.usatoday.com';
      this.url = '/news';
    }

    USAToday.prototype.get_anchors = function() {
      return {};
    };

    return USAToday;

  })(Scraper);

  WashingtonExaminer = (function(_super) {

    __extends(WashingtonExaminer, _super);

    function WashingtonExaminer() {
      this.name = 'Washington Examiner';
      this.domain = 'http://washingtonexaminer.com';
    }

    WashingtonExaminer.prototype.get_anchors = function() {
      return {
        'Most Popular': this.$(".view-popular div ul li a")
      };
    };

    return WashingtonExaminer;

  })(Scraper);

  WashingtonPost = (function(_super) {

    __extends(WashingtonPost, _super);

    function WashingtonPost() {
      this.name = 'Washington Post: Politics';
      this.domain = 'http://www.washingtonpost.com';
      this.url = '/politics';
    }

    WashingtonPost.prototype.get_anchors = function() {
      var $title, $titles, title;
      $titles = this.$('.most-post ul li span .title');
      $title = this.$((function() {
        var _i, _len, _ref, _results;
        _ref = $titles.toArray();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          title = _ref[_i];
          if (this.$(title).text() === 'Most Popular') {
            _results.push(title);
          }
        }
        return _results;
      }).call(this));
      return {
        'Most Popular': $title.parent().next().find('a')
      };
    };

    return WashingtonPost;

  })(Scraper);

  WashingtonPostOpinions = (function(_super) {

    __extends(WashingtonPostOpinions, _super);

    function WashingtonPostOpinions() {
      this.name = 'Washington Post: Opinions';
      this.domain = 'http://www.washingtonpost.com';
      this.url = '/opinions';
    }

    WashingtonPostOpinions.prototype.get_anchors = function() {
      var $title, $titles, title;
      $titles = this.$('.most-post ul li span .title');
      $title = this.$((function() {
        var _i, _len, _ref, _results;
        _ref = $titles.toArray();
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          title = _ref[_i];
          if (this.$(title).text() === 'Most Popular') {
            _results.push(title);
          }
        }
        return _results;
      }).call(this));
      return {
        'Most Popular': $title.parent().next().find('a')
      };
    };

    return WashingtonPostOpinions;

  })(Scraper);

  Wonkette = (function(_super) {

    __extends(Wonkette, _super);

    function Wonkette() {
      this.name = 'Wonkette';
      this.domain = 'http://wonkette.com';
    }

    Wonkette.prototype.get_anchors = function() {
      var anchors, category, name, _i, _len, _ref, _ref1;
      anchors = {};
      _ref = [['most_read_box', 'Most Read'], ['most_commented_box', 'Most Commented']];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], category = _ref1[0], name = _ref1[1];
        anchors[name] = this.$("#" + category + " ul li a");
      }
      return anchors;
    };

    return Wonkette;

  })(Scraper);

  WSJ = (function(_super) {

    __extends(WSJ, _super);

    function WSJ() {
      this.name = 'WSJ';
      this.domain = 'http://online.wsj.com';
      this.url = '/public/page/news-world-business.html';
    }

    WSJ.prototype.get_anchors = function() {
      var anchors, category, name, _i, _len, _ref, _ref1;
      anchors = {};
      _ref = [['mostRead', 'Most Read'], ['mostEmailed', 'Most Emailed'], ['mostCommented', 'Most Commented']];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], category = _ref1[0], name = _ref1[1];
        anchors[name] = this.$("#mostPopularTab_panel_" + category + " ul li a");
      }
      return anchors;
    };

    return WSJ;

  })(Scraper);

  WSJWashwire = (function(_super) {

    __extends(WSJWashwire, _super);

    function WSJWashwire() {
      this.name = 'WSJ: washwire';
      this.domain = 'http://blogs.wsj.com';
      this.url = '/washwire/';
    }

    WSJWashwire.prototype.get_anchor_text = function(a) {
      var text_getter;
      text_getter = function(a) {
        var text;
        text = a.attribs.href;
        if (text[text.length - 1] === '/') {
          text = text.slice(0, text.length - 1);
        }
        return text.split('/').pop();
      };
      return this.$(a).text() || text_getter(a);
    };

    WSJWashwire.prototype.get_anchors = function() {
      return {
        'Trending Now': this.$('.trendingNow ul.newsItem li h2 a')
      };
    };

    return WSJWashwire;

  })(Scraper);

  TheWeek = (function(_super) {

    __extends(TheWeek, _super);

    function TheWeek() {
      this.name = 'The Week';
      this.domain = 'http://theweek.com';
    }

    TheWeek.prototype.get_anchors = function() {
      var anchors, category, name, _i, _len, _ref, _ref1;
      anchors = {};
      _ref = [['mostRead', 'Most Read'], ['mostEmailed', 'Most Emailed']];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        _ref1 = _ref[_i], category = _ref1[0], name = _ref1[1];
        anchors[name] = this.$("#" + category + " a");
      }
      return anchors;
    };

    return TheWeek;

  })(Scraper);

  Yahoo = (function(_super) {

    __extends(Yahoo, _super);

    function Yahoo() {
      this.name = 'Yahoo';
      this.domain = 'http://news.yahoo.com';
      this.url = '/most-popular';
    }

    Yahoo.prototype.get_anchors = function() {
      return {
        'Most popular': this.$(".most-popular-ul li div.txt a:not(a.more)").toArray().slice(0, 15)
      };
    };

    return Yahoo;

  })(Scraper);

  SCRAPER_CLASSES = [TheAtlantic, AtlanticWire, BBCUSandCanadaArticle, BBCUSandCanada, TheBlaze, BusinessInsider, BuzzFeed, CNNNewsPulse, CBS, DailyBeast, DailyCaller, DailyKos, DailyMail, FoxNews, HuffingtonPost, LATimes, TheNation, NYDailyNews, NewYorkTimes, NPR, Politico, RealClearPolitics, Reddit, RollingStone, Slate, USAToday, WashingtonExaminer, WashingtonPost, WashingtonPostOpinions, WSJ, WSJWashwire, TheWeek, Yahoo];

  global.data = {};

  global.count = SCRAPER_CLASSES.length;

  global.callback = function() {};

  setTimeout((function() {
    global.count = -1;
    util.puts(JSON.stringify(data, null, 2));
    return process.exit(0);
  }), 20 * 1000);

  for (_i = 0, _len = SCRAPER_CLASSES.length; _i < _len; _i++) {
    scraper_cls = SCRAPER_CLASSES[_i];
    (new scraper_cls).scrape();
  }

}).call(this);
