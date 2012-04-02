$ ->
    article_ages = for el in $('a.article')
        $el = $(el)
        [$el, $el.attr('age')]

    handle_change = (event, info) ->
        '''
        Hide articles older than the slider value
        '''
        $('#slider-value').html info.value

        seconds_limit = info.value * 60 * 60
        for [$article, age] in article_ages
            $article.toggle age < seconds_limit

    initial_value = 3 * 24
    $('#slider').slider
        min: 1
        max: 5 * 24
        value: initial_value
        change: handle_change

    $('#slider-value').html initial_value
