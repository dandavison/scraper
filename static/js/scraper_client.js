(function() {

  $(function() {
    var $articles, $el, article_ages, el, handle_change, initial_value, update_text;
    $articles = $('a.article');
    article_ages = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = $articles.length; _i < _len; _i++) {
        el = $articles[_i];
        $el = $(el);
        _results.push([$el, $el.attr('age')]);
      }
      return _results;
    })();
    update_text = function(hours_limit, displayed_articles) {
      $('#slider-value').text(hours_limit);
      $('#displayed-articles').text(displayed_articles);
      return $('#total-articles').text($articles.length);
    };
    handle_change = function(event, info) {
      'Hide articles older than the slider value';
      var $article, age, displayed, displayed_articles, seconds_limit, _i, _len, _ref;
      displayed_articles = 0;
      seconds_limit = info.value * 60 * 60;
      for (_i = 0, _len = article_ages.length; _i < _len; _i++) {
        _ref = article_ages[_i], $article = _ref[0], age = _ref[1];
        displayed = age < seconds_limit;
        $article.toggle(displayed);
        if (displayed) displayed_articles += 1;
      }
      return update_text(info.value, displayed_articles);
    };
    initial_value = 3 * 24;
    $('#slider').slider({
      min: 1,
      max: 5 * 24,
      value: initial_value,
      change: handle_change
    });
    return handle_change({}, {
      value: initial_value
    });
  });

}).call(this);
