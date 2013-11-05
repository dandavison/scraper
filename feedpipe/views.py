# -*- coding: utf-8 -*-
from lxml import etree
from StringIO import StringIO
import requests

from django.http import HttpResponse


AUTHORS = {
    'dain',
    'david',
    'lisa',
    'mary',
}

_PLACEHOLDER = '__xZZZx_PLACEHOLDER_xZZZx__'


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
    content = buf.getvalue()
    # Place a non-breaking space infront of the @ in an attempt to
    # avoid stripping of the @mention by ifttt.
    content = content.replace(_PLACEHOLDER, '.')
    return HttpResponse(
        content=content,
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
    title = item.find('title')
    if title is None:
        print "Expected title element"
    else:
        name = creator.text.split()[0]
        if name.lower() in AUTHORS and name.lower() not in exclude:
            title.text += ' via %s@Politix%s' % (_PLACEHOLDER, name)
