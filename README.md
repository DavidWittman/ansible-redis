# ansible-redis

 - Requires Ansible 1.4+
 - Tested on Ubuntu 12.04 (Precise) and CentOS 6.5

## Installation

``` bash
$ ansible-galaxy install DavidWittman.redis
```

## Getting started

### Single Redis node

Deploying a single Redis server node is pretty trivial; just add the role to your playbook and go. Here's an example which we'll make a little more exciting by setting the bind address to 127.0.0.1:

``` yaml
---
- hosts: redis01.example.com
  vars:
    - redis_bind: 127.0.0.1
  roles:
    - redis
```

``` bash
$ ansible-playbook -i redis01.example.com, redis.yml
```

**Note:** You may have noticed above that I just passed a hostname in as the ansible inventory file. This is an easy way to run ansible without first having to create an inventory file, you just need to suffix the hostname with a comma so ansible knows what to do with it.

That's it! You'll now have a Redis server listening on 127.0.0.1 on redis01.example.com.

### Master-Slave replication

Configuring [replication](http://redis.io/topics/replication) in Redis is accomplished by deploying multiple nodes, and setting `{{ redis_slaveof }}` on the slave nodes, just as you would in the redis.conf. In the example that follows, we'll deploy a Redis master with 3 slaves.

In this example, we're going to use groups to separate the master and slave nodes. Let's start with the inventory file:

```
[redis-master]
redis-master.example.com

[redis-slave]
redis-slave0[1:3].example.com
```

And here's the playbook:

``` yaml
---
- name: configure the master redis server
  hosts: redis-master
  roles:
    - redis

- name: configure redis slaves
  hosts: redis-slave
  vars:
    - redis_slaveof: redis-master.example.com 6379
  roles:
    - redis
```

In this case, I'm assuming you have DNS records set up for redis-master.example.com, but that's not always the case. You can pretty much go crazy with whatever you need this to be set to. In many cases, I tell Ansible to use the eth1 IP address for the master. Here's a more flexible value for the sake of posterity:

``` yaml
redis_slaveof: "{{ hostvars['redis-master.example.com'].ansible_eth1.ipv4.address }} 6379"
```

### Redis Sentinel

## Configurables

``` yaml
---
## Installation options
redis_version: 2.8.8
redis_install_dir: /opt/redis

## Networking/connection options
redis_bind: 0.0.0.0
redis_port: 6379
redis_password: false
redis_tcp_backlog: 511
redis_tcp_keepalive: 0
# Max connected clients at a time
redis_maxclients: 10000
redis_timeout: 0

## Replication options
# Set slaveof just as you would in redis.conf. (e.g. "redis01 6379")
redis_slaveof: false
# Make slaves read-only. "yes" or "no"
redis_slave_read_only: "yes"
redis_slave_priority: 100
redis_repl_backlog_size: false

## General configuration
# Number of databases to allow
redis_databases: 16
redis_loglevel: notice
# Log queries slower than this many milliseconds. -1 to disable
redis_slowlog_log_slower_than: 10000
# Maximum number of slow queries to save
redis_slowlog_max_len: 128
# Redis memory limit (e.g. 4294967296, 4096mb, 4gb)
redis_maxmemory: false
redis_maxmemory_policy: noeviction
redis_rename_commands: []
# How frequently to snapshot the database to disk
# e.g. "900 1" => 900 seconds if at least 1 key changed
redis_save:
  - 900 1
  - 300 10
  - 60 10000

redis_daemonize: "yes"
redis_pidfile: /var/run/redis_{{ redis_port }}.pid
redis_logfile: '""'
redis_sentinel_logfile: '""'
# Enable syslog. "yes" or "no"
redis_syslog_enabled: "yes"
redis_syslog_ident: redis_{{ redis_port }}
# Syslog facility. Must be USER or LOCAL0-LOCAL7
redis_syslog_facility: USER
```
