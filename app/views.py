import os
import json
from datetime import datetime
from datetime import timedelta
from itertools import izip_longest
from subprocess import Popen, PIPE

from django.db import settings
from django.shortcuts import render_to_response

from models import Article


SHELF_LIFE = timedelta(days=5)


def loading(request):
    return render_to_response(
        'loading.html',
        {})


def flying(request):
    return render_to_response(
        'loading.html',
        {'nofetch': True})


def store_and_filter(data):
    now = datetime.now()
    stale = []
    for site in data:
        for category in data[site]:
            fresh = []
            for article in data[site][category]:
                _article, created = (
                    Article.objects
                    .get_or_create(site=site, title=article['text']))
                if created:
                    _article.pub_date = now
                    _article.save()
                    fresh.append(article)
                article['age'] = (now - _article.pub_date).total_seconds()

    return data


def scrapey(request):
    def reshape(data):
        return {
            'columns': data.keys(),
            'rows': izip_longest(*data.values(), fillvalue='')
        }

    data = get_scrape_data()

    data = store_and_filter(data)

    data = sorted((site, reshape(site_data))
                  for site, site_data in data.iteritems())

    return render_to_response(
        'scrapey.html',
        {'data': data})


def get_scrape_data():
    scraper = os.path.join(settings.SITE_DIRECTORY,
                          'js/scraper.coffee')

    scraper = Popen(['coffee', scraper], stdin=PIPE, stdout=PIPE)
    scraper.stdin.close()

    data = scraper.stdout.read()
    try:
        return json.loads(data)
    except:
        raise Exception('Error: received\n%s' % data)
