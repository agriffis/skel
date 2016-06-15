#!/usr/bin/env python2

from __future__ import absolute_import, unicode_literals

import datetime
import itertools
import sys

actions = itertools.cycle(['START', 'STOP'])
prev = datetime.datetime.fromtimestamp(0)
days = {}

def punch(stamp):
    date = prev.date()
    days.setdefault(date, datetime.timedelta(0))
    days[date] += stamp - prev

with open('/home/aron/Dropbox/tt.txt') as tt:
    for expected, line in itertools.izip(actions, tt):
        action, stamp = line.strip().split()
        assert action == expected
        stamp = datetime.datetime.strptime(stamp, '%Y%m%d-%H%M%S')
        assert stamp > prev, stamp

        if action == 'STOP':
            punch(stamp)

        prev = stamp

    # Handle a trailing START
    if expected == 'START':
        punch(datetime.datetime.now())

prev = total = None

def delta_hours(d):
    return 1.0 * d.total_seconds() / 3600

def print_total(total):
    if total:
        print "\nWeek total hours: {:.02f}\n".format(
            delta_hours(total))

for date, delta in sorted(days.items()):
    week = date.strftime('%U')

    if week != prev:
        print_total(total)
        total = datetime.timedelta(0)
        prev = week

    print "{}: {:.02f}".format(date, delta_hours(delta))

    total += delta

print_total(total)
