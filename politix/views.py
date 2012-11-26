from subprocess import Popen, PIPE
from datetime import datetime
from datetime import timedelta
import os
import json

from django.http import HttpResponse
from django.db import settings
from django.shortcuts import render_to_response



class Logger(object):

    def debug(self, msg):
        print msg


logger = Logger()



def stories(request):
    return render_to_response('stories.html', {})


def stories_data(request):
    "JSON story data"
    scraper = os.path.join(settings.SITE_DIRECTORY,
                           'politix/scraper/get_comments.js')

    scraper = Popen(["node", scraper], stdin=PIPE, stdout=PIPE)
    scraper.stdin.close()
    data = json.loads(scraper.stdout.read())
    data = clean(data)
    return HttpResponse(json.dumps(data), mimetype='application/json')


def clean(data):
    for d in data:
        d['timestamp'] = _clean_timestamp(d['timestamp'])
        d['comments'] = _clean_comments(d['comments'])
    return data


def _clean_comments(comments):
    count, string = comments.strip().split()
    if string != "comments":
        raise ValueError("Can't parse comments: '%s'" % comments)
    return int(count)


def _clean_timestamp(timestamp):
    months = ['Jan', 'Feb', 'Mar',
              'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep',
              'Oct', 'Nov', 'Dec']
    days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']

    timestamp = timestamp.strip()

    now = datetime.now()
    this_year = now.strftime('%Y')
    one_day = timedelta(days=1)

    try:
        # E.g. "Sat "
        # A bare day: return most recent matching day
        day = next(day for day in days if timestamp.startswith(day))
        time = now
        count = 0
        while time.strftime('%a') != day:
            time = time - one_day
            count += 1
            if count == 7:
                raise ValueError("Can't parse timestamp: '%s'" % timestamp)
        timestamp_type = "Bare day"
    except StopIteration:
        try:
            # E.g. "Nov 13 "
            month = next(month for month in months
                         if timestamp.startswith(month))
            day = int(timestamp.replace(month, '').strip())
            date_string = '%d-%s-%s' % (day, month, this_year)
            time = datetime.strptime(date_string, '%d-%b-%Y')
            timestamp_type = 'Month day'
        except StopIteration:
            try:
                # E.g. "14 hr "
                quantity, unit = timestamp.split()
                if unit != "hr":
                    raise ValueError("Can't parse timestamp: '%s'" % timestamp)
                time = now - timedelta(hours=int(quantity))
                timestamp_type = 'hours'
            except:
                raise

    logger.debug("%s:     %s:     %s" % (
        timestamp,
        time.strftime('%a %d-%b-%Y: %H:%m'),
        timestamp_type))

    return int(time.strftime('%s')) * 1000
