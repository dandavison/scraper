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


#@login_required
def loading(request):
    return render_to_response(
        'loading.html',
        {})


#@login_required
def scrapey(request):
    return render_to_response(
        'loading.html',
        {'nofetch': True})


def store_and_filter(data):
    now = datetime.now()
    stale = []
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


# @login_required
def scraper(request):
    def reshape(data):
        return {
            'columns': data.keys(),
            'rows': izip_longest(*data.values(), fillvalue='')
        }

    data = get_scrape_data()

    data = store_and_filter(data)

    data = sorted((site, reshape(site_data))
                  for site, site_data in data.iteritems())

    html = render_to_response(
        'scraper.html',
        {'data': data})

    with open('/tmp/scraper.html', 'w') as fp:
        fp.write(str(html))

    return html


def get_scrape_data():
    scrape = os.path.join(settings.SITE_DIRECTORY,
                          'js/scrape.js')

    scraper = Popen(["node", scrape], stdin=PIPE, stdout=PIPE)
    scraper.stdin.close()

    data = scraper.stdout.read()
    try:
        return json.loads(data)
    except:
        raise Exception('Error: received\n%s' % data)
