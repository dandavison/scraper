from lxml import etree
from StringIO import StringIO
import requests

from django.http import HttpResponse


def politix_homepage(request):
    url = 'http://politix.topix.com/rssfeeds/homepage'
    resp = requests.get(url)
    resp.raise_for_status()
    rss = etree.fromstring(resp.content)
    exclude = {
        name.lower()
        for name in request.GET.get('exclude', '').split(',')
    }
    _process_politix_homepage_feed(rss, exclude)
    buf = StringIO()
    rss.getroottree().write(buf)
    return HttpResponse(
        content=buf.getvalue(),
        content_type='text/xml',
        status=200,
    )


def _process_politix_homepage_feed(rss, exclude):
    for el in rss.getiterator():
        if el.tag == 'item':
            _process_politix_homepage_item(el, exclude)


def _process_politix_homepage_item(item, exclude):
    creator = item.find('{http://purl.org/dc/elements/1.1/}creator')
    if creator is None:
        return
    link = item.find('link')
    if link is None:
        print "Expected link element"
    else:
        name = creator.text.split()[0]
        if name.lower() not in exclude:
            link.text += ' @Politix%s' % name
