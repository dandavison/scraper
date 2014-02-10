from django.conf import settings
from django.conf.urls.defaults import patterns, include, url


urlpatterns = patterns(
    '',
    url(r'^login/$', 'django.contrib.auth.views.login', {
        'template_name': 'login.html'
    }),

    url(r'^$', '_scraper.views.loading'),
    url(r'^scrapey/(?P<sources>\w+)/$', '_scraper.views.loading'),
    url(r'^scraper/(?P<sources>\w+)/$', '_scraper.views.scraper'),

    url(r'^politix/stories/$', 'politix.views.stories'),
    url(r'^politix/stories/data/$', 'politix.views.stories_data'),

    url(r'^feedpipe/politix/homepage/$', 'feedpipe.views.politix_homepage'),
)

urlpatterns += patterns(
    '',
    (r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.STATIC_ROOT}),
)
