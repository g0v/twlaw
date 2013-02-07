#!/usr/bin/env python
# -*- coding: utf-8 -*-

import codecs
import json
import os
import os.path
import sys

if len(sys.argv) != 3:
    print "Usage: ./json2git.py law.json path/to/git/repo"
    sys.exit(-1)

law = json.load(file(sys.argv[1]))

paths = os.path.dirname(sys.argv[1]).split('/')
cat = paths[-2]
law_name = paths[-1]
output = '%s/%s.md' % (cat, law_name)
print 'Generating', output

os.chdir(sys.argv[2])
if not os.path.exists(cat):
    os.makedirs(cat)
#os.system('git init')


def system_or_cry(cmd):
    if os.system(cmd) != 0:
        print "ERROR:", cmd

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

    system_or_cry('git add %s' % output)

    date = rev['date']
    if int(date[:date.index('.')]) < 1970:
        date = '1970.1.1'

    detail = ''
    if 'reference' in rev and len(rev['reference']) > 0:
        refs = rev['reference']
        detail = u'委員會: %s\n\n' % refs[0]['committee']
        for ref in refs:
            detail += "%s: %s (%s)\n" % (ref['progress'], ref['desc'], ref['link'])
            if 'misc' in ref:
                detail += "  ref: %s %s" % (ref['misc']['content'], ref['misc']['link'])

    msg = "%s %s" % (law_name, rev['date'].encode('utf-8'))
    if detail:
        msg += '\n\n' + detail.encode('utf-8')
    system_or_cry('git commit --date "%sT23:00:00" -m "%s"' % (date.encode('utf-8'), msg))
