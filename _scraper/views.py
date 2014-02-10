import os
import json
import re
from datetime import datetime
from datetime import timedelta
from itertools import izip_longest
from subprocess import Popen, PIPE

from django.db import settings
from django.shortcuts import render_to_response
from django.contrib.auth.decorators import login_required

from models import Article


SHELF_LIFE = timedelta(days=5)


@login_required
def loading(request, sources):
    return render_to_response(
        'loading.html',
        {'sources': sources})


@login_required
def loading_politix(request):
    return render_to_response(
        'loading.html',
        {'sources': 'politix'})


@login_required
def scrapey(request, sources):
    return render_to_response(
        'loading.html',
        {'nofetch': True,
         'sources': sources})


def store_and_filter(data):
    now = datetime.now()
    for site in data:
        for category in data[site]:
            fresh = []
            for i, article in enumerate(data[site][category]):
                article['text'] = clean(article['text'])
                if not article['text']:
                    data[site][category].pop(i)
                    continue
                _article, created = (
                    Article.objects
                    .get_or_create(site=site, title=article['text']))
                if created:
                    _article.pub_date = now
                    _article.save()
                    fresh.append(article)
                article['age'] = (now - _article.pub_date).total_seconds()

    return data


TITLE_REGEXP = re.compile('(^[0-9][.:][ \n\t]?)?[ \n\t]*([^\n\t]*)')


def clean(text):
    match = TITLE_REGEXP.match(text)
    if match:
        return match.groups()[1]
    else:
        return text


@login_required
def scraper(request, sources):

    # Some housekeeping that should be done outside the request-response cycle
    (Article.objects
     .filter(pub_date__lt=datetime.now() - timedelta(days=7))
     .delete())

    def reshape(data):
        return {
            'columns': data.keys(),
            'rows': izip_longest(*data.values(), fillvalue='')
        }

    t0 = datetime.now()
    print 'Fetching articles'
    data = get_scrape_data(sources)
    print 'Got articles from %d sources in %.1fs' % (
        len(data),
        (datetime.now() - t0).total_seconds(),
    )

    data = store_and_filter(data)

    data = sorted(
        ((site.lstrip('_'), reshape(site_data))
         for site, site_data in data.iteritems()),
        key=lambda (site, site_data): (
            ('zzz' + site) if site.startswith('_') else site))

    return render_to_response(
        'scraper.html',
        {'data': data})


def get_scrape_data(sources):
    scrape = os.path.join(settings.SITE_DIRECTORY,
                          'js/scrape.js')

    node = os.path.join(settings.SITE_DIRECTORY,
                        'bin/node')

    assert sources in {'social', 'politix', 'offbeat'}

    scraper = Popen([node, scrape, sources], stdin=PIPE, stdout=PIPE)
    scraper.stdin.close()

    data = scraper.stdout.read()
    return json.loads(data)
