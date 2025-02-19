#!/usr/bin/env python3
# encoding=UTF-8

# Copyright © 2024 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

import os
import pathlib
import re
import shlex
import subprocess
import sys
import unittest

async def _(): f'{await "# Python >= 3.7 is required #"}'

tc = unittest.TestCase('__hash__')
tc.maxDiff = None
assert_equal = tc.assertEqual

var = 'ZGLAB_NETWORK_TESTING'
if os.environ.get(var, '') != '1':
    print(f'1..0 # SKIP set {var}=1 to opt in to network testing')
    sys.exit()
print('1..1')
basedir = pathlib.Path(__file__).parent.parent
with open(f'{basedir}/README', 'rt', encoding='UTF-8') as file:
    readme = file.read()
match = re.search(r'^   [$] zglab (https://.*)\n((?:(?:   .*)?\n)+)', readme, flags=re.MULTILINE)
if not match:
    raise RuntimeError('cannot parse README')
(args, xout) = match.groups()
xout = re.sub('^   ', '', xout, flags=re.MULTILINE)
xout = xout.rstrip('\n') + '\n'
match = re.fullmatch('([^\u22EE]+\n)\u22EE\n([^\u22EE]+)', xout)
if not match:
    raise RuntimeError('cannot parse README')
(xhead, xtail) = match.groups()
prog = f'{basedir}/zglab'
cmdline = [prog, *shlex.split(args)]
proc = subprocess.run(cmdline, text=True, capture_output=True)
for line in proc.stdout.splitlines():
    print('#', line)
assert_equal(proc.stderr, '')
assert_equal(proc.returncode, 0)
out = proc.stdout
out = re.sub(r' +$', '', out, flags=re.MULTILINE)
assert_equal(xhead, out[:len(xhead)])
assert_equal(xtail, out[-len(xtail):])
print('ok 1')

# vim:ts=4 sts=4 sw=4 et ft=python
