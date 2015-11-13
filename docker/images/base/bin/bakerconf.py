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
    from docker import Client

    """Configures Baker Street for a vanilla Docker deployment"""

    # this is some nasty stuff; we're mounting the docker socket into the container to make this work then we're
    # grabbing a generated ID from the environment variables to lookup the container by name.
    #
    # With the container ID we can then lookup the exposed port on the host as well as the containers IP address.
    #
    # I don't like this at all! But it's going to work for now...
    docker_client = Client(base_url='unix://var/run/docker.sock')
    c_id = os.environ['container_name']
    c_info = docker_client.inspect_container(c_id)
    c_net = c_info['NetworkSettings']
    c_container_address = c_net['IPAddress']
    template_vars = {'routable_address': os.getenv("routable_address", c_container_address),
                     'mapped_port': os.environ['exposed_port'],
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