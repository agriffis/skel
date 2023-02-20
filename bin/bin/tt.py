#!/usr/bin/env python2

from __future__ import absolute_import, unicode_literals

import datetime
import itertools
import os.path
import sys

actions = itertools.cycle(['START', 'STOP'])
prev = datetime.datetime.fromtimestamp(0)
days = {}
tt_txt = os.path.expanduser('~/Dropbox/tt-{}.txt'.format(sys.argv[1]))

def punch(stamp, activity=''):
    date = prev.date()
    key = (date, activity)
    days.setdefault(key, datetime.timedelta(0))
    days[key] += stamp - prev

with open(tt_txt) as tt:
    for expected, line in itertools.izip(actions, tt):
        action, stamp = line.strip().split(' ', 1)
        assert action == expected
        stamp, activity = (stamp.split(' ', 1) if ' ' in stamp
                           else (stamp, ''))
        stamp = datetime.datetime.strptime(stamp, '%Y%m%d-%H%M%S')
        assert stamp > prev, stamp

        if action == 'STOP':
            punch(stamp, activity)

        prev = stamp

    # Handle a trailing START
    if expected == 'START':
        punch(datetime.datetime.now())

prev = week_total = None
total = datetime.timedelta(0)

def delta_hours(d):
    return 1.0 * d.total_seconds() / 3600

def print_total(t, label):
    if t:
        print "\n{} hours: {:.02f}\n".format(label, delta_hours(t))

for (date, activity), delta in sorted(days.items()):
    week = date.strftime('%U')

    if week != prev:
        print_total(week_total, "Week total")
        week_total = datetime.timedelta(0)
        prev = week

    print "{}: {:.02f} {}".format(date, delta_hours(delta), activity)

    week_total += delta
    total += delta

print_total(week_total, "Week total")
print_total(total, "Overall total")
