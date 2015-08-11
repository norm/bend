#!/usr/bin/env python

from optparse import OptionParser
import os
import subprocess
import yaml


hostname = os.uname()[1]
default_host = hostname.split('.')[0]
default_user = os.getenv('USER')
default_dir = '%s/etc/battleschool' % os.getenv('HOME')

parser = OptionParser()
parser.add_option(
    '--user',
    dest = 'user',
    help = 'override the default username',
)
parser.add_option(
    '--host',
    dest = 'host',
    help = 'override the default hostname',
)
parser.add_option(
    '--dir',
    dest = 'dir',
    help = 'look for configuration in DIR',
)
(options, args) = parser.parse_args()

if len(args) > 0:
    default_host = args[0]
elif options.host:
    default_host = options.host
if len(args) > 1:
    default_user = args[1]
elif options.user:
    default_user = options.user
if options.dir:
    default_dir = options.dir

USERNAME=os.getenv('BEND_USER', default_user)
HOSTNAME=os.getenv('BEND_HOST', default_host)
BATTLEDIR=default_dir

user_yaml = '%s/user/%s.yml' % (BATTLEDIR, USERNAME)
user_vars = '%s/user/%s.vars.yml' % (BATTLEDIR, USERNAME)
host_yaml = '%s/host/%s.yml' % (BATTLEDIR, HOSTNAME)
host_vars = '%s/host/%s.vars.yml' % (BATTLEDIR, HOSTNAME)
common_yaml = '%s/common.yml' % BATTLEDIR
common_vars = '%s/common.vars.yml' % BATTLEDIR
destination = '%s/config.yml' % BATTLEDIR


def create_config():
    repos = {}
    config = {
        'cache_dir': '~/var/battleschool',
        'sources': {
            'urls': [],
            'local': [],
            'git': [],
        },
    }

    for filename in [common_yaml, host_yaml, user_yaml]:
        if os.path.isfile(filename):
            with open(filename) as file:
                conf = yaml.load(file)
                if conf is None:
                    continue

                if 'playbooks' in conf:
                    config['sources']['local'].extend(conf['playbooks'])
                if 'urls' in conf:
                    for url in conf['urls']:
                        config['sources']['urls'].append({
                            'name': url,
                            'url': url,
                        })
                if 'repos' in conf:
                    for repo in conf['repos']:
                        url = repo['url']
                        if url not in repos:
                            repos[url] = []
                        repos[url].extend(repo['playbooks'])

    for repo in repos:
        config['sources']['git'].extend([{
            'name': repo,
            'repo': repo,
            'playbooks': repos[repo],
        }])

    for key in ['urls', 'git', 'local']:
        if len(config['sources'][key]) == 0:
            del config['sources'][key]

    with open(destination, 'w') as file:
        file.write(yaml.dump(config, default_flow_style=False))


def run_battleschool():
    args = [
        'battle',
        '--config-dir', BATTLEDIR,
        '-K',
    ]

    # add any existing vars files
    for filename in [common_vars, host_vars, user_vars]:
        if os.path.isfile(filename):
            args.extend(['-e', '@%s' % filename])

    subprocess.call(args)


create_config()
run_battleschool()
