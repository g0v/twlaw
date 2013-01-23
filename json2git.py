#!/usr/bin/env python
# -*- coding: utf-8 -*-

import codecs
import json
import os
import sys

law = json.load(file(sys.argv[1]))

os.chdir(sys.argv[2])
#os.system('git init')

output = 'law.md'

content = None
for rev in law['revision']:
    if content is None:
        content = rev['content']
    else:
        for index, obj in rev['content'].iteritems():
            content[index] = obj

    with codecs.open(output, 'w', 'utf-8') as out:
        keylist = content.keys()
        keylist.sort(key=float)
        for index in keylist:
            print >>out, u"* %s %s\n" % (content[index]['num'], content[index]['article'])
            if 'reason' in content[index]:
                print >>out, u"> 釋：%s\n" % (content[index]['reason'])

    os.system('git add %s' % output)

    date = rev['date']
    if int(date[:date.index('.')]) < 1970:
        date = '1970.1.1'
    # FIXME The date on github is one day earlier?
    os.system('git commit --date "%sT23:00:00" -m "%s"' % (date, rev['date']))
