# ansible-redis

 - Requires Ansible 1.4+
 - Tested on Ubuntu 12.04 (Precise)

## Configurables

``` yaml
## Installation and connection info
redis_version: 2.8.8
redis_bind: 0.0.0.0
redis_port: 6379
redis_install_dir: /opt/redis
redis_password: false

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
redis_timeout: 0
# Max connected clients at a time
redis_maxclients: 10000
# Redis memory limit (e.g. 4294967296, 4096mb, 4gb)
redis_maxmemory: false
redis_tcp_backlog: 511

# A list of commands to rename
redis_rename_commands:
  - CONFIG b840fc02d524045429941cc15f59e41cb7be6c52

redis_daemonize: "yes"
redis_pidfile: /var/run/redis_{{ redis_port }}.pid
redis_logfile: '""'
redis_loglevel: notice
# Enable syslog. "yes" or "no"
redis_syslog_enabled: "yes"
redis_syslog_ident: redis_{{ redis_port }}
# Syslog facility. Must be USER or LOCAL0-LOCAL7
redis_syslog_facility: USER
```
