# ansible-redis

[![Build Status](https://travis-ci.org/DavidWittman/ansible-redis.svg?branch=master)](https://travis-ci.org/DavidWittman/ansible-redis) [![Ansible Galaxy](https://img.shields.io/badge/galaxy-DavidWittman.redis-blue.svg?style=flat)](https://galaxy.ansible.com/davidwittman/redis)

 - Ansible 2.4+
 - Compatible with most versions of Ubuntu/Debian and RHEL/CentOS 6.x

## Contents

 1. [Installation](#installation)
 2. [Getting Started](#getting-started)
  1. [Single Redis node](#single-redis-node)
  2. [Master-Slave Replication](#master-slave-replication)
  3. [Redis Sentinel](#redis-sentinel)
 3. [Advanced Options](#advanced-options)
  1. [Verifying checksums](#verifying-checksums)
  2. [Install from local tarball](#install-from-local-tarball)
  3. [Building 32-bit binaries](#building-32-bit-binaries)
 4. [Role Variables](#role-variables)

## Installation

``` bash
$ ansible-galaxy install davidwittman.redis
```

## Getting started

Below are a few example playbooks and configurations for deploying a variety of Redis architectures.

This role expects to be run as root or as a user with sudo privileges.

### Single Redis node

Deploying a single Redis server node is pretty trivial; just add the role to your playbook and go. Here's an example which we'll make a little more exciting by setting the bind address to 127.0.0.1:

``` yml
---
- hosts: redis01.example.com
  vars:
    - redis_bind: 127.0.0.1
  roles:
    - davidwittman.redis
```

``` bash
$ ansible-playbook -i redis01.example.com, redis.yml
```

**Note:** You may have noticed above that I just passed a hostname in as the Ansible inventory file. This is an easy way to run Ansible without first having to create an inventory file, you just need to suffix the hostname with a comma so Ansible knows what to do with it.

That's it! You'll now have a Redis server listening on 127.0.0.1 on redis01.example.com. By default, the Redis binaries are installed under /opt/redis, though this can be overridden by setting the `redis_install_dir` variable.

### Master-Slave replication

Configuring [replication](http://redis.io/topics/replication) in Redis is accomplished by deploying multiple nodes, and setting the `redis_slaveof` variable on the slave nodes, just as you would in the redis.conf. In the example that follows, we'll deploy a Redis master with three slaves.

In this example, we're going to use groups to separate the master and slave nodes. Let's start with the inventory file:

``` ini
[redis-master]
redis-master.example.com

[redis-slave]
redis-slave0[1:3].example.com
```

And here's the playbook:

``` yml
---
- name: configure the master redis server
  hosts: redis-master
  roles:
    - davidwittman.redis

- name: configure redis slaves
  hosts: redis-slave
  vars:
    - redis_slaveof: redis-master.example.com 6379
  roles:
    - davidwittman.redis
```

In this case, I'm assuming you have DNS records set up for redis-master.example.com, but that's not always the case. You can pretty much go crazy with whatever you need this to be set to. In many cases, I tell Ansible to use the eth1 IP address for the master. Here's a more flexible value for the sake of posterity:

``` yml
redis_slaveof: "{{ hostvars['redis-master.example.com'].ansible_eth1.ipv4.address }} {{ redis_port }}"
```

Now you're cooking with gas! Running this playbook should have you ready to go with a Redis master and three slaves.

### Redis Sentinel

#### Introduction

Using Master-Slave replication is great for durability and distributing reads and writes, but not so much for high availability. If the master node fails, a slave must be manually promoted to master, and connections will need to be redirected to the new master. The solution for this problem is [Redis Sentinel](http://redis.io/topics/sentinel), a distributed system which uses Redis itself to communicate and handle automatic failover in a Redis cluster.

Sentinel itself uses the same redis-server binary that Redis uses, but runs with the `--sentinel` flag and with a different configuration file. All of this, of course, is abstracted with this Ansible role, but it's still good to know.

#### Configuration

To add a Sentinel node to an existing deployment, assign this same `redis` role to it, and set the variable `redis_sentinel` to True on that particular host. This can be done in any number of ways, and for the purposes of this example I'll extend on the inventory file used above in the Master/Slave configuration:

``` ini
[redis-master]
redis-master.example.com

[redis-slave]
redis-slave0[1:3].example.com

[redis-sentinel]
redis-sentinel0[1:3].example.com redis_sentinel=True
```

Above, we've added three more hosts in the **redis-sentinel** group (though this group serves no purpose within the role, it's merely an identifier), and set the `redis_sentinel` variable inline within the inventory file.

Now, all we need to do is set the `redis_sentinel_monitors` variable to define the Redis masters which Sentinel should monitor. In this case, I'm going to do this within the playbook:

``` yml
- name: configure the master redis server
  hosts: redis-master
  roles:
    - davidwittman.redis

- name: configure redis slaves
  hosts: redis-slave
  vars:
    - redis_slaveof: redis-master.example.com 6379
  roles:
    - davidwittman.redis

- name: configure redis sentinel nodes
  hosts: redis-sentinel
  vars:
    - redis_sentinel_monitors:
      - name: master01
        host: redis-master.example.com
        port: 6379
  roles:
    - davidwittman.redis
```

This will configure the Sentinel nodes to monitor the master we created above using the identifier `master01`. By default, Sentinel will use a quorum of 2, which means that at least 2 Sentinels must agree that a master is down in order for a failover to take place. This value can be overridden by setting the `quorum` key within your monitor definition. See the [Sentinel docs](http://redis.io/topics/sentinel) for more details.

Along with the variables listed above, Sentinel has a number of its own configurables just as Redis server does. These are prefixed with `redis_sentinel_`, and are enumerated in the **Role Variables** section below.

### Multiple role inclusions

Should you need to execute the role several times, have a look at `test/test_all.yml` to see how to proceed. See [here](https://github.com/DavidWittman/ansible-redis/issues/133) and [here](https://github.com/DavidWittman/ansible-redis/issues/193) for context.


## Advanced Options

### Verifying checksums

Set the `redis_verify_checksum` variable to true to use the checksum verification option for `get_url`. Note that this will only verify checksums when Redis is downloaded from a URL, not when one is provided in a tarball with `redis_tarball`.

When using Ansible 2.x, this role will verify the sha1 checksum of the download against checksums defined in the `redis_checksums` variable in `vars/main.yml`. If your version is not defined in here or you wish to override the checksum with one of your own, simply set the `redis_checksum` variable. As in the example below, you will need to prefix the checksum with the type of hash which you are using.

``` yaml
- name: install redis on ansible 1.x and verify checksums
  hosts: all
  roles:
    - role: davidwittman.redis
      redis_version: 3.0.7
      redis_verify_checksum: true
      redis_checksum: "sha256:b2a791c4ea3bb7268795c45c6321ea5abcc24457178373e6a6e3be6372737f23"
```

### Install from local tarball

If the environment your server resides in does not allow downloads (i.e. if the machine is sitting in a dmz) set the variable `redis_tarball` to the path of a locally downloaded Redis tarball to use instead of downloading over HTTP from redis.io.

Do not forget to set the version variable to the same version of the tarball to avoid confusion! For example:

```yml
vars:
  redis_version: 2.8.14
  redis_tarball: /path/to/redis-2.8.14.tar.gz
```

In this case the source archive is copied to the server over SSH rather than downloaded.

### Building 32 bit binaries

To build 32-bit binaries of Redis (which can be used for [memory optimization](https://redis.io/topics/memory-optimization)), set `redis_make_32bit: true`. This installs the necessary dependencies (x86 glibc) on RHEL/Debian/SuSE and sets the option '32bit' when running make.

### Building with TLS support

To build Redis with [TLS support](https://redis.io/topics/encryption) (Added in version `6`), set `redis_make_tls: true`. This requires OpenSSL development libraries (e.g. libssl-dev on Debian/Ubuntu).

## Role Variables

Here is a list of all the default variables for this role, which are also available in defaults/main.yml. One of these days I'll format these into a table or something.

``` yml
---
## Installation options
redis_version: 2.8.24
redis_install_dir: /opt/redis
redis_dir: /var/lib/redis/{{ redis_port }}
redis_config_file_name: "{{ redis_port }}.conf"
redis_download_url: "http://download.redis.io/releases/redis-{{ redis_version }}.tar.gz"
# Set this to true to validate redis tarball checksum against vars/main.yml
redis_verify_checksum: false
# Set this value to a local path of a tarball to use for installation instead of downloading
redis_tarball: false
# Set this to true to build 32-bit binaries of Redis
redis_make_32bit: false
# Set this to true to build redis with TLS support, available only for versions >= 6 (require OpenSSL development libraries)
redis_make_tls: false

redis_user: redis
redis_group: "{{ redis_user }}"

# The open file limit for Redis/Sentinel
redis_nofile_limit: 16384

## Role options
# Configure Redis as a service
# This creates the init scripts for Redis and ensures the process is running
# Also applies for Redis Sentinel
redis_as_service: true
# Add local facts to /etc/ansible/facts.d for Redis
redis_local_facts: true
# Service name
redis_service_name: "redis_{{ redis_port }}"

## Networking/connection options
redis_bind: false
redis_port: 6379
redis_password: false
# Slave replication options
redis_min_slaves_to_write: 0
redis_min_slaves_max_lag: 10
redis_tcp_backlog: 511
redis_tcp_keepalive: 0
# Max connected clients at a time
redis_maxclients: 10000
redis_timeout: 0
# Socket options
# Set socket_path to the desired path to the socket. E.g. /var/run/redis/{{ redis_port }}.sock
redis_socket_path: false
redis_socket_perm: 755

## Replication options
# Set slaveof just as you would in redis.conf. (e.g. "redis01 6379")
redis_slaveof: false
# Make slaves read-only. "yes" or "no"
redis_slave_read_only: "yes"
redis_slave_priority: 100
redis_repl_backlog_size: false

## Logging
redis_logfile: '""'
# Enable syslog. "yes" or "no"
redis_syslog_enabled: "yes"
redis_syslog_ident: "{{ redis_service_name }}"
# Syslog facility. Must be USER or LOCAL0-LOCAL7
redis_syslog_facility: USER

## General configuration
redis_daemonize: "yes"
redis_pidfile: /var/run/redis/{{ redis_port }}.pid
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
redis_db_filename: dump.rdb
# How frequently to snapshot the database to disk
# e.g. "900 1" => 900 seconds if at least 1 key changed
redis_save:
  - 900 1
  - 300 10
  - 60 10000
redis_stop_writes_on_bgsave_error: "yes"
redis_rdbcompression: "yes"
redis_rdbchecksum: "yes"
redis_appendonly: "no"
redis_appendfilename: "appendonly.aof"
redis_appendfsync: "everysec"
redis_no_appendfsync_on_rewrite: "no"
redis_auto_aof_rewrite_percentage: "100"
redis_auto_aof_rewrite_min_size: "64mb"
redis_notify_keyspace_events: '""'

## Additional configuration options
# leave empty if not required. Use a block style scalar to add options, e.g.
# redis_config_additional: |
#   io-threads 4
#   io-threads-do-reads yes
redis_config_additional: ""

## Redis sentinel configs
# Set this to true on a host to configure it as a Sentinel
redis_sentinel: false
redis_sentinel_dir: /var/lib/redis/sentinel_{{ redis_sentinel_port }}
redis_sentinel_bind: 0.0.0.0
redis_sentinel_port: 26379
redis_sentinel_password: false
redis_sentinel_pidfile: /var/run/redis/sentinel_{{ redis_sentinel_port }}.pid
redis_sentinel_logfile: '""'
redis_sentinel_syslog_ident: sentinel_{{ redis_sentinel_port }}
redis_sentinel_monitors:
  - name: master01
    host: localhost
    port: 6379
    quorum: 2
    auth_pass: ant1r3z
    down_after_milliseconds: 30000
    parallel_syncs: 1
    failover_timeout: 180000
    notification_script: false
    client_reconfig_script: false
    rename_commands: []
```

## Facts

The following facts are accessible in your inventory or tasks outside of this role.

- `{{ ansible_local.redis.bind }}`
- `{{ ansible_local.redis.port }}`
- `{{ ansible_local.redis.sentinel_bind }}`
- `{{ ansible_local.redis.sentinel_port }}`
- `{{ ansible_local.redis.sentinel_monitors }}`

To disable these facts, set `redis_local_facts` to a false value.
