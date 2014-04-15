# ansible-redis

 - Requires Ansible 1.4+
 - Tested on Ubuntu 12.04 (Precise) and CentOS 6.5

## Installation

``` bash
$ ansible-galaxy install DavidWittman.redis
```

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
