#!/usr/bin/env python2
#
# Make tags file in a python project

import os
import re
import subprocess
import sys
import tempfile

paths = [os.getcwd()]
exclude_globs = ['.?*', '_[^_]*', '*.log']

# Look for a virtualenv path to append.
for path in reversed(sys.path):
    match = re.search(r'^(.*/\.virtualenvs/[^/]*)/.*/site-packages$', path)
    if match:
        paths.append(path)
        paths.append(match.group(1) + '/src')
        break

# Find the glob list that ctags includes by default.
include_globs = []
output = subprocess.check_output(['ctags', '--list-maps'])
for line in output.split('\n'):
    if line:
        include_globs.extend(line.split()[1:])

# Remove the existing tags files.
for t in ['tags', 'TAGS']:
    if os.path.lexists(t):
        os.unlink(t)

# Build up the tags files.
for path in paths:
    # grep --exclude-dir=.* will exclude everything in the virtualenv, just
    # because the target path has .virtualenvs in it. This seems like a bug in
    # grep. We can work around it with chdir.
    cwd = os.getcwd()
    os.chdir(path)

    # Find any files with very long lines to exclude.
    grep_cmd = ['grep', '-rlEe', '^.{1000}', '.']
    grep_cmd.extend('--include=' + x for x in include_globs)
    grep_cmd.extend('--exclude=' + x for x in exclude_globs)
    grep_cmd.extend('--exclude-dir=' + x for x in exclude_globs)
    try:
        output = subprocess.check_output(grep_cmd)
    except subprocess.CalledProcessError as e:
        output = e.output
    exclude_files = filter(None, output.split('\n'))
    exclude_files = [path + x[1:] for x in exclude_files]

    # Revert chdir to write tags files.
    os.chdir(cwd)

    # Append tags for vim and TAGS for emacs.
    ctags_options = ['--append', '--recurse', '--python-kinds=-i']
    ctags_options.extend('--exclude=' + x for x in exclude_globs)
    ctags_options.extend('--exclude=' + x for x in exclude_files)
    subprocess.call(['ctags'] + ctags_options + [path])
    subprocess.call(['ctags', '-e'] + ctags_options + [path])
