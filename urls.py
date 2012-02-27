from django.conf.urls.defaults import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', '_scraper.views.loading'),
    url(r'^scrapey$', '_scraper.views.scrapey'),
    url(r'^scraper$', '_scraper.views.scraper'),
)
