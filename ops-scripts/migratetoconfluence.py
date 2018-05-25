# -*- coding: utf-8 -*-
# @Author: Geekwolf
# @Date:   2018-05-24 17:58:16
# @Last Modified by:   Geekwolf
# @Last Modified time: 2018-05-25 19:50:37

import pymysql
import collections
import requests
import json
import markdown


class DBHelper(object):
    """docstring for DBHelper"""

    def __init__(self):
        self.host = '192.168.1.1'
        self.user = 'wiki'
        self.password = 'password'
        self.database = 'db'
        self.conn = None
        self.cur = None

    def ConnDB(self):
        try:
            self.conn = pymysql.connect(self.host, self.user, self.password, self.database, charset='utf8')
        except Exception as e:
            print(str(e))
            return False
        self.cur = self.conn.cursor()
        return True

    def Close(self):
        if self.conn and self.cur:
            self.cur.close()
            self.conn.close()
        return True

    def Execute(self, sql, params=None):
        self.ConnDB()
        try:
            if self.conn and self.cur:
                self.cur.execute(sql, params)
                self.conn.commit()
        except Exception as e:
            print(str(e))
            self.Close()
            return False
        return True

    def Select(self, sql, params=None):
        self.Execute(sql, params)
        return self.cur.fetchall()


class SyncWiki(object):
    """docstring for SyncWiki"""

    def __init__(self, ):

        # The Space:autotest Key Name
        self.space = 'ops'
        self.url = 'http://confluence'
        self.username = 'geekwolf'
        self.password = 'geekwolf'
        self.session = self.GetSession()
        # self.home_page = '{} Home'.format(self.space)
        self.home_page='ops'
        self.headers = {'Content-Type': 'application/json'}
        self.dbhelper = DBHelper()

    def GetSession(self):
        session = requests.session()
        data = {'os_username': self.username, 'os_password': self.password, 'login': 'Log in'}
        res = session.post(self.url, data)
        return session

    def MarkdownToHtml(self, content):
        # convert_url = "{}/rest/api/contentbody/convert/storage".format(self.url)
        # print(convert_url)
        # data = {"value": content, "representation": "wiki"}
        # ret = self.session.post(convert_url, json.dumps(data), headers=self.headers)

        ret = markdown.markdown(content, extensions=['fenced_code', 'codehilite', 'extra', 'abbr', 'attr_list', 'def_list', 'footnotes',
                                                     'tables', 'smart_strong', 'admonition', 'codehilite', 'headerid', 'meta', 'nl2br', 'sane_lists', 'smarty', 'toc', 'wikilinks'])
        return ret

    def GetPageId(self, title):
        '''
                通过分类名称获取在Confluence中的id
        '''
        content_url = '{}/rest/api/content?spaceKey={}&title={}'.format(self.url, self.space, title)
        data = self.session.get(content_url).json()
        id = data['results'][0]['id']
        return id

    def CreatePageMethod(self, id, title, value=None):

        page_url = '{}/rest/api/content'.format(self.url)
        data = {"type": "page", "ancestors": [{"id": id}], "title": title, "space": {
            "key": self.space}, "body": {"storage": {"value": value, "representation": "storage"}}}
        self.session.post(page_url, json.dumps(data), headers=self.headers)

    def CreateTypePage(self):
        '''
                创建分类页面(二级分类)
        '''
        group_page_url = '{}/rest/api/content'.format(self.url)
        group_info = self.GetGroupInfo()

        try:
            for k, v in group_info.items():
                self.CreatePageMethod(self.GetPageId(self.home_page), k)
                for i in v:
                    self.CreatePageMethod(self.GetPageId(k), i)
            ret = True
        except Exception as e:
            print(str(e))
            ret = False
        return ret

    def CreatePage(self):
        '''
                根据标题和内容创建对应子类的页面
        '''
        content = self.GetWiki()
        for i in content:
            try:
                id = self.GetPageId(i[0])
                title = i[1]
                value = self.MarkdownToHtml(i[2])
                self.CreatePageMethod(id, title, value=value)
                print('{}------{}已经创建'.format(i[0], i[1]))
            except Exception as e:
                print('{}------{}创建失败:{}'.format(i[0], i[1], str(e)))

    def GetGroupInfo(self):

        sql = 'select * from wiki_group;'
        result = self.dbhelper.Select(sql)
        _group_info = collections.defaultdict(list)
        _group_dict = dict([(r[0], r[1]) for r in result])

        for r in result:
            if r[3] is None:
                _group_info[r[1]] = []
            else:
                _group_info[_group_dict[r[3]]].append(r[1])
        return _group_info

    def GetWiki(self):

        sql = 'SELECT g.name,w.title,w.content from wiki_wiki as w LEFT JOIN wiki_group  as g ON w.group_id = g.id'
        result = self.dbhelper.Select(sql)
        return result


if __name__ == '__main__':

    ins = SyncWiki()
    if ins.CreateTypePage():
        ins.CreatePage()

