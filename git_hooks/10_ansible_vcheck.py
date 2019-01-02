#!/usr/bin/env python

import sys
import os
import re
import subprocess

def git(args, **kwargs):
    environ = os.environ.copy()
    if 'repo' in kwargs:
        environ['GIT_DIR'] = kwargs['repo']
    if 'work' in kwargs:
        environ['GIT_WORK_TREE'] = kwargs['work']
    proc = subprocess.Popen(args, stdout=subprocess.PIPE, env=environ)
    return proc.communicate()

def get_changed_files(base, commit, **kw):
    (results, code) = git(('git', 'diff', '--numstat', '--name-only', "%s..%s" % (base, commit)), **kw)
    return results.strip().split('\n')

def get_new_file(filename, commit):
    (results, code) = git(('git', 'show', '%s:%s' % (commit, filename)))
    return results

repo = os.getcwd()
basedir = os.path.join(repo, "..")

line = sys.stdin.read()
(base, commit, ref) = line.strip().split()
modified = get_changed_files(base, commit)

pattern = '.*vault.*\.*$|group_vars/production\.yml|group_vars/staging\.yml|do_env\.sh'
required = 'ANSIBLE_VAULT'
unencrypted_files = []

for fname in modified:
    if not re.search(pattern, fname):
        continue

    if required not in get_new_file(fname, commit):
        unencrypted_files.append(fname)

out = lambda s: sys.stdout.write(s + '\r\n')
wipe="\033[1m\033[0m"
yellow='\033[1;33m'
exit_code = 0
if unencrypted_files:
   exit_code = 1
   out('# COMMIT REJECTED')
   out('# Looks like unencrypted ansible-vault files are part of the commit:')
   out('#')
   for i in unencrypted_files:
       out('#\t{}unencrypted:  {}{}'.format(yellow, i, wipe))

   out("# Please encrypt them with 'ansible-vault encrypt <file>'")

sys.exit(exit_code)
