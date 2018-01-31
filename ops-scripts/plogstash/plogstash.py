# -*- coding: utf-8 -*-
# @Author: Geekwolf
# @Date:   2018-01-29 14:23:04
# @Last Modified by:   Geekwolf
# @Last Modified time: 2018-01-31 10:55:01

#!/usr/bin/env python3
# daemon.py

import os
import sys
import time
import redis
import json
import re
import atexit
import signal
# import collections


class Base(object):

    def __init__(self, *args, **kwargs):

        self.pidfile = '/var/run/plogstash.pid'
        self.service_name = 'Plogstash'
        self.path = '/var/log/plogstash'
        os.makedirs(self.path, exist_ok=True)
        self.logfile = '%s/%s.log' % (self.path, self.service_name)

        self.redis_host = '127.0.0.1'
        self.redis_password = 'geekwolf'
        self.redis_port = 5044
        self.redis_db = 0
        self.redis_key = 'filebeat'
        self.batch_size = 5000
        self.expires = 5  # second
        self.archive_time = 1  # how long time to archive
        self.base_dir = '/data/logs'
        # self._tmp = '/tmp/.%s' % self.service_name


class Daemon(Base):

    def __init__(self, *args, **kwargs):
        super(Daemon, self).__init__(*args, **kwargs)

    def daemonize(self):

        # First fork (detaches from parent)
        try:
            if os.fork() > 0:
                raise SystemExit(0)   # Parent exit
        except OSError as e:
            raise RuntimeError('fork #1 failed.')

        os.chdir('/')
        # set this will 777
        # os.umask(0)
        os.setsid()
        # Second fork (relinquish session leadership)
        try:
            if os.fork() > 0:
                raise SystemExit(0)
        except OSError as e:
            raise RuntimeError('fork #2 failed.')

        # Flush I/O buffers
        sys.stdout.flush()
        sys.stderr.flush()

        # Replace file descriptors for stdin, stdout, and stderr
        with open(self.logfile, 'ab', 0) as f:
            os.dup2(f.fileno(), sys.stdout.fileno())
        with open(self.logfile, 'ab', 0) as f:
            os.dup2(f.fileno(), sys.stderr.fileno())
        with open(self.logfile, 'rb', 0) as f:
            os.dup2(f.fileno(), sys.stdin.fileno())

        # Write the PID file
        print(os.getpid())
        with open(self.pidfile, 'w') as f:
            print(os.getpid(), file=f)

        # Arrange to have the PID file removed on exit/signal
        atexit.register(lambda: os.remove(self.pidfile))

        # Signal handler for termination (required)
        def sigterm_handler(signo, frame):
            raise SystemExit(1)

        signal.signal(signal.SIGTERM, sigterm_handler)

    def get_now_date(self):

        return time.strftime('%Y-%m-%d', time.localtime(time.time()))

    def get_now_timestamp(self):

        return time.time()

    def get_now_time(self):
        return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())

    def logging(self, msg):

        with open(self.logfile) as f:
            print('%s  %s' % (self.get_now_time(), msg))

    def append_log(self):
        pass

    def start(self):

        if os.path.exists(self.pidfile):
            raise RuntimeError('Already running')
        else:
            try:
                self.daemonize()
                self.append_log()
                self.status()
            except RuntimeError as e:
                print(e, file=sys.stderr)
                raise SystemExit(1)

    def stop(self):

        # f = os.open(self.pipe_path, os.O_RDONLY | os.O_NONBLOCK)
        # ret = os.read(f, 1024).decode('utf-8')
        # print(ret.split('\n'))
        # os.close(f)

        if os.path.exists(self.pidfile):
            # with open(self._tmp) as f:
            #     _data = f.read()
            #     if _data is not None and len(eval(_data)) > 0:
            #         for k, v in eval(_data).items():
            #             v = v['fd'].rstrip('\n')
            #             v.close()
            with open(self.pidfile) as f:
                os.kill(int(f.read()), signal.SIGTERM)
            print('Plogstash is stopped')
        else:
            print('Not running', file=sys.stderr)
            raise SystemExit(1)

    def restart(self):

        self.stop()
        self.start()

    def status(self):

        try:
            with open(self.pidfile, 'r') as f:
                pid = int(f.read().strip())
        except:
            pid = None

        if pid:
            print('%s is running as pid:%s' % (self.service_name, pid))
        else:
            print('%s is not running' % self.service_name)


class Worker(Daemon):

    def __init__(self, *args, **kwargs):
        super(Worker, self).__init__(self, *args, **kwargs)

    def _redis(self):

        pool = redis.ConnectionPool(host=self.redis_host, password=self.redis_password, port=self.redis_port, db=self.redis_db, socket_timeout=10000)
        rc = redis.StrictRedis(connection_pool=pool)
        return rc

    def get_redis_data(self):

        _data = self._redis().lrange(self.redis_key, 0, self.batch_size - 1)
        # 删除数据(可考虑处理完再删除)
        return _data

    def del_redis_data(self):

        _data = self._redis().ltrim(self.redis_key, self.batch_size, -1)

    def append_log(self):

        file_meta = {}
        # file_handler = collections.defaultdict(dict)
        # try:
        #     os.mkfifo(self.pipe_path)
        # except Exception as e:
        #     print(str(e))

        # pipe_ins = os.open(self.pipe_path, os.O_SYNC | os.O_CREAT | os.O_RDWR)
        while True:
            time.sleep(self.archive_time)
            _data = self.get_redis_data()
            if _data:
                for _d in _data:
                    try:
                        _d = json.loads(_d.decode('utf-8'))
                        _path = '%s/%s/%s/%s' % (self.base_dir, _d['fields']['env'], self.get_now_date(), _d['fields']['ip_address'])
                        os.makedirs(_path + '/logs', exist_ok=True)
                        file_name = _d['source'].split('/')[-1]
                       # _path = '%s/%s/%s/%s' % (self.base_dir, _d['fields']['env'],self.get_now_date(), _d['fields']['ip_address'])

                        if re.match('nohup', file_name):
                            file_path = '%s/%s' % (_path, file_name)
                        else:
                            file_path = '%s/logs/%s' % (_path, file_name)

                        with open(file_path, 'a') as f:
                            f.write(_d['message'] + '\n')
                        # if 'fd' not in file_handler[file_path]:
                        #     f = open(file_path, 'a', buffering=1024000)
                        #     file_handler[file_path]['fd'] = str(f)
                        # file_handler[file_path]['time'] = self.get_now_timestamp()
                    except Exception as e:
                        self.logging(str(e))
                self.del_redis_data()
            # with open(self._tmp, 'w') as f:
            #     f.write(json.dumps(file_handler))

if __name__ == '__main__':

    if len(sys.argv) != 2:
        print('Usage: {} [start|stop|restart|status]'.format(sys.argv[0]), file=sys.stderr)
        raise SystemExit(1)

    daemon = Worker()
    if sys.argv[1] == 'start':
        daemon.start()
    elif sys.argv[1] == 'stop':
        daemon.stop()
    elif sys.argv[1] == 'restart':
        print("Restart ...")
        daemon.restart()
    elif sys.argv[1] == 'status':
        daemon.status()
    else:
        print('Unknown command {!r}'.format(sys.argv[1]), file=sys.stderr)
        raise SystemExit(1)
