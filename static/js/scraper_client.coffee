$ ->
    $articles = $('a.article')
    article_ages = for el in $articles
        $el = $(el)
        [$el, $el.attr('age')]

    update_text = (hours_limit, displayed_articles) ->
        $('#slider-value').text hours_limit
        $('#displayed-articles').text displayed_articles
        $('#total-articles').text $articles.length


    handle_change = (event, info) ->
        '''
        Hide articles older than the slider value
        '''
        displayed_articles = 0

        seconds_limit = info.value * 60 * 60
        for [$article, age] in article_ages
            displayed = age < seconds_limit
            $article.toggle displayed
            if displayed
                displayed_articles += 1

        update_text info.value, displayed_articles


    initial_value = 3 * 24
    $('#slider').slider
        min: 1
        max: 5 * 24
        value: initial_value
        change: handle_change

    handle_change {}, value: initial_value
