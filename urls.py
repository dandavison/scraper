from django.conf.urls.defaults import patterns, include, url

urlpatterns = patterns('',
    url(r'^$', 'app.views.loading'),
    url(r'^scrapey$', 'app.views.scrapey'),
    url(r'^flying$', 'app.views.flying'),
)
