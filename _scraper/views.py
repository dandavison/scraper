import os
import json
from itertools import izip_longest
from subprocess import Popen, PIPE

from django.db import settings
from django.shortcuts import render_to_response


def loading(request):
    return render_to_response(
        'loading.html',
        {})


def scrapey(request):
    return render_to_response(
        'loading.html',
        {'nofetch': True})


def scraper(request):
    def reshape(data):
        return {
            'columns': data.keys(),
            'rows': izip_longest(*data.values(), fillvalue='')
        }

    data = get_scrape_data()
    data = sorted((site, reshape(site_data))
                  for site, site_data in data.iteritems())

    return render_to_response(
        'scraper.html',
        {'data': data})


def get_scrape_data():
    scrape = os.path.join(settings.SITE_DIRECTORY,
                          'js/scrape.coffee')

    scraper = Popen(['coffee', scrape], stdin=PIPE, stdout=PIPE)
    scraper.stdin.close()

    data = scraper.stdout.read()
    try:
        return json.loads(data)
    except:
        raise Exception('Error: received\n%s' % data)
