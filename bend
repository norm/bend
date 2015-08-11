#!/usr/bin/env python

import os
import subprocess
import yaml


USERNAME='norm'
HOSTNAME='sinister'
BATTLEDIR='%s/etc/battleschool' % os.getenv('HOME')

user_yaml = 'user/%s.yml' % USERNAME
user_vars = 'user/%s.vars.yml' % USERNAME
host_yaml = 'host/%s.yml' % HOSTNAME
host_vars = 'host/%s.vars.yml' % HOSTNAME
common_yaml = 'common.yml'
common_vars = 'common.vars.yml'


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

    with open('config.yml', 'w') as file:
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
