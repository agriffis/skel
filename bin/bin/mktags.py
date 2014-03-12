#!/usr/bin/env python
#
# Make tags file in a python project

import re
import subprocess
import sys

paths = ['.']

# Look for a virtualenv path to append
for p in reversed(sys.path):
    match = re.search(r'^(.*/\.virtualenvs/[^/]*)/.*/site-packages$', p)
    if match:
        paths.append(p)
        paths.append(match.group(1) + '/src')
        break

# Generate tags for vim and TAGS for emacs
ctags_options = ['-R', '--python-kinds=-i', '--exclude=[._][!/]*/*', '--exclude=*.log']
subprocess.call(['ctags'] + ctags_options + paths)
#subprocess.call(['ctags', '-e'] + ctags_options + paths)
