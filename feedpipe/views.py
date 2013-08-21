from lxml import etree
from StringIO import StringIO
import requests

from django.http import HttpResponse


def politix_homepage(request):
    url = 'http://politix.topix.com/rssfeeds/homepage'
    resp = requests.get(url)
    resp.raise_for_status()
    rss = etree.fromstring(resp.content)
    _process_politix_homepage_feed(rss)
    buf = StringIO()
    rss.getroottree().write(buf)
    return HttpResponse(
        content=buf.getvalue(),
        content_type='text/xml',
        status=200,
    )


def _process_politix_homepage_feed(rss):
    for el in rss.getiterator():
        if el.tag == 'item':
            _process_politix_homepage_item(el)


def _process_politix_homepage_item(item):
    creator = item.find('{http://purl.org/dc/elements/1.1/}creator')
    if creator is None:
        return
    link = item.find('link')
    if link is None:
        print "Expected link element"
    else:
        link.text += ' @Politix%s' % creator.text.split()[0]
