#!/usr/bin/env python

"""mw.py

Container tracker for MicroWizard.

Usage:
  mw add <tag> <container>
  mw remove <tag>
  mw generate-name
  mw -h | --help
  mw --version

Options:
  -h --help     Show this screen.
  --version     Show version.
"""

import errno
import json
import os
import random
import string
import time

from docopt import docopt

def add_container(args, state):
    tag = args['<tag>']
    container = args['<container>']

    if tag not in state['containers']:
        state['containers'][tag] = []

    state['containers'][tag].append(container)

def remove_container(args, state):
    tag = args['<tag>']

    if tag not in state['containers']:
        return

    state['containers'][tag].pop()

def initialize_state(path):
    state = {"index": 0, "container": {}}
    write_state(state, path)

def load_state(path='/etc/datawire/mw_containers.json'):
    result = {}

    if not os.path.isfile(path):
        initialize_state(path)

    with open(path, "r") as state:
        result = json.load(state)

    return result

def write_state(state, path='/etc/datawire/mw_containers.json'):
    ensure_path_exists(os.path.dirname(path))
    with open(path, "w+") as f:
        json.dump(state, f, sort_keys=True, indent=4, ensure_ascii=False)

def ensure_path_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

def generate_name():
    return "{}_{}".format(int(time.time()), id_generator())

def id_generator(size=6, chars=string.ascii_lowercase):
    return ''.join(random.choice(chars) for _ in range(size))

def mwc(args):
    state = load_state()

    if args['add']:
        add_container(args, state)
        write_state(state)

    if args['remove']:
        remove_container(args, state)
        write_state(state)

    if args['generate-name']:
        print generate_name()

def main():
    mwc(docopt(__doc__))

if __name__ == "__main__":
    main()
