import os
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_directories(host):
    dirs = [
        "/etc/pgbouncer",
        "/var/log/pgbouncer",
        "/var/run/pgbouncer"
    ]
    for dir in dirs:
        d = host.file(dir)
        assert d.is_directory
        assert d.exists


def test_files(host):
    files = [
        "/etc/pgbouncer/pgbouncer.ini",
        "etc/pgbouncer/userlist.txt",
        "/etc/pgbouncer/pgbouncer_hba.conf",
        "/var/log/pgbouncer/pgbouncer.log",
        "/var/run/pgbouncer/pgbouncer.pid"
    ]
    for file in files:
        f = host.file(file)
        assert f.exists
        assert f.is_file


def test_service(host):
    s = host.service("pgbouncer")
    assert s.is_enabled
    assert s.is_running


def test_socket(host):
    sockets = [
        "tcp://0.0.0.0:6432"
    ]
    for socket in sockets:
        s = host.socket(socket)
        assert s.is_listening