#!/usr/bin/env python
#Author: Geekwolf
# -*- coding: utf-8 -*-

from pyzabbix import ZabbixAPI
import xlsxwriter
import time
import sys


zabbix_url = 'https://zbx.simlinux.com'
zabbix_user = 'geekwolf'
zabbix_passwd = 'geekwolf'
groups_name = ["hostgroup_name"]
items_key = {"custom.tcp.conn.stat[established]": "TCP", "custom.udp.conn.stat[inuse]": "UDP",
             "system.cpu.util[,idle]": "CPU", "system.cpu.load[all,avg5]": "LOAD", "proc.num[]": "PROC"}
zapi = ZabbixAPI(zabbix_url)
zapi.session.auth = (zabbix_user, zabbix_passwd)
zapi.session.verify = False
zapi.login(zabbix_user, zabbix_passwd)


def get_data(start, end):
    group_id = zapi.hostgroup.get(output="groupid", filter={"name": groups_name})[0]['groupid']
    # hosts_ip = json.dumps(zapi.host.get(output=["hostid", "host"], selectGroups="extend", filter={"groupids": "33"}))
    hosts_ip = zapi.host.get(output=["hostid", "host"], groupids=group_id)

    his_data = []
    for host in hosts_ip:
        data = {}
        dict1 = []

        for key, value in items_key.items():
            item_id = zapi.item.get(output=["itemids", "value_type", "key_"], hostids=host['hostid'],
                                    filter={"key_": key})
            # print key +'--------' + value
            history = zapi.history.get(history=item_id[0]['value_type'],
                                       itemids=item_id[0]['itemid'], time_from=start, time_till=end)
            _tmp = []
            for h in history:
                _tmp.append(float(h['value']))
            if _tmp:
                imax = max(_tmp)
                imin = min(_tmp)
                iavg = float(sum(_tmp) / len(_tmp))
                # print item_id[0]['key_'] + "max:%.1f,min:%.1f,iavg:%.2f" % (imax, imin, iavg)

                if value == 'TCP' or value == 'UDP' or value == 'PROC':
                    dict1.extend([int(imax), int(iavg), int(imin)])
                elif value == 'CPU':
                    dict1.extend([format(float(100 - imin), '0.2f') + "%", format(float(100 - iavg), '0.2f') + "%",
                                  format(float(100 - imax), '0.2f') + "%"])
                else:
                    dict1.extend([format(imax, '0.2f'), format(iavg, '0.2f'), format(imin, '0.2f')])
            else:
                imax = 'None'
                imin = 'None'
                iavg = 'None'
                # print "max:%s,min:%s,avg:%s" % (imax, imin, iavg)

                dict1.extend([imax, iavg, imin])

        data[host['host']] = dict1
        his_data.append(data)
    return his_data


def dump_excel(data):
    # Create a workbook and add a worksheet.
    workbook = xlsxwriter.Workbook('zabbix_report.xlsx')
    worksheet = workbook.add_worksheet(u'服务器状态')

    # Add a title content format to use to highlight cells.
    title = workbook.add_format({'bold': True, 'align': 'center', 'border': 1, 'font_name': 'Microsoft YaHei'})
    content = workbook.add_format({'align': 'left', 'border': 1})

    # Write some data headers.
    row2 = [u'UDP(单位/个)', u'CPU(单位/百分比)', u'TCP(单位/个)', u'LOAD(5分钟)', u'系统进程数(单位/个)']
    row2_col2 = [u'服务项/监控项', u'服务器地址']
    row3 = [u'', u'', u'最大值', u'平均值', u'最小值', u'最大值', u'平均值', u'最小值', u'最大值', u'平均值', u'最小值', u'最大值', u'平均值', u'最小值',
            u'最大值', u'平均值', u'最小值']
    worksheet.merge_range('A1:Q1', u'服务器状态（最近7天数据统计）', title)

    c = 0
    for item in row2_col2:
        worksheet.merge_range(1, c, 2, c, item, title)
        c += 1
    # Set the column 1-2 width size
    worksheet.set_column(0, 1, 25)

    c = 0
    for item in row2:
        worksheet.merge_range(1, c + 2, 1, c + 4, item, title)
        c += 3

    c = 0
    for item in row3:
        worksheet.write(2, c, item, content)
        c += 1

    row_number = 2

    for p in data:
        row_number += 1
        for key, value in p.items():
            col_number = 1
            worksheet.write(row_number, col_number - 1, key, content)
            worksheet.write(row_number, col_number, key, content)

            print row_number, col_number - 1
            for v in value:
                col_number += 1
                worksheet.write(row_number, col_number, v, content)

    workbook.close()


if __name__ == '__main__':
    start_time = time.time()
    if len(sys.argv) < 2:
        print "Please Input the start time and end time to report like 2016-10-18 10:11:30" + "\n" + '"2016-10-18 10:11:30" "2016-10-18 11:11:30"'
        sys.exit()
    else:
        his_data = get_data(time.mktime(time.strptime(sys.argv[1], '%Y-%m-%d %H:%M:%S'))
                            , time.mktime(time.strptime(sys.argv[2], '%Y-%m-%d %H:%M:%S')))
        dump_excel(his_data)
        end_time = time.time()
        times = end_time - start_time
        print '%s min,%s sec' % (int(times / 60), int(times % 60))
