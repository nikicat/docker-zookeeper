#!/usr/bin/env python

# Copyright (C) 2013 SignalFuse, Inc.

# Start script for the ZooKeeper service.
# Because of the nature of the bootstrapping of the ZooKeeper cluster, we make
# use of some "internal" Maestro guest helper functions here.

import os
import subprocess
import logging

from maestro.guestutils import *

logging.basicConfig(level=logging.INFO)

os.chdir(os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    '..'))

ZOOKEEPER_DATA_DIR = '/var/lib/zookeeper'
ZOOKEEPER_NODE_ID = None

# First, gather ZooKeeper nodes from the environment.
ZOOKEEPER_NODE_LIST = get_node_list(get_service_name(),
                                    ports=['peer', 'leader_election'])

# Build a representation of ourselves, to match against the node list.
myselfports = '{}:{}'.format(
        get_specific_port(get_service_name(), get_container_name(), 'peer'),
        get_specific_port(get_service_name(), get_container_name(), 'leader_election'))

myself = '{}:{}'.format(
        get_specific_host(get_service_name(), get_container_name()), myselfports)

# Build the ZooKeeper node configuration.
conf = {
    'tickTime': 2000,
    'initLimit': 10,
    'syncLimit': 5,
    'dataDir': ZOOKEEPER_DATA_DIR,
    'clientPort': get_port('client', 2181),
    'autopurge.purgeInterval': os.getenv('ZOOKEEPER_PURGE_INTERVAL', 1),
}

# Add the ZooKeeper node list with peer and leader election ports.
for id, node in enumerate(ZOOKEEPER_NODE_LIST, 1):
    # Make a note of our node ID if we find ourselves in the list.
    if node == myself:
        ZOOKEEPER_NODE_ID = id
        # workaround for https://issues.apache.org/jira/browse/ZOOKEEPER-1711
        node = '0.0.0.0:{}'.format(myselfports)
    conf['server.{}'.format(id)] = node

# Write out the ZooKeeper configuration file.
with open(os.path.join('conf', 'zoo.cfg'), 'w+') as f:
    for entry in conf.iteritems():
        f.write("%s=%s\n" % entry)

# Write out the 'myid' file in the data directory if we found ourselves in the
# node list.
if ZOOKEEPER_NODE_ID:
    if not os.path.exists(ZOOKEEPER_DATA_DIR):
        os.makedirs(ZOOKEEPER_DATA_DIR, mode=0750)
    with open(os.path.join(ZOOKEEPER_DATA_DIR, 'myid'), 'w+') as f:
        f.write('%s\n' % ZOOKEEPER_NODE_ID)
    logging.info('Starting {}, node {} of a {}-node ZooKeeper cluster...'.format(
            get_container_name(),
            ZOOKEEPER_NODE_ID,
            len(ZOOKEEPER_NODE_LIST)))
else:
    logging.info('Starting {} as a single-node ZooKeeper cluster...'.format(
            get_container_name()))

os.environ['JVMFLAGS'] = ' '.join([
    '-server',
    '-showversion',
    '-javaagent:lib/jmxagent.jar',
    '-Dsf.jmxagent.port={}'.format(get_port('jmx', -1)),
    '-Djava.rmi.server.hostname={}'.format(get_container_host_address()),
    '-Dvisualvm.display.name="{}/{}"'.format(get_environment_name(), get_container_name()),
    os.environ.get('JVM_OPTS', ''),
])

# Start ZooKeeper
subprocess.call(['bin/zkServer.sh', 'start-foreground'])
