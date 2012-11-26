import os
from subprocess import Popen, PIPE

from django.http import HttpResponse
from django.db import settings
from django.shortcuts import render_to_response


def stories(request):
    return render_to_response('stories.html', {})


def stories_data(request):
    "JSON story data"
    scraper = os.path.join(settings.SITE_DIRECTORY,
                           'politix/scraper/get_comments.js')
    node = os.path.join(settings.SITE_DIRECTORY,
                        'bin/node')
    scraper = Popen([node, scraper], stdin=PIPE, stdout=PIPE)
    scraper.stdin.close()
    return HttpResponse(scraper.stdout.read(),
                        mimetype='application/json')
