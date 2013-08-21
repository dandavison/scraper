import requests

from django.http import HttpResponse


def politix_homepage(request):
    url = 'http://politix.topix.com/rssfeeds/homepage'
    resp = requests.get(url)
    resp.raise_for_status()
    feed = resp.content
    return HttpResponse(content=feed, content_type='text/xml', status=200)
