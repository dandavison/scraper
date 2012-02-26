import os
import json
from itertools import izip_longest
from subprocess import Popen, PIPE

from django.db import settings
from django.shortcuts import render_to_response


def scraper(request):
    def reshape(data):
        return {
            'columns': data.keys(),
            'rows': izip_longest(*data.values(), fillvalue='')
        }

    data = get_scrape_data()
    data = sorted(zip(data.keys(),
                      map(reshape, data.values())))

    return render_to_response(
        'scraper.html',
        {'data': data})


def get_scrape_data():
    scrape = os.path.join(settings.SITE_DIRECTORY,
                          'js/scrape.coffee')

    scraper = Popen(['coffee', scrape], stdin=PIPE, stdout=PIPE)
    scraper.stdin.close()

    return json.loads(scraper.stdout.read())
