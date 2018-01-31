#### 用途

- 基于Redis List日志消息，归档日志文件
- 解决Logstash(新版本单线程可解决)归档乱序问题
- 架构: Filebeat->Redis->Plogstash->Files
#### 用法:
```
python3 plogstash.py
Usage: plogstash.py [start|stop|restart|status]
```
