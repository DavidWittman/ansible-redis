import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')

def test_dir(host):
    dirs = [
        "/etc/redis",
        "/var/run/redis",
        "/var/log/redis"
    ]
    for dir in dirs:
        d = host.file(dir)
        assert d.exists
        assert d.is_directory

def test_files(host):
    files = [
        "/etc/systemd/system/redis_6379.service",
        "/etc/redis/6379.conf",
        "/var/log/redis/redis_6379.log"
    ]
    for file in files:
        f = host.file(file)
        assert f.exists
        assert f.is_file

# def test_passwd_file(host):
#     passwd = host.file("/etc/passwd")
#     assert passwd.user == "redis"
#     assert passwd.group == "redis"

def test_bin(host):
    bins = [
        "/opt/redis/bin/redis-server"
    ]
    for bin in bins:
        b = host.file(bin)
        assert b.exists
        assert b.is_file

def test_service(host):
    s = host.service("redis_6379")
    assert s.is_enabled
    assert s.is_running


def test_socket(host):
    sockets = [
        "tcp://127.0.0.1:6379"
    ]
    for socket in sockets:
        s = host.socket(socket)
        assert s.is_listening