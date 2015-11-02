#!/usr/bin/env python

"""bakerconf

A tool for configuring bakerstreet when running and starting on a container engine.

Usage:
  bakerconf (docker)

Options:
  -h | --help   Show this screen.
"""

import os

from docopt import docopt

datawire_config_file = '/etc/datawire/datawire.conf'

def configure_for_docker(**kwargs):

    """Configures Baker Street for a vanilla Docker deployment"""

    template_vars = {'routable_address': os.environ['dockerhost'],
                     'mapped_port': os.environ['mapped_port'],
                     'dw_directory_host': os.environ['DIRECTORY_PORT_5672_TCP_ADDR']}

    content = render(template=datawire_config_file, template_vars=template_vars)
    with open(datawire_config_file, 'w+') as config:
        config.write(content)

def configure_for_kubernetes():

    """Configures Baker Street for a Kubernetes deployment"""

    # should just be a matter of invoking configure_for_docker(routable_address=<container_ip>)
    pass

def configure_for_ecs():

    """Configures Baker Street for an Amazon ECS deployment"""
    pass

def configure_for_mesos():

    """Configures Baker Street for an Apache Mesos deployment"""
    pass

def render(**kwargs):
    from string import Template
    with open(kwargs['template']) as f:
        template = Template(f.read())
        return template.substitute(kwargs['template_vars'])

def resolve(**kwargs):
    for host in open(kwargs['hosts_file'], 'r'):
        parts = host.split()
        if parts[1] == kwargs['hostname']:
            return parts[0]

    raise ValueError('IP for hostname not found (src: {}, hostname: {})'.format(kwargs['hosts_file'],
                                                                                kwargs['hostname']))
def discover_engine():
    {
        'docker': configure_for_docker,
        'kubernetes': configure_for_kubernetes,
        'ecs': configure_for_ecs,
        'mesos': configure_for_mesos
    }[os.environ['CONTAINER_ENGINE'].lower()]()

def configure(args):
    if args['docker']:
        configure_for_docker()

def main():
    configure(docopt(__doc__))

if __name__ == "__main__":
    main()