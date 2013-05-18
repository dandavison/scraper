from django.conf.urls.defaults import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'scrapey.views.loading'),
    url(r'^scrapey$', 'scrapey.views.scrapey'),
    url(r'^scraper$', 'scrapey.views.scraper'),
)
